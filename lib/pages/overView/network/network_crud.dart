import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkCRUD {
  Future<bool> addsmPostDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_sm_post_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "user_id": data[1],
        "post_type": data[2],
        "comment": data[3],
        "compare_date": data[4]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmPostImageDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_sm_post_images'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(
          <String, dynamic>{"imagelist_id": data[0], "image": data[1]}),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmPostVideoDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_sm_post_videos'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "videolistt_id": data[0],
        "video": data[1],
        "thumbnail": data[2]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmPostUserTaggedDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_sm_post_users_tagged'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(
          <String, dynamic>{"usertaglist_id": data[0], "user_id": data[1]}),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmPostMoodDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_sm_mood_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "user_id": data[1],
        "message": data[2],
        "user_mood": data[3],
        "imagelist_id": data[4],
        "videolist_id": data[5],
        "usertaglist_id": data[6],
        "privacy": data[7],
        "like_count": data[8],
        "comment_count": data[9],
        "view_count": data[10],
        "impression_count": data[11],
        "compare_date": data[12]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmCausePostDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_user_sm_cause_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "user_id": data[1],
        "message": data[2],
        "datetime": data[3],
        "address": data[4],
        "date": data[5],
        "eventcategory": data[6],
        "eventname": data[7],
        "eventsubcategory": data[8],
        "eventtype": data[9],
        "feedtype": data[10],
        "frequency": data[11],
        "from_": data[12],
        "from24hrs": data[13],
        "fromtime": data[14],
        "grade": data[15],
        "latitude": data[16],
        "longitude": data[17],
        "meetingid": data[18],
        "subject": data[19],
        "theme": data[20],
        "themeindex": data[21],
        "to_": data[22],
        "to24hrs": data[23],
        "totime": data[24],
        "imagelist_id": data[25],
        "videolist_id": data[26],
        "usertaglist_id": data[27],
        "privacy": data[28],
        "like_count": data[29],
        "comment_count": data[30],
        "view_count": data[31],
        "impression_count": data[32],
        "compare_date": data[33]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmBusinessIdeasPostDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_user_sm_bideas_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "user_id": data[1],
        "content": data[2],
        "theme": data[3],
        "title": data[4],
        "identification": data[5],
        "solution": data[6],
        "target": data[7],
        "competitors": data[8],
        "swot": data[9],
        "strategy": data[10],
        "funds": data[11],
        "documentlist_id": data[12],
        "videolist_id": data[13],
        "memberlist_id": data[14],
        "privacy": data[15],
        "like_count": data[16],
        "comment_count": data[17],
        "view_count": data[18],
        "impression_count": data[19],
        "compare_date": data[20]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmProjectDiscussPostDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_user_sm_project_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "user_id": data[1],
        "content": data[2],
        "theme": data[3],
        "title": data[4],
        "grade": data[5],
        "subject": data[6],
        "topic": data[7],
        "requirements": data[8],
        "purchasedfrom": data[9],
        "procedure_": data[10],
        "theory": data[11],
        "findings": data[12],
        "similartheory": data[13],
        "projectvideourl": data[14],
        "reqvideourl": data[15],
        "summarydoc": data[16],
        "otherdoc": data[17],
        "memberlist_id": data[18],
        "privacy": data[19],
        "like_count": data[20],
        "comment_count": data[21],
        "view_count": data[22],
        "impression_count": data[23],
        "compare_date": data[24]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmBlogPostDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_sm_blog_post_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "user_id": data[1],
        "blogger_name": data[2],
        "blog_title": data[3],
        "blog_intro": data[4],
        "blog_content": data[5],
        "like_count": data[6],
        "comment_count": data[7],
        "view_count": data[8],
        "impression_count": data[9],
        "compare_date": data[10]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmBlogCategoryDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_sm_blog_category_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "blog_category": data[1],
        "compare_date": data[2]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmUploadsDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_user_sm_uploads_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "upload_id": data[0],
        "upload_type": data[1],
        "user_id": data[2],
        "school_name": data[3],
        "exam_name": data[4],
        "grade": data[5],
        "subject": data[6],
        "chapter": data[7],
        "topic": data[8],
        "term": data[9],
        "year": data[10],
        "tags": data[11],
        "description": data[12],
        "compare_date": data[13]
      }),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmUploadFilesDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_sm_upload_file_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "upload_id": data[0],
        "file_url": data[1],
        "file_ext": data[2],
        "file_name": data[3]
      }),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmCommentPostDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_user_sm_comment_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "comment_id": data[0],
        "post_id": data[1],
        "user_id": data[2],
        "comment": data[3],
        "imagelist_id": data[4],
        "videolist_id": data[5],
        "usertaglist_id": data[6],
        "like_count": data[7],
        "reply_count": data[8],
        "compare_date": data[9]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addUserAchievementDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_user_achievement_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "achievement_id": data[0],
        "user_id": data[1],
        "scorecard_school_name": data[2],
        "scorecard_board_name": data[3],
        "ach_description": data[4],
        "ach_image_url": data[5],
        "ach_title": data[6],
        "scorecard_grade": data[7],
        "scorecard_total_score": data[8],
        "ach_type": data[9],
        "compare_date": data[10]
      }),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addUserScorecardDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_user_scorecard_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "achievement_id": data[0],
        "user_id": data[1],
        "subject": data[2],
        "marks": data[3]
      }),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateUserPrivacyDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_update_user_privacy'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": data[0],
        "address": data[1],
        "ambition": data[2],
        "dreamvacations": data[3],
        "email": data[4],
        "friends": data[5],
        "mygroups": data[6],
        "hobbies": data[7],
        "library": data[8],
        "mobileno": data[9],
        "novels": data[10],
        "placesvisited": data[11],
        "schooladdress": data[12],
        "scorecards": data[13],
        "uploads": data[14],
        "weakness": data[15]
      }),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addSmPostLikeDetailsAdvancedLogic(List data) async {
    print(data);
//Post_type = Mood, blog, cause|teachunprevilagedKids, projectdiscuss, businessideas, reply, comment, shared*

    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_sm_reaction_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "do_post": data[0],
        "post_id": data[1],
        "user_id": data[2],
        "post_type": data[3],
        "like_type": data[4],
        "like_count": data[5],
        "comment_count": data[6],
        "view_count": data[7],
        "impression_count": data[8],
        "reply_count": data[9],
      }),
    );
    print(response.statusCode);
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addSmPostLikeDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_sm_like_post_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "user_id": data[1],
        "like_type": data[2]
      }),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateSmPostLikeDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_update_sm_like_post_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "like_type": data[0],
        "post_id": data[1],
        "user_id": data[2]
      }),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteSmPostLikeDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_delete_sm_like_post_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body:
          jsonEncode(<String, dynamic>{"post_id": data[0], "user_id": data[1]}),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateSmMoodPostLikeDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_update_sm_mood_post_count_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "user_id": data[1],
        "like_count": int.parse(data[2]),
        "comment_count": int.parse(data[3]),
        "view_count": int.parse(data[4]),
        "impression_count": int.parse(data[5])
      }),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateSmCausePostLikeDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_update_user_sm_cause_count_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "user_id": data[1],
        "like_count": int.parse(data[2]),
        "comment_count": int.parse(data[3]),
        "view_count": int.parse(data[4]),
        "impression_count": int.parse(data[5])
      }),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateSmIdeasPostLikeDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_update_user_sm_b_ideas_count_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "user_id": data[1],
        "like_count": int.parse(data[2]),
        "comment_count": int.parse(data[3]),
        "view_count": int.parse(data[4]),
        "impression_count": int.parse(data[5])
      }),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateSmProjectPostLikeDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_update_user_sm_project_count_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "user_id": data[1],
        "like_count": int.parse(data[2]),
        "comment_count": int.parse(data[3]),
        "view_count": int.parse(data[4]),
        "impression_count": int.parse(data[5])
      }),
    );
    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addsmReplyPostDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_user_sm_reply_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "reply_id": data[0],
        "comment_id": data[1],
        "post_id": data[2],
        "user_id": data[3],
        "reply": data[4],
        "imagelist_id": data[5],
        "videolist_id": data[6],
        "usertaglist_id": data[7],
        "like_count": data[8],
        "compare_date": data[9]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }
}
