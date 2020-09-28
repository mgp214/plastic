const express = require('express');
const Template = require('../models/Template');
const Thing = require('../models/Thing');
const auth = require('../middleware/auth');
const router = express.Router();

// // Create a new template, or update if it exists already
// router.post('/templates/create', auth, async (req, res) => {

// 	try {
// 		const template = new Template(req.body);
// 		template.userId = req.user._id;
// 		await template.save();
// 		res.status(201).send({ template });
// 	} catch (error) {
// 		res.status(400).statusMessage = error.toString();
// 		res.send();
// 		console.log(error);
// 	}
// });

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

async function getListOfAffectedThings(template) {
	var affectedThings = await Thing.find({ templateId: template.id }).exec();
	return affectedThings.length > 0 ? affectedThings : false;
}

async function saveTemplate(template) {
	console.log('saving template: ' + template._id.toString());
	await Template.findOneAndUpdate(
		{ _id: template._id },
		template,
		{ upsert: true, useFindAndModify: false });
}

// Create a new template, or update if it exists already
router.post('/templates/save', auth, async (req, res) => {
	try {
		const template = new Template(JSON.parse(req.body.template));
		// const updatedThingsJson = JSON.parse(req.body.updatedThings);
		const updatedThings = req.body.updatedThings.map(t => new Thing(JSON.parse(t)));
		template.userId = req.user._id;
		var affectedThings = await getListOfAffectedThings(template);
		console.log(updatedThings);
		if (affectedThings) {
			//TODO: verify each affected thing is included in the updated things provided.
			// console.log(affectedThings);
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
				res.status(201).send({ template: template });
			}
			return;
		}
		console.log('no affected things.');
		saveTemplate(template);
		res.status(201).send({ template: template });
	} catch (error) {
		res.status(400).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});

// Deletes a template
router.post('/templates/delete', auth, async (req, res) => {
	try {
		const id = req.body.id;
		const userId = req.user._id;
		console.log('deleting template with id: ' + id);
		await Template.findOneAndDelete(
			{ _id: id.toString(), userId: userId });
		res.status(200).send({ id });
	} catch (error) {
		res.status(400).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});


module.exports = router;