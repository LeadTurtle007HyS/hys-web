

// class CommentReplyModel {

//   int like_count ;
//   String city;
//   String comment_id;
//   String compare_date;
//   String first_name;
//   String gender;
//   int grade;
//   List<dynamic> image_list;
//   String imagelist_id;
//   String last_name;
//   String like_type;
//   String post_id;
//   String profilepic;
//   String reply;
//   String reply_id;
//   String school_name;
//   List<dynamic> tag_list;
//   String user_id;
//   String usertaglist_id;
//   List<dynamic> video_list;
//   String videolist_id;


//   CommentReplyModel(this.like_count, this.city, this.comment_id,
//       this.compare_date, this.first_name, this.gender, this.grade,
//       this.image_list, this.imagelist_id, this.last_name,this.like_type, this.post_id,
//       this.profilepic, this.reply, this.reply_id, this.school_name,
//       this.tag_list, this.user_id, this.usertaglist_id, this.video_list,
//       this.videolist_id);

//   CommentReplyModel.fromJson(Map<String, dynamic> json) {
//     like_count=json['like_count'];
//     city = json['city'];
//     comment_id = json['comment_id'];
//     compare_date=json['compare_date'];
//     first_name=json['first_name'];
//     gender = json['gender'];
//     grade=json['grade'];
//     image_list=json['image_list'];
//     imagelist_id = json['imagelist_id'];
//     last_name = json['last_name'];
//     like_type=json['like_type'];
//     post_id=json['post_id'];
//     profilepic=json['profilepic'];
//     reply = json['reply'];
//     reply_id = json['reply_id'];
//     school_name=json['school_name'];
//     tag_list=json['tag_list'];
//     user_id = json['user_id'];
//     usertaglist_id = json['usertaglist_id'];
//     video_list=json['video_list'];
//     videolist_id=json['videolist_id'];

//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['like_count']=this.like_count;
//     data['city'] = this.city;
//     data['comment_id'] = this.comment_id;
//     data['compare_date']=compare_date;
//     data['first_name']=this.first_name;
//     data['gender'] = this.gender;
//     data['grade'] = this.grade;
//     data['image_list']=this.image_list;
//     data['imagelist_id']=this.imagelist_id;
//     data['last_name'] = this.last_name;
//     data['like_type'] =this.like_type;
//     data['post_id'] = this.post_id;
//     data['profilepic']=profilepic;
//     data['reply']=this.reply;
//     data['reply_id'] = this.reply_id;
//     data['school_name'] = this.school_name;
//     data['tag_list']=tag_list;
//     data['user_id']=this.user_id;
//     data['usertaglist_id'] = this.usertaglist_id;
//     data['video_list'] = this.video_list;
//     data['videolist_id']=videolist_id;
//     return data;
//   }

// }

