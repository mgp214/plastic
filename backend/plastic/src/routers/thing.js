const express = require('express');
const moment = require('moment');
const Thing = require('../models/Thing');
const Template = require('../models/Template');
const auth = require('../middleware/auth');
const router = express.Router();

// Make sure that the given thing is valid according to its template.
async function validateAgainstTemplate(thing) {
	const template = await Template.findById(thing.templateId);

	// first check that each template field is present and valid in thing
	for (var i = 0; i < template.fields.toBSON().length; i++) {
		var templateField = template.fields.toBSON()[i];

		var matchingCount = 0;
		for (var thingField of thing.toBSON().fields) {
			matchingCount += thingField._id.toString() == templateField._id.toString() ? 1 : 0;
		}

		if (matchingCount != 1) return false;
		var matchingIndex = thing.fields.toBSON().findIndex(f => f._id.toString() == templateField._id.toString());
		if (matchingIndex == -1) return false;
		var matchingField = thing.fields.toBSON()[matchingIndex];
		if (matchingField.name != templateField.name) return false;
		if (templateField.fieldType == 'ENUM') {
			if (matchingField.value != null && templateField.choices.findIndex(c => c == matchingField.value) == -1) return false;
		}
	}

	// finally, make sure that there aren't any extra fields in the thing.
	if (template.fields.toBSON().length != thing.fields.toBSON().length) return false;

	// made it to the end, thing is valid.
	return true;
}

// Create a new thing, or update if it exists already
router.post('/things/save', auth, async (req, res) => {
	try {
		const thing = new Thing(req.body);
		thing.userId = req.user._id;
		console.log('validating thing [' + thing.id.toString() + '] against its template ' + thing.templateId.toString());
		if (!await validateAgainstTemplate(thing)) {
			res.status(400).statusMessage = 'thing does not match its template.';
			res.send();
			return;
		}
		console.log('saving thing ' + thing._id.toString());
		await Thing.findOneAndUpdate(
			{ _id: thing._id },
			thing,
			{ upsert: true, useFindAndModify: false });
		res.send({ thing });
	} catch (error) {
		res.status(500).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});

// Deletes a thing
router.post('/things/delete', auth, async (req, res) => {
	try {
		const id = req.body.id;
		const userId = req.user._id;
		console.log('deleting thing with id: ' + id);
		await Thing.findOneAndDelete(
			{ _id: id.toString(), userId: userId });
		res.send({ id });
	} catch (error) {
		res.status(400).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});

// Get all of a User's things
router.get('/things/all', auth, async (req, res) => {
	const things = await Thing.findAllByUser(req.user._id);
	res.send(things);
});

// Get all of a template's things.
router.get('/things/bytemplate', auth, async (req, res) => {
	const things = await Thing.findByTemplate(req.body.templateId);
	res.send(things);
});

function getFindParamsWithFieldDetails(fieldName, fieldType, valueObject) {
	return { 'fields': { $elemMatch: { 'name': fieldName, 'fieldType': fieldType, 'value': valueObject } } };
}

function getDateFieldFindParams(condition) {
	switch (condition['value'].substring(0, 1)) {
		case 'A':
			return condition['value'].substring(2);
		case 'R':
			var unit = condition['value'][2];
			var quantity = parseFloat(condition['value'].split(' ')[1]);
			var tzMinutes = parseInt(condition['value'].split(' ')[2]);
			var date = moment(Date.now()).add(tzMinutes, 'm').toDate();
			var isLookingForward = condition['value'].split(' ')[1].substring(0, 1) == '+';
			var currentDateString = date.toISOString().substring(0, 10);
			date = moment(date).add(quantity, unit).toDate();
			var otherDateString = date.toISOString().substring(0, 10);
			if (isLookingForward) {
				return {
					$gte: currentDateString,
					$lte: otherDateString,
				};
			} else {
				return {
					$lte: currentDateString,
					$gte: otherDateString,
				};
			}
		case 'C':
			var calendarUnit = condition['value'][2];
			var direction = condition['value'][3];
			tzMinutes = parseInt(condition['value'].split(' ')[1]);
			var calendarDate = moment(Date.now()).add(tzMinutes, 'm').toDate();
			console.log('local date: ' + calendarDate.toISOString().substring(0, 10));
			switch (direction) {
				case '-':
					// previous
					date = moment(calendarDate).subtract(1, calendarUnit).toDate();
					break;
				case '=':
					// current
					break;
				case '+':
					// next
					date = moment(calendarDate).add(1, calendarUnit).toDate();
					break;
			}
			var startDate = moment(date).startOf(calendarUnit).toISOString().substring(0, 10);
			var endDate = moment(date).endOf(calendarUnit).subtract(1, 'd').toISOString().substring(0, 10);
			console.log('finding values between ' + startDate + ' and ' + endDate);
			if (calendarUnit == 'd') return startDate;
			return {
				$gte: startDate,
				$lte: endDate,
			};
		case 'U':
			return null;
	}
}

function getFindParams(condition) {
	if (condition['type'] == 'operation') {
		var operands = [];
		for (var i = 0; i < condition['operands'].length; i++) {
			operands.push(getFindParams(condition['operands'][i]));
		}
		switch (condition['operator']) {
			case 'OPERATOR.AND':
				return { $and: operands };
			case 'OPERATOR.NOT':
				return { $nor: operands };
			case 'OPERATOR.OR':
				return { $or: operands };
		}
	}
	if (condition['type'] == 'template') {
		return { templateId: condition['value'] };
	}
	if (condition['type'] == 'value') {
		var value = condition['value'];
		switch (condition['fieldType']) {
			case 'FieldType.BOOL':
				value = value == 'true';
				break;
			case 'FieldType.INT':
				value = parseInt(value);
				break;
			case 'FieldType.DOUBLE':
				value = parseFloat(value);
				break;
			case 'FieldType.DATE':
				value = getDateFieldFindParams(condition);
		}
		var fieldName = condition['fieldName'];
		var fieldType = condition['fieldType'].split('.')[1];
		var valueObject = null;
		//if it's a DATE field, we've already built the valueObject directly into value.
		if (fieldType == 'DATE') return getFindParamsWithFieldDetails(fieldName, fieldType, value);
		switch (condition['comparison']) {
			case 'ValueComparison.E':
				valueObject = value;
				break;
			case 'ValueComparison.GT':
				valueObject = { $gt: value };
				break;
			case 'ValueComparison.GTE':
				valueObject = { $gte: value };
				break;
			case 'ValueComparison.LT':
				valueObject = { $lt: value };
				break;
			case 'ValueComparison.LTE':
				valueObject = { $lte: value };
				break;
			case 'ValueComparison.STR_CONTAINS':
				valueObject = { $regex: value, $options: 'i' };
				break;
		}
		return getFindParamsWithFieldDetails(fieldName, fieldType, valueObject);
	}
}

router.post('/things/matching', auth, async (req, res) => {
	try {
		const userId = req.user._id;
		const condition = req.body;
		console.log('finding thing with condition: ' + JSON.stringify(condition));
		const findParams = getFindParams(condition);
		const findParamsWithUser = {
			$and: [
				findParams,
				{ userId: userId }
			]
		};
		console.log('processed condition into find params: ' + JSON.stringify(findParamsWithUser));
		const things = await Thing.find(findParamsWithUser);
		res.send(things);
	} catch (error) {
		res.status(400).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});

module.exports = router;