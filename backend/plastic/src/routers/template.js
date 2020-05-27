const express = require('express');
const Template = require('../models/Template');
const auth = require('../middleware/auth');
const router = express.Router();

// Create a new template
router.post('/templates/create', auth, async (req, res) => {

	try {
		const template = new Template(req.body);
		template.userId = req.user._id;
		await template.save();
		res.status(201).send({ template });
	} catch (error) {
		res.status(400).send({ error: error.toString() });
		console.log(error);
	}
});

// Get all of a User's templates
router.get('/templates/all', auth, async (req, res) => {
	const templates = await Template.findAllByUser(req.user._id);
	res.send(templates);
});


module.exports = router;