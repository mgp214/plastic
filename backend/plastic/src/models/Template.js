const mongoose = require('mongoose');

const templateSchema = mongoose.Schema({
	userId: {
		type: mongoose.Types.ObjectId,
		required: true,
	},
	name: {
		type: String
	},
	fields: {
		type: mongoose.SchemaTypes.Array
	}
});

/*
exmaple:
{
	userId: "SOME_ID",
	_id: "SOME_OTHER_ID",
	name: "A friendly template name"
	fields: [
		{
			"name": "field A",
			"fieldType": "String"
		},
		{
			"name": "field B",
			"fieldType": "double"
		},
	]
}
*/

templateSchema.pre('save', async function (next) {
	//const template = this;


	//TODO: validate fields against accepted types.
	//TODO: validate no duplicate template name for user

	next();
});

templateSchema.statics.findAllByUser = async (userId) => {
	const templates = await Template.find({ 'userId': userId });
	return templates;
};

templateSchema.statics.findById = async (templateId) => {
	const template = await Template.findById(templateId);
	if (template) {
		return template;
	}
	throw new Error(`Template with id: ${templateId} not found.`);
};

const Template = mongoose.model('Template', templateSchema);

module.exports = Template;