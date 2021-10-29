const mongoose = require('mongoose');

const thingFieldSchema = mongoose.Schema({
	'name': String,
	'value': mongoose.Schema.Types.Mixed,
	'fieldType': String,
});


const thingSchema = mongoose.Schema({
	userId: {
		type: mongoose.Types.ObjectId,
		required: true,
	},
	templateId: {
		type: mongoose.Types.ObjectId,
		required: true,
	},
	fields: [thingFieldSchema]
});

/*
exmaple:
{
	userId: "SOME_ID",
	templateId: "SOME_OTHER_ID",
	fields: [
		{
			"name": "field A",
			"value": "some value"
		},
		{
			"name": "field B",
			"value": 123.45
		},
	]
}
*/

thingSchema.pre('save', async function (next) {
	//	const thing = this;
	//	const template = Template.findById(this.templateId);

	//TODO: validate thing against template
	//TODO: validate no duplicate field names

	next();
});

thingSchema.statics.findAllByUser = async (userId) => {
	const things = await Thing.find({ 'userId': userId });
	return things;
};

thingSchema.statics.findById = async (thingId) => {

	const thing = await Thing.findById(thingId);
	if (thing) {
		return thing;
	}
	throw new Error(`Thing with id: ${thingId} not found.`);
};

thingSchema.statics.findByTemplate = async (templateId) => {
	const things = await Thing.find({ 'templateId': templateId });
	return things;
};

thingSchema.statics.findWithField = async (userId, fieldName) => {
	const things = await Thing.find({ 'userId': userId, 'fields.name': fieldName });
	return things;
};

const Thing = mongoose.model('Thing', thingSchema);

module.exports = Thing;