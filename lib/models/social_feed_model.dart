import 'dart:convert';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class SocialFeedModel extends HiveObject {
  @HiveField(0)
  String? address;
  @HiveField(1)
  String? blog_content;
  @HiveField(2)
  String? blog_intro;
  @HiveField(3)
  String? blog_title;
  @HiveField(4)
  String? blogger_name;
  @HiveField(5)
  String? city;
  @HiveField(6)
  int? comment_count;
  @HiveField(7)
  String? compare_date;
  @HiveField(8)
  String? competitors;
  @HiveField(9)
  String? content;
  @HiveField(10)
  String? createdate;
  @HiveField(11)
  String? date;
  @HiveField(12)
  String? datetime;
  @HiveField(13)
  String? eventcategory;
  @HiveField(14)
  String? eventname;
  @HiveField(15)
  String? eventsubcategory;
  @HiveField(16)
  String? eventtype;
  @HiveField(17)
  String? feedtype;
  @HiveField(18)
  String? findings;
  @HiveField(19)
  String? first_name;
  @HiveField(20)
  String? frequency;
  @HiveField(21)
  String? from_;
  @HiveField(22)
  String? fromtime;
  @HiveField(23)
  String? funds;
  @HiveField(24)
  String? gender;
  @HiveField(25)
  String? grade;
  @HiveField(26)
  String? identification;
  @HiveField(27)
  List<dynamic>? image_list;
  @HiveField(28)
  String? image_url;
  @HiveField(29)
  String? imagelist_id;
  @HiveField(30)
  int? impression_count;
  @HiveField(31)
  String? last_name;
  @HiveField(32)
  String? latitude;
  @HiveField(33)
  int? like_count;
  @HiveField(34)
  String? like_type;
  @HiveField(35)
  String? longitude;
  @HiveField(36)
  String? meetingid;
  @HiveField(37)
  String? message;
  @HiveField(38)
  String? otherdoc;
  @HiveField(39)
  String? personal_bio;
  @HiveField(40)
  String? post_id;
  @HiveField(41)
  String? post_type;
  @HiveField(42)
  String? privacy;
  @HiveField(43)
  String? procedure_;
  @HiveField(44)
  String? profilepic;
  @HiveField(45)
  String? projectvideourl;
  @HiveField(46)
  String? purchasedfrom;
  @HiveField(47)
  int? reply_count;
  @HiveField(48)
  String? requirements;
  @HiveField(49)
  String? reqvideourl;
  @HiveField(50)
  String? school_name;
  @HiveField(51)
  String? similartheory;
  @HiveField(52)
  String? solution;
  @HiveField(53)
  String? strategy;
  @HiveField(54)
  String? subject;
  @HiveField(55)
  String? summarydoc;
  @HiveField(56)
  String? swot;
  @HiveField(57)
  List<dynamic>? tag_list;
  @HiveField(58)
  String? target;
  @HiveField(59)
  String? theme;
  @HiveField(60)
  String? themeindex;
  @HiveField(61)
  String? theory;
  @HiveField(62)
  String? title;
  @HiveField(63)
  String? to24hrs;
  @HiveField(64)
  String? to_;
  @HiveField(65)
  String? topic;
  @HiveField(66)
  String? totime;
  @HiveField(67)
  String? user_id;
  @HiveField(68)
  String? user_mood;
  @HiveField(69)
  String? usertaglist_id;
  @HiveField(70)
  List<dynamic>? video_list;
  @HiveField(71)
  String? videolist_id;
  @HiveField(72)
  int? view_count;
  @HiveField(73)
  List<dynamic>? document_list;
  @HiveField(74)
  String? documentlist_id;
  @HiveField(75)
  String? memberlist_id;

  SocialFeedModel(
      this.address,
      this.blog_content,
      this.blog_intro,
      this.blog_title,
      this.blogger_name,
      this.city,
      this.comment_count,
      this.compare_date,
      this.competitors,
      this.content,
      this.createdate,
      this.date,
      this.datetime,
      this.eventcategory,
      this.eventname,
      this.eventsubcategory,
      this.eventtype,
      this.feedtype,
      this.findings,
      this.first_name,
      this.frequency,
      this.from_,
      this.fromtime,
      this.funds,
      this.gender,
      this.grade,
      this.identification,
      this.image_list,
      this.image_url,
      this.imagelist_id,
      this.impression_count,
      this.last_name,
      this.latitude,
      this.like_count,
      this.like_type,
      this.longitude,
      this.meetingid,
      this.message,
      this.otherdoc,
      this.personal_bio,
      this.post_id,
      this.post_type,
      this.privacy,
      this.procedure_,
      this.profilepic,
      this.projectvideourl,
      this.purchasedfrom,
      this.reply_count,
      this.requirements,
      this.reqvideourl,
      this.school_name,
      this.similartheory,
      this.solution,
      this.strategy,
      this.subject,
      this.summarydoc,
      this.swot,
      this.tag_list,
      this.target,
      this.theme,
      this.themeindex,
      this.theory,
      this.title,
      this.to24hrs,
      this.to_,
      this.topic,
      this.totime,
      this.user_id,
      this.user_mood,
      this.usertaglist_id,
      this.video_list,
      this.videolist_id,
      this.view_count,
      this.document_list,
      this.documentlist_id,
      this.memberlist_id);

  SocialFeedModel.fromJson(Map<String, dynamic> data) {
    address = data['address'];
    blog_content = data['blog_content'];
    blog_intro = data['blog_intro'];
    blog_title = data['blog_title'];
    blogger_name = data['blogger_name'];
    city = data['city'];
    comment_count = data['comment_count'];
    compare_date = data['compare_date'];
    competitors = data['competitors'];
    content = data['content'];
    createdate = data['createdate'];
    date = data['date'];
    datetime = data['datetime'];
    eventcategory = data['eventcategory'];
    eventname = data['eventname'];
    eventsubcategory = data['eventsubcategory'];
    eventtype = data['eventtype'];
    feedtype = data['feedtype'];
    findings = data['findings'];
    first_name = data['first_name'];
    frequency = data['frequency'];
    from_ = data['from_'];
    fromtime = data['fromtime'];
    funds = data['funds'];
    gender = data['gender'];
    grade = data['grade'].toString();
    identification = data['identification'];
    image_list = data['image_list'] != null &&
            data['image_list'].runtimeType.toString() == "String"
        ? json.decode(data['image_list']) as List<dynamic>
        : data['image_list'] != null
            ? data['image_list']
            : <dynamic>[];
    image_url = data['image_url'];
    imagelist_id = data['imagelist_id'];
    impression_count = data['impression_count'];
    last_name = data['last_name'];
    latitude = data['latitude'];
    like_count = data['like_count'];
    like_type = data['like_type'];
    longitude = data['longitude'];
    meetingid = data['meetingid'];
    message = data['message'];
    otherdoc = data['otherdoc'];
    personal_bio = data['personal_bio'];
    post_id = data['post_id'];
    post_type = data['post_type'];
    privacy = data['privacy'];
    procedure_ = data['procedure_'];
    profilepic = data['profilepic'];
    projectvideourl = data['projectvideourl'];
    purchasedfrom = data['purchasedfrom'];
    reply_count = data['reply_count'];
    requirements = data['requirements'];
    reqvideourl = data['reqvideourl'];
    school_name = data['school_name'];
    similartheory = data['similartheory'];
    solution = data['solution'];
    strategy = data['strategy'];
    subject = data['subject'];
    summarydoc = data['summarydoc'];
    swot = data['swot'];
    tag_list = data['tag_list'] != null &&
            data['tag_list'].runtimeType.toString() == "String"
        ? json.decode(data['tag_list']) as List<dynamic>
        : data['tag_list'] != null
            ? data['tag_list']
            : <dynamic>[];
    target = data['target'];
    theme = data['theme'];
    themeindex = data['themeindex'].toString();
    theory = data['theory'];
    title = data['title'];
    to24hrs = data['to24hrs'];
    to_ = data['to_'];
    topic = data['topic'];
    totime = data['totime'];
    user_id = data['user_id'];
    user_mood = data['user_mood'];
    usertaglist_id = data['usertaglist_id'];
    video_list = data['video_list'] != null &&
            data['video_list'].runtimeType.toString() == "String"
        ? json.decode(data['video_list']) as List<dynamic>
        : data['video_list'] != null
            ? data['video_list']
            : <dynamic>[];
    videolist_id = data['videolist_id'];
    view_count = data['view_count'];
    this.document_list = data['document_list'] != null &&
            data['document_list'].runtimeType.toString() == "String"
        ? json.decode(data['document_list']) as List<dynamic>
        : data['document_list'] != null
            ? data['document_list']
            : <dynamic>[];
    this.documentlist_id = data['documentlist_id'];
    this.memberlist_id = data['memberlist_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['blog_content'] = this.blog_content;
    data['blog_intro'] = this.blog_intro;
    data['blog_title'] = blog_title;
    data['blogger_name'] = this.blogger_name;
    data['city'] = this.city;
    data['comment_count'] = this.comment_count;
    data['compare_date'] = compare_date;
    data['competitors'] = this.competitors;
    data['content'] = this.content;
    data['createdate'] = this.createdate;
    data['date'] = date;
    data['datetime'] = this.datetime;
    data['eventcategory'] = this.eventcategory;
    data['eventname'] = this.eventname;
    data['eventsubcategory'] = eventsubcategory;
    data['eventtype'] = this.eventtype;
    data['feedtype'] = this.feedtype;
    data['findings'] = this.findings;
    data['first_name'] = first_name;
    data['frequency'] = this.frequency;
    data['from_'] = this.from_;
    data['fromtime'] = this.fromtime;
    data['funds'] = this.funds;
    data['gender'] = this.gender;
    data['grade'] = this.grade;
    data['identification'] = this.identification;
    data['image_list'] = image_list;

    data['image_url'] = this.image_url;
    data['imagelist_id'] = this.imagelist_id;
    data['impression_count'] = this.impression_count;
    data['last_name'] = last_name;

    data['latitude'] = this.latitude;
    data['like_count'] = this.like_count;
    data['like_type'] = this.like_type;
    data['longitude'] = this.longitude;
    data['meetingid'] = meetingid;

    data['message'] = this.message;
    data['otherdoc'] = this.otherdoc;
    data['personal_bio'] = this.personal_bio;
    data['post_id'] = post_id;
    data['post_type'] = this.post_type;
    data['privacy'] = this.privacy;
    data['procedure_'] = this.procedure_;
    data['profilepic'] = profilepic;
    data['projectvideourl'] = this.projectvideourl;
    data['purchasedfrom'] = this.purchasedfrom;
    data['reply_count'] = this.reply_count;
    data['requirements'] = this.requirements;
    data['reqvideourl'] = this.reqvideourl;
    data['school_name'] = this.school_name;
    data['similartheory'] = this.similartheory;
    data['solution'] = this.solution;
    data['strategy'] = strategy;

    data['subject'] = this.subject;
    data['summarydoc'] = this.summarydoc;
    data['swot'] = this.swot;
    data['tag_list'] = tag_list;
    data['target'] = this.target;
    data['theme'] = this.theme;
    data['themeindex'] = this.themeindex;
    data['theory'] = theory;
    data['title'] = this.title;
    data['to24hrs'] = this.to24hrs;
    data['to_'] = this.to_;
    data['topic'] = this.topic;
    data['totime'] = this.totime;
    data['user_id'] = this.user_id;
    data['user_mood'] = this.user_mood;
    data['usertaglist_id'] = this.usertaglist_id;
    data['video_list'] = this.video_list;
    data['videolist_id'] = this.videolist_id;
    data['view_count'] = this.view_count;
    data['documentlist_id'] = this.documentlist_id;
    data['document_list'] = this.document_list;
    data['memberlist_id'] = this.memberlist_id;

    return data;
  }
}
