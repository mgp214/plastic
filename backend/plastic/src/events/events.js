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
				},
				{
					name: 'complete',
					fieldType: 'bool',
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
				},
				{
					name: 'start',
					fieldType: 'datetime',
				},
				{
					name: 'ends',
					fieldType: 'datetime',
				},
			]
		});
		await eventTemplate.save();
	}
};

module.exports = Events;