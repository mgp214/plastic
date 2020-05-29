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

function validateFieldValue(field, value) {
	switch (field.fieldType) {
		case 'string':
			return typeof (value) == 'string';
		case 'int':
			return typeof (value) == 'number' && value % 1 == 0;
		case 'double':
			return typeof (value) == 'number';
		case 'enum':
			return field.values.indexOf(value) != -1;
		case 'bool':
			return typeof (value) == 'boolean';
		case 'date':
			return isNaN(Date.parse(value)) && value.length == 10;
		case 'datetime':
			return isNaN(Date.parse(value)) && value.length >= 13;
	}
}

templateSchema.pre('save', async function (next) {
	const template = this;

	const existingWithName = await Template.findOne({ 'name': template.name, 'userId': template.userId });

	if (existingWithName && existingWithName._id != template._id) {
		throw new Error('User already has different template with name [{' + template.name + '}]');
	}
	var errors = [];
	// template.fields is a CoreMongooseArray that is a pain to work with, so we're simplifying it here
	var simplifiedFields = template.toBSON().fields.map(o => o[0]);
	for (var i = 0; i < simplifiedFields.length; i++) {
		var field = simplifiedFields[i];
		if (FIELD_TYPES.indexOf(field.fieldType) == -1) {
			errors.push('field [' + field.name + '] has an invalid type of [' + field.fieldType + ']');
		}
	}

	var numMains = 0;
	simplifiedFields.forEach(field => {
		if (!field.name) {
			errors.push('field without a name');
			return;
		}
		if (!field.fieldType) {
			errors.push('field [' + field.name + '] is missing the type attribute');
			return;
		}
		numMains += field.main ? 1 : 0;
		if (field.main && field.fieldType != 'string')
			errors.push('field [' + field.name + '] is marked as main, but is not of type string');
		if (field.default && !validateFieldValue(field, field.default))
			errors.push('field [' + field.name + '] with type [' + field.fieldType + '] has an invalid default value of [' + field.default + ']');
	});
	if (numMains > 1)
		errors.push('Template can only have one field with the "main" attribute');
	if (numMains == 0)
		errors.push('Template must have at least one field with the "main" attribute');

	if (errors.length > 0) {
		throw new Error('Encountered one or more validation errors saving template [' + template.name + ']: '.concat(errors));
	}

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