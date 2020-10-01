const Template = require('../models/Template');

const Events = {
	setupNewUser: async function (user) {
		const taskTemplate = new Template({
			userId: user._id,
			name: 'Task',
			fields: [
				{
					name: 'description',
					fieldType: 'STRING',
					required: true,
					main: true,
					default: 'new task'
				}
			]
		});
		await taskTemplate.save();
	}
};

module.exports = Events;