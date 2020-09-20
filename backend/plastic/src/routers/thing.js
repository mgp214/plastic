const express = require('express');
const Thing = require('../models/Thing');
const auth = require('../middleware/auth');
const router = express.Router();



// Create a new thing
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
		res.status(400).send({ error: error.toString() });
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