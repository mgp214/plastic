enum FieldType {
  STRING,
  INT,
  DOUBLE,
  ENUM,
  BOOL,
}

class Template {
  List<TemplateField> fields;
  String sId;
  String userId;
  String name;
  int iV;

  Template({this.fields, this.sId, this.userId, this.name, this.iV});

  Template.fromJson(Map<String, dynamic> json) {
    if (json['fields'] != null) {
      fields = new List<TemplateField>();
      json['fields'].forEach((v) {
        fields.add(new TemplateField.fromJson(v));
      });
    }
    sId = json['_id'];
    userId = json['userId'];
    name = json['name'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fields != null) {
      data['fields'] = this.fields.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['__v'] = this.iV;
    return data;
  }
}

class TemplateField {
  String name;
  FieldType type;

  TemplateField({this.name, this.type});

  TemplateField.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = FieldType.values
        .singleWhere((ft) => ft.toString() == json['fieldType']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['fieldType'] = type.toString();
    return data;
  }
}
