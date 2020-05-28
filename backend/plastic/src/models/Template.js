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
			"fieldType": "string"
		},
		{
			"name": "field B",
			"fieldType": "double"
		},
	]
}
*/
const FIELD_TYPES = [
	'string',
	'int',
	'double',
	'enum',
	'bool',
	'date',
	'datetime'
];

templateSchema.pre('save', async function (next) {
	const template = this;

	const existingWithName = await Template.findOne({ 'name': template.name, 'userId': template.userId });

	if (existingWithName && existingWithName._id != template._id) {
		throw new Error('User already has different template with name [{' + template.name + '}]');
	}
	var errors = [];
	// template.fields is a CoreMongooseArray that is a pain to work with, so we're simplifying it here
	var simplifiedFields = template.toBSON().fields.map(o => o[0]);
	for (var i = 1; i < simplifiedFields.length; i++) {
		var field = simplifiedFields[i];
		if (FIELD_TYPES.indexOf(field.fieldType) == -1) {
			errors.push('\n- field [' + field.name + '] has an invalid type of [' + field.fieldType + ']');
		}
	}

	if (errors.length > 0) {
		throw new Error('Encountered one or more validation errors saving template [' + template.name + ']: '.concat(errors));
	}

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