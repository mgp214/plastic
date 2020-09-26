const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');
const jwt = require('jsonwebtoken');
const Events = require('../events/events');
const router = express.Router();

// Create a new user
router.post('/users', async (req, res) => {
	try {
		const user = new User(req.body);
		await user.save();
		const token = await user.generateAuthToken();

		Events.setupNewUser(user);

		res.status(201).send({ user, token });
	} catch (error) {
		res.status(400).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});

// Login a registered user
router.post('/users/login', async (req, res) => {
	try {
		const { email, password } = req.body;
		const user = await User.findByCredentials(email, password);
		if (!user) {
			return res.status(401)
				.send({ error: 'Login failed! Check authentication credentials' });
		}
		const token = await user.generateAuthToken();
		res.send({ user, token });
	} catch (error) {
		res.status(400).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});

// View logged in user profile
router.get('/users/me', auth, async (req, res) => {

	res.send(req.user);
});

// Log user out of the application
router.post('/users/me/logout', auth, async (req, res) => {
	try {
		req.user.tokens = req.user.tokens.filter((token) => {
			return token.token != req.token;
		});
		await req.user.save();
		res.send();
	} catch (error) {
		res.status(500).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});

// Log user out of all devices
router.post('/users/me/logoutall', auth, async (req, res) => {
	try {
		req.user.tokens.splice(0, req.user.tokens.length);
		await req.user.save();
		res.send();
	} catch (error) {
		res.status(500).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
});

// Verifies that a given token is still valid for authorization.
router.post('/users/checktoken', async (req, res) => {
	try {
		var token = req.body.token;
		const data = jwt.verify(token, process.env.JWT_KEY);
		const user = await User.findOne({ _id: data._id, 'tokens.token': token });

		if (user) {
			res.send(true);
			return;
		}
	} catch (error) {
		res.status(500).statusMessage = error.toString();
		res.send();
		console.log(error);
	}
	res.send(false);
});

module.exports = router;