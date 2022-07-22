class UserPersonalData {
  String? userid;
  String? address;
  String? ambition;
  String? city;
  String? comparedate;
  String? createdate;
  String? dob;
  String? dreamvacations;
  String? email;
  String? firstname;
  String? gender;
  String? hobbies;
  String? lastname;
  String? mobile;
  String? novelsread;
  String? placesvisited;
  List<dynamic>? preferedlanguage;
  String? profilepic;
  String? state;

  UserPersonalData(
      {this.userid,
      this.address,
      this.ambition,
      this.city,
      this.comparedate,
      this.createdate,
      this.dob,
      this.dreamvacations,
      this.email,
      this.firstname,
      this.gender,
      this.hobbies,
      this.lastname,
      this.mobile,
      this.novelsread,
      this.placesvisited,
      this.preferedlanguage,
      this.profilepic,
      this.state});

  UserPersonalData.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    address = json['address'];
    ambition = json['ambition'];
    city = json['city'];
    comparedate = json['comparedate'];
    createdate = json['createdate'];
    dob = json['dob'];
    dreamvacations = json['dreamvacations'];
    email = json['email'];
    firstname = json['firstname'];
    gender = json['gender'];
    hobbies = json['hobbies'];
    lastname = json['lastname'];
    mobile = json['mobile'];
    novelsread = json['novelsread'];
    placesvisited = json['placesvisited'];
    preferedlanguage = json['preferedlanguage'];
    profilepic = json['profilepic'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userid'] = this.userid;
    data['address'] = this.address;
    data['ambition'] = this.ambition;
    data['city'] = this.city;
    data['comparedate'] = this.comparedate;
    data['createdate'] = this.createdate;
    data['dob'] = this.dob;
    data['dreamvacations'] = this.dreamvacations;

    data['email'] = this.email;
    data['firstname'] = this.firstname;
    data['hobbies'] = this.hobbies;
    data['lastname'] = this.lastname;
    data['mobile'] = this.mobile;
    data['novelsread'] = this.novelsread;
    data['placesvisited'] = this.placesvisited;

    data['preferedlanguage'] = this.preferedlanguage;
    data['profilepic'] = this.profilepic;
    data['state'] = this.state;

    return data;
  }
}
