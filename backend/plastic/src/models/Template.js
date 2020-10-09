const mongoose = require('mongoose');

const templateFieldSchema = mongoose.Schema({
	'name': String,
	'fieldType': String,
	'value': mongoose.Schema.Types.Mixed,
	'default': mongoose.Schema.Types.Mixed,
	'main': Boolean,
});

const templateSchema = mongoose.Schema({
	userId: {
		type: mongoose.Types.ObjectId,
		required: true,
	},
	name: {
		type: String
	},
	fields: [templateFieldSchema]
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
	'STRING',
	'INT',
	'DOUBLE',
	'ENUM',
	'BOOL',
	'DATE',
	'DATETIME'
];

function validateFieldValue(field, value) {
	switch (field.fieldType) {
		case 'STRING':
			return typeof (value) == 'string';
		case 'INT':
			return typeof (value) == 'number' && value % 1 == 0;
		case 'DOUBLE':
			return typeof (value) == 'number';
		case 'ENUM':
			return field.values.indexOf(value) != -1;
		case 'BOOL':
			return typeof (value) == 'boolean';
		case 'DATE':
			return isNaN(Date.parse(value)) && value.length == 10;
		case 'DATETIME':
			return isNaN(Date.parse(value)) && value.length >= 13;
	}
}

templateSchema.statics.validate = async function (template) {
	// const template = this;

	const existingWithName = await Template.findOne({ 'name': template.name, 'userId': template.userId });
	var errors = [];

	if (existingWithName && existingWithName._id.toString() != template._id.toString()) {
		errors.push('You already have a template with name "' + template.name + '"');
	}

	var fields = template.toBSON().fields;
	if (!this.name) errors.push('Template must have a name.');
	for (var i = 0; i < fields; i++) {
		var field = fields[i];
		if (FIELD_TYPES.indexOf(field.fieldType) == -1) {
			errors.push('field "' + field.name + '" has an unknown type.');
		}
	}

	var numMains = 0;
	fields.forEach(field => {
		if (!field.name) {
			errors.push('field without a name');
			return;
		}
		if (!field.fieldType) {
			errors.push('field "' + field.name + '" is doesn\'t have a type.');
			return;
		}
		numMains += field.main ? 1 : 0;
		if (field.main && field.fieldType != 'STRING')
			errors.push('field "' + field.name + '" is the main field, but is not a text field.');
		if (field.default && !validateFieldValue(field, field.default))
			errors.push('field "' + field.name + '" has an invalid default value of "' + field.default + '" for its type.');
	});
	if (numMains > 1)
		errors.push('Template can only have one "main" field.');
	if (numMains == 0)
		errors.push('Template must have a main field.');

	if (errors.length > 0)
		return errors;
	else
		return null;
};

templateSchema.pre('save', async function (next) {


	next();
});

templateSchema.statics.findAllByUser = async (userId) => {
	const templates = await Template.find({ 'userId': userId });
	return templates;
};

templateSchema.statics.findByIdAndUser = async (userId, templateId) => {
	const template = await Template.findOne({ 'userId': userId, '_id': templateId });
	if (template) {
		return template;
	}
	throw new Error(`Template with id: ${templateId} not found.`);
};

const Template = mongoose.model('Template', templateSchema);

module.exports = Template;