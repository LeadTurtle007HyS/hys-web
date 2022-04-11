import 'dart:convert';
import 'package:http/http.dart' as http;

class DataLoadCRUD {
  Future<bool> postUserQuestionData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_user_question_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "question_id": data[0],
        "user_id": data[1],
        "answer_count": data[2],
        "answer_preference": data[3],
        "audio_reference": data[4],
        "call_date": data[5],
        "call_end_time": data[6],
        "call_now": data[7],
        "call_preferred_lang": data[8],
        "call_start_time": data[9],
        "answer_credit": data[10],
        "question_credit": data[11],
        "view_count": data[12],
        "examlikelyhood_count": data[13],
        "grade": data[14],
        "like_count": data[15],
        "note_reference": data[16],
        "ocr_image": data[17],
        "compare_date": data[18],
        "question": data[19],
        "question_type": data[20],
        "is_identity_visible": data[21],
        "subject": data[22],
        "topic": data[23],
        "text_reference": data[24],
        "toughness_count": data[25],
        "video_reference": data[26],
        "impression_count": data[27]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> postUsertaggedInQuestionData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_add_users_tagged_in_question'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(
          <String, dynamic>{"question_id": data[0], "user_id": data[1]}),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {}
  }

  Future<bool> postUserAnswerData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_post_answer_on_question_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "answer_id": data[0],
        "question_id": data[1],
        "user_id": data[2],
        "comment_count": data[3],
        "audio_reference": data[4],
        "like_count": data[5],
        "upvote_count": data[6],
        "downvote_count": data[7],
        "note_reference": data[8],
        "image": data[9],
        "compare_date": data[10],
        "answer": data[11],
        "answer_type": data[12],
        "text_reference": data[13],
        "video_reference": data[14]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateAnswerCountData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_update_counts_in_answer_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "answer_id": data[0],
        "user_id": data[1],
        "comment_count": data[2],
        "like_count": data[3],
        "upvote_count": data[4],
        "downvote_count": data[5]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateAnswerCommentCountData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_update_counts_in_answer_comment_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "comment_id": data[0],
        "user_id": data[1],
        "like_count": data[2],
        "reply_count": data[3]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateAnswerReplyCountData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_update_counts_in_answer_reply_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "reply_id": data[0],
        "user_id": data[1],
        "like_count": data[2]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> postUsertaggedInAnswerData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_users_tagged_in_answer'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(
          <String, dynamic>{"answer_id": data[0], "user_id": data[1]}),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {}
  }

  Future<bool> postUserAnswerCommentData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_users_answer_comment'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "comment_id": data[0],
        "answer_id": data[1],
        "question_id": data[2],
        "user_id": data[3],
        "like_count": data[4],
        "reply_count": data[5],
        "comment": data[6],
        "comment_type": data[7],
        "note_reference": data[8],
        "audio_reference": data[9],
        "text_reference": data[10],
        "video_reference": data[11],
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

  Future<bool> postUserAnswerReplyData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_users_answer_reply'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "reply_id": data[0],
        "comment_id": data[1],
        "answer_id": data[2],
        "question_id": data[3],
        "user_id": data[4],
        "reply": data[5],
        "reply_type": data[6],
        "like_count": data[7],
        "compare_date": data[8]
      }),
    );
    print(response.statusCode);
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addQuestionSaved(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_question_saved_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": data[0],
        "question_id": data[1],
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

  Future<bool> deleteQuestionSaved(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_delete_question_saved_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(
          <String, dynamic>{"user_id": data[0], "question_id": data[1]}),
    );
    print(response.statusCode);
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addQuestionBookmarked(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_add_question_bookmarked_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": data[0],
        "question_id": data[1],
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

  Future<bool> deleteQuestionBookmarked(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_delete_question_bookmarked_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(
          <String, dynamic>{"user_id": data[0], "question_id": data[1]}),
    );
    print(response.statusCode);
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }
}
