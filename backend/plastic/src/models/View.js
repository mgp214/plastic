const mongoose = require('mongoose');

const viewSchema = mongoose.Schema({
	name: {
		type: String
	},
	userId: {
		type: mongoose.Types.ObjectId,
		required: true,
	},
	root: {
		type: mongoose.Schema.Types.Mixed,
		required: true,
	}
});

viewSchema.statics.findAllByUser = async (userId) => {
	const views = await View.find({ 'userId': userId });
	return views;
};

viewSchema.statics.findById = async (viewId) => {

	const view = await View.findById(viewId);
	if (view) {
		return view;
	}
	throw new Error(`View with id: ${viewId} not found.`);
};

const View = mongoose.model('View', viewSchema);

module.exports = View;


