class PreferredLanguages {
  String? createdate;
  String? preferred_lang;
  String? user_id;

  PreferredLanguages(this.createdate, this.preferred_lang, this.user_id);

  PreferredLanguages.fromJson(Map<String, dynamic> json) {
    this.createdate = json['createdate'];
    preferred_lang = json['preferred_lang'];
    user_id = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdate'] = createdate;
    data['preferred_lang'] = preferred_lang;
    data['user_id'] = user_id;
    return data;
  }
}
