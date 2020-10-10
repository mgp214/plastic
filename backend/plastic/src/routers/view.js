const express = require('express');
const View = require('../models/View');
const auth = require('../middleware/auth');
const router = express.Router();

// Create a new view, or update if it exists already
router.post('/views/save', auth, async (req, res) => {
	try {
		const view = new View(req.body);
		view.userId = req.user._id;
		console.log('saving view ' + view._id.toString());
		await View.findOneAndUpdate(
			{ _id: view._id },
			view,
			{ upsert: true, useFindAndModify: false });
		res.send({ view });
	} catch (error) {
		res.status(500).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});

// Deletes a view
router.post('/views/delete', auth, async (req, res) => {
	try {
		const id = req.body.id;
		const userId = req.user._id;
		console.log('deleting view with id: ' + id);
		await View.findOneAndDelete(
			{ _id: id.toString(), userId: userId });
		res.send({ id });
	} catch (error) {
		res.status(400).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});

// Get all of a User's things
router.get('/views/all', auth, async (req, res) => {
	const things = await View.findAllByUser(req.user._id);
	res.send(things);
});

module.exports = router;