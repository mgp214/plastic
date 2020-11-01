const express = require('express');
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
		// thing.fields.toBSON().reduce(
		// 	(matchingCount, currentField) => matchingCount += (currentField._id == templateField._id ? 1 : 0));
		if (matchingCount != 1) return false;
		var matchingIndex = thing.fields.toBSON().findIndex(f => f._id.toString() == templateField._id.toString());
		if (matchingIndex == -1) return false;
		var matchingField = thing.fields.toBSON()[matchingIndex];
		if (matchingField.name != templateField.name) return false;
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