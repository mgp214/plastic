enum TemplateChangeType {
  Deleted,
  Added,
  NameChanged,
  DefaultValueChanged,
  TypeChanged
}

class TemplateChange {
  final TemplateChangeType changeType;
  final String fieldId;
  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;

  TemplateChange(
      {this.changeType,
      this.fieldId,
      this.oldValue,
      this.newValue,
      this.fieldName});
}