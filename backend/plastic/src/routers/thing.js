const express = require('express');
const Thing = require('../models/Thing');
const auth = require('../middleware/auth');
const router = express.Router();


// Create a new thing, or update if it exists already
router.post('/things/save', auth, async (req, res) => {
	try {
		const thing = new Thing(req.body);
		thing.userId = req.user._id;
		console.log('saving thing: ' + thing);
		await Thing.findOneAndUpdate(
			{ _id: thing._id },
			thing,
			{ upsert: true, useFindAndModify: false });
		res.status(201).send({ thing });
	} catch (error) {
		res.status(400).statusMessage = error.toString();
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
		res.status(200).send({ id });
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

module.exports = router;