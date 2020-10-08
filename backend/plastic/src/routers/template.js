const express = require('express');
const Template = require('../models/Template');
const Thing = require('../models/Thing');
const auth = require('../middleware/auth');
const router = express.Router();

// Get all of a User's templates
router.get('/templates/all', auth, async (req, res) => {
	const templates = await Template.findAllByUser(req.user._id);
	res.send(templates);
});

// Get a template by id
router.get('/templates/:id', auth, async (req, res) => {
	const templates = await Template.findByIdAndUser(req.user._id, req.params.id);
	res.send(templates);
});

async function getListOfAffectedThings(templateId) {
	var affectedThings = await Thing.find({ templateId: templateId }).exec();
	return affectedThings.length > 0 ? affectedThings : false;
}

async function saveTemplate(template) {
	console.log('saving template: ' + template._id.toString());
	await Template.findOneAndUpdate(
		{ _id: template._id },
		template,
		{ upsert: true, useFindAndModify: false });
}

function validateTemplate(template) {
	const fields = template.toBSON().fields;
	var hasMainField = false;
	const errors = [];
	for (var field of fields) {
		if (field.main) hasMainField = true;
	}
	if (!hasMainField) errors.push('Template must a text field marked as main.');
	if (template.name == null || template.name.length < 1) errors.push('Template must have a name');
	//TODO: validate template name is unique per user

	return errors;
}

// Create a new template, or update if it exists already
router.post('/templates/save', auth, async (req, res) => {
	try {
		const template = new Template(JSON.parse(req.body.template));
		const errors = validateTemplate(template);
		if (errors.length != 0) {
			res.status(422).statusMessage = 'Invalid template';
			res.send({ templateErrors: errors });
			return;
		}
		const updatedThings = req.body.updatedThings.map(t => new Thing(JSON.parse(t)));
		template.userId = req.user._id;
		var affectedThings = await getListOfAffectedThings(template._id);
		console.log(updatedThings);
		if (affectedThings) {
			var updatedThingIds = updatedThings.map(thing => thing._id.toString());
			if (affectedThings.some(thing => updatedThingIds.indexOf(thing._id.toString()) == -1)) {
				console.log('request didn\'t include updates for all affected things, returning full list of affected things.');
				res.status(422).send(JSON.stringify({ affectedThings: affectedThings }));
			} else {
				console.log('request includes updates for all affected things. performing updates');
				for (var i = 0; i < updatedThings.length; i++) {
					var thing = updatedThings[i];
					thing.userId = req.user._id;
					console.log('saving thing ' + thing._id.toString());
					await Thing.findOneAndUpdate(
						{ _id: thing._id },
						thing,
						{ upsert: true, useFindAndModify: false });
				}
				saveTemplate(template);
				res.send({ template: template });
			}
			return;
		}
		console.log('no affected things.');
		saveTemplate(template);
		res.send({ template: template });
	} catch (error) {
		res.status(500).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});

// Deletes a template
router.post('/templates/delete', auth, async (req, res) => {
	try {
		const id = req.body.id;
		const userId = req.user._id;
		var affectedThings = await getListOfAffectedThings(id);
		if (affectedThings) {
			for (var i = 0; i < affectedThings.length; i++) {
				var thingId = affectedThings[i]._id;
				console.log('deleting thing with id: ' + thingId.toString());
				await Thing.findOneAndDelete(
					{ _id: thingId, userId: userId });
			}
		}
		console.log('deleting template with id: ' + id.toString());
		await Template.findOneAndDelete(
			{ _id: id.toString(), userId: userId });
		res.send({ id });
	} catch (error) {
		res.status(500).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});


module.exports = router;