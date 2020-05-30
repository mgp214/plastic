const Template = require('../models/Template');

const Events = {
	setupNewUser: async function (user) {
		const taskTemplate = new Template({
			userId: user._id,
			name: 'Task',
			fields: [
				{
					name: 'task',
					fieldType: 'STRING',
					required: true,
					main: true,
				},
				{
					name: 'complete',
					fieldType: 'BOOL',
					default: false,
				},
				{
					name: 'due date',
					fieldType: 'DATE',
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
					fieldType: 'STRING',
					required: true,
					main: true,
				},
				{
					name: 'start',
					fieldType: 'DATETIME',
					required: true,
				},
				{
					name: 'ends',
					fieldType: 'DATETIME',
					required: true,
				},
			]
		});
		await eventTemplate.save();
	}
};

module.exports = Events;