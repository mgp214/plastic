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

viewSchema.statics.findByIdAndUser = async (viewId, userId) => {

	const view = await View.findOne({ '_id': viewId, 'userId': userId });
	if (view) {
		return view;
	}
	throw new Error(`View with id: ${viewId} not found.`);
};

const View = mongoose.model('View', viewSchema);

module.exports = View;


