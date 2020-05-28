const Template = require('../models/Template');

const Events = {
	setupNewUser: async function (user) {
		const taskTemplate = new Template({
			userId: user._id,
			name: 'Task',
			fields: [
				{
					name: 'task',
					fieldType: 'string',
					required: true,
				},
				{
					name: 'complete',
					fieldType: 'bool',
					required: true,
				},
				{
					name: 'due date',
					fieldType: 'date',
				},
			]
		});
		await taskTemplate.save();

		const eventTemplate = new Template({
			userId: user._id,
			name: 'Event',
			fields: [
				{
					name: 'title',
					fieldType: 'string',
					required: true,
				},
				{
					name: 'start',
					fieldType: 'datetime',
					required: true,
				},
				{
					name: 'ends',
					fieldType: 'datetime',
					required: true,
				},
			]
		});
		await eventTemplate.save();
	}
};

module.exports = Events;