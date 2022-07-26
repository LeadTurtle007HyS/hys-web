import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;

import '../../constants/constants.dart';

String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

class AnswerCRUD {
  Future<bool> postUserAnswerData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(Constant.BASE_URL + 'post_answer_on_question_details'),
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
    final http.Response response = await http.post(
      Uri.parse(Constant.BASE_URL + 'update_counts_in_answer_details'),
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

  Future<bool> updateAnswerReaction(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(Constant.BASE_URL + 'update_answer_reaction'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "answer_id": data[0],
        "user_id": data[1],
        "reaction": data[2],
        "reaction_type": data[3]
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
      Uri.parse(Constant.BASE_URL + 'update_counts_in_answer_comment_details'),
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

  Future<bool> updateAnswerCommentReaction(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(Constant.BASE_URL + 'update_answer_comment_reaction'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "comment_id": data[0],
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

  Future<bool> updateAnswerReplyCountData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(Constant.BASE_URL + 'update_counts_in_answer_reply_details'),
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

  Future<bool> updateViewCountData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(Constant.BASE_URL + 'update_post_view_count'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": data[0],
        "post_type": data[1],
        "user_id": data[2],
        "compare_date": data[3]
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
      Uri.parse(Constant.BASE_URL + 'add_users_tagged_in_answer'),
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
      Uri.parse(Constant.BASE_URL + 'add_users_answer_comment'),
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
        "compare_date": data[12],
        "image": data[13]
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
      Uri.parse(Constant.BASE_URL + 'add_users_answer_reply'),
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
        "compare_date": data[8],
        "image": data[9]
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
