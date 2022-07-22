import 'package:HyS/models/preferred_languages_model.dart';
import 'package:HyS/models/strength_model.dart';

class UserAllDataModel {
  String? userid;
  String? address;
  List<dynamic>? ambition;
  String? city;
  String? comparedate;
  String? createdate;
  String? dob;
  List<dynamic>? dreamvacations;
  String? email;
  String? firstname;
  String? gender;
  List<dynamic>? hobbies;
  String? lastname;
  String? mobile;
  List<dynamic>? novels_read;
  List<dynamic>? place_visited;
  List<PreferredLanguages>? preferedlanguage;
  String? profilepic;
  String? state;
  String? board;
  int? grade;
  String? school_address;
  String? school_city;
  String? school_name;
  String? school_state;
  String? school_street;
  String? stream;
  String? street;
  String? user_dob;
  List<StrengthModel>? strength;
  List<StrengthModel>? weakness;

  UserAllDataModel(
      {required this.userid,
      required this.address,
      required this.ambition,
      required this.city,
      required this.comparedate,
      required this.createdate,
      required this.dob,
      required this.dreamvacations,
      required this.email,
      required this.firstname,
      required this.gender,
      required this.hobbies,
      required this.lastname,
      required this.mobile,
      required this.novels_read,
      required this.place_visited,
      required this.preferedlanguage,
      required this.profilepic,
      required this.state,
      required this.board,
      required this.grade,
      required this.school_address,
      required this.school_city,
      required this.school_name,
      required this.school_state,
      required this.school_street,
      required this.stream,
      required this.street,
      required this.user_dob,
      required this.strength,
      required this.weakness});

  UserAllDataModel.fromJson(Map<String, dynamic> json) {
    var weaknessJson = json['weakness'] as List;
    List<StrengthModel> weaknessList = weaknessJson != null
        ? weaknessJson
            .map((tagJson) => StrengthModel.fromJson(tagJson))
            .toList()
        : <StrengthModel>[];
    var strengthJson = json['strength'] as List;
    List<StrengthModel> strengthList = strengthJson != null
        ? strengthJson
            .map((tagJson) => StrengthModel.fromJson(tagJson))
            .toList()
        : <StrengthModel>[];
    var preferredLanJson = json['preferred_languages'] as List;
    List<PreferredLanguages> preferredLangList = preferredLanJson != null
        ? preferredLanJson
            .map((tagJson) => PreferredLanguages.fromJson(tagJson))
            .toList()
        : <PreferredLanguages>[];

    userid = json['user_id'];
    address = json['address'];
    ambition = json['ambition'];
    city = json['city'];
    comparedate = json['comparedate'];
    createdate = json['createdate'];
    dob = json['dob'];
    dreamvacations = json['dream_vacations'];
    email = json['email_id'];
    firstname = json['first_name'];
    gender = json['gender'];
    hobbies = json['hobbies'];
    lastname = json['last_name'];
    mobile = json['mobile_no'];
    novels_read = json['novels_read'];
    place_visited = json['place_visited'];
    preferedlanguage = preferredLangList;
    profilepic = json['profilepic'];
    state = json['state'];
    board = json['board'];
    grade = json['grade'];
    school_address = json['sd.address'];
    school_city = json['sd.city'];
    school_name = json['school_name'];
    school_state = json['sd.state'];
    school_street = json['sd.street'];
    stream = json['stream'];
    street = json['street'];
    user_dob = json['user_dob'];
    strength = strengthList;
    weakness = weaknessList;
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
    data['novelsread'] = this.novels_read;
    data['placesvisited'] = this.place_visited;
    data['preferedlanguage'] = this.preferedlanguage;
    data['profilepic'] = this.profilepic;
    data['state'] = this.state;
    return data;
  }
}
