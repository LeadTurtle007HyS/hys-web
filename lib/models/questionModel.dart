class Questions {
  int answer_count;
  final int answer_credit;
  final String answer_preference;
  final String audio_reference;
  final String call_date;
  final String call_end_time;
  final String call_now;
  final String call_preferred_lang;
  final String call_start_time;
  final String city;
  final String compare_date;
  int examlikelyhood_count;
  final String first_name;
  final int grade;
  int impression_count;
  String isExamlikelyhoodButtonExpanded;
  String isLikeButtonExpanded;
  String isToughnessButtonExpanded;
  final String is_identity_visible;
  final String last_name;
  int like_count;
  final String note_reference;
  final String ocr_image;
  final String profilepic;
  final String question;
  final int question_credit;
  final String question_id;
  final String question_type;
  final String school_name;
  final String subject;
  final List tag_list;
  final List<SharedQuestion> shared_question_details;
  final String text_reference;
  final String topic;
  int toughness_count;
  final String user_id;
  final String video_reference;
  int view_count;
  String like_type;
  String examlikelyhood_type;
  String toughness_type;
  String is_save;
  String is_bookmark;
  final int high_toughness_count;
  final int medium_toughness_count;
  final int low_toughness_count;
  final int high_examlike_count;
  final int medium_examlike_count;
  final int low_examlike_count;

  Questions(
      {required this.answer_count,
      required this.answer_credit,
      required this.answer_preference,
      required this.audio_reference,
      required this.call_date,
      required this.call_end_time,
      required this.call_now,
      required this.call_preferred_lang,
      required this.call_start_time,
      required this.city,
      required this.compare_date,
      required this.examlikelyhood_count,
      required this.first_name,
      required this.grade,
      required this.impression_count,
      required this.isExamlikelyhoodButtonExpanded,
      required this.isLikeButtonExpanded,
      required this.isToughnessButtonExpanded,
      required this.is_identity_visible,
      required this.last_name,
      required this.like_count,
      required this.note_reference,
      required this.ocr_image,
      required this.profilepic,
      required this.question,
      required this.question_credit,
      required this.question_id,
      required this.question_type,
      required this.school_name,
      required this.subject,
      required this.tag_list,
      required this.shared_question_details,
      required this.text_reference,
      required this.topic,
      required this.toughness_count,
      required this.user_id,
      required this.video_reference,
      required this.view_count,
      required this.like_type,
      required this.examlikelyhood_type,
      required this.toughness_type,
      required this.is_save,
      required this.is_bookmark,
      required this.high_toughness_count,
      required this.medium_toughness_count,
      required this.low_toughness_count,
      required this.high_examlike_count,
      required this.medium_examlike_count,
      required this.low_examlike_count});

  factory Questions.fromJson(Map<String, dynamic> json) {
    return Questions(
        answer_count: json['answer_count'],
        answer_credit: json['answer_credit'],
        answer_preference:
            json['answer_preference'] == null ? "" : json['answer_preference'],
        audio_reference:
            json['audio_reference'] == null ? "" : json['audio_reference'],
        call_date: json['call_date'] == null ? "" : json['call_date'],
        call_end_time:
            json['call_end_time'] == null ? "" : json['call_end_time'],
        call_now: json['call_now'] == null ? "" : json['call_now'],
        call_preferred_lang: json['call_preferred_lang'] == null
            ? ""
            : json['call_preferred_lang'],
        call_start_time:
            json['call_start_time'] == null ? "" : json['call_start_time'],
        city: json['city'] == null ? "" : json['city'],
        compare_date: json['compare_date'] == null ? "" : json['compare_date'],
        examlikelyhood_count: json['examlikelyhood_count'],
        first_name: json['first_name'] == null ? "" : json['first_name'],
        grade: json['grade'],
        impression_count: json['impression_count'],
        isExamlikelyhoodButtonExpanded:
            json['isExamlikelyhoodButtonExpanded'] == null
                ? "false"
                : json['isExamlikelyhoodButtonExpanded'],
        isLikeButtonExpanded: json['isLikeButtonExpanded'] == null
            ? ""
            : json['isLikeButtonExpanded'],
        isToughnessButtonExpanded: json['isToughnessButtonExpanded'] == null
            ? "false"
            : json['isToughnessButtonExpanded'],
        is_identity_visible: json['is_identity_visible'] == null
            ? "false"
            : json['is_identity_visible'],
        last_name: json['last_name'] == null ? "" : json['last_name'],
        like_count: json['like_count'],
        note_reference:
            json['note_reference'] == null ? "" : json['note_reference'],
        ocr_image: json['ocr_image'] == null ? "" : json['ocr_image'],
        profilepic: json['profilepic'] == null ? "" : json['profilepic'],
        question: json['question'] == null ? "" : json['question'],
        question_credit: json['question_credit'],
        question_id: json['question_id'] == null ? "" : json['question_id'],
        question_type:
            json['question_type'] == null ? "" : json['question_type'],
        school_name: json['school_name'] == null ? "" : json['school_name'],
        subject: json['subject'] == null ? "" : json['subject'],
        tag_list: json['tag_list'] == null ? [] : json['tag_list'],
        shared_question_details: json["shared_question_details"] != null
            ? List<SharedQuestion>.from(json["shared_question_details"]
                .map((x) => SharedQuestion.fromJson(x)))
            : <SharedQuestion>[],
        text_reference:
            json['text_reference'] == null ? "" : json['text_reference'],
        topic: json['topic'] == null ? "" : json['topic'],
        toughness_count: json['toughness_count'],
        user_id: json['user_id'] == null ? "" : json['user_id'],
        video_reference:
            json['video_reference'] == null ? "" : json['video_reference'],
        view_count: json['view_count'],
        like_type: json['like_type'] == null ? "" : json['like_type'],
        examlikelyhood_type: json['examlikelyhood_level'] == null
            ? ""
            : json['examlikelyhood_level'],
        toughness_type:
            json['toughness_level'] == null ? "" : json['toughness_level'],
        is_save: json['is_save'] == null ? "" : json['is_save'],
        is_bookmark: json['is_bookmark'] == null ? "" : json['is_bookmark'],
        high_toughness_count: json['high_toughness_count'],
        medium_toughness_count: json['medium_toughness_count'],
        low_toughness_count: json['low_toughness_count'],
        high_examlike_count: json['high_examlike_count'],
        medium_examlike_count: json['medium_examlike_count'],
        low_examlike_count: json['low_examlike_count']);
  }
}

class SharedQuestion {
  int answer_count;
  final int answer_credit;
  final String answer_preference;
  final String audio_reference;
  final String call_date;
  final String call_end_time;
  final String call_now;
  final String call_preferred_lang;
  final String call_start_time;
  final String city;
  final String compare_date;
  int examlikelyhood_count;
  final String first_name;
  final int grade;
  int impression_count;
  String isExamlikelyhoodButtonExpanded;
  String isLikeButtonExpanded;
  String isToughnessButtonExpanded;
  final String is_identity_visible;
  final String last_name;
  int like_count;
  final String note_reference;
  final String ocr_image;
  final String profilepic;
  final String question;
  final int question_credit;
  final String question_id;
  final String question_type;
  final String school_name;
  final String subject;
  final List tag_list;
  final String text_reference;
  final String topic;
  int toughness_count;
  final String user_id;
  final String video_reference;
  int view_count;
  String like_type;
  String examlikelyhood_type;
  String toughness_type;
  String is_save;
  String is_bookmark;
  final int high_toughness_count;
  final int medium_toughness_count;
  final int low_toughness_count;
  final int high_examlike_count;
  final int medium_examlike_count;
  final int low_examlike_count;

  SharedQuestion(
      {required this.answer_count,
      required this.answer_credit,
      required this.answer_preference,
      required this.audio_reference,
      required this.call_date,
      required this.call_end_time,
      required this.call_now,
      required this.call_preferred_lang,
      required this.call_start_time,
      required this.city,
      required this.compare_date,
      required this.examlikelyhood_count,
      required this.first_name,
      required this.grade,
      required this.impression_count,
      required this.isExamlikelyhoodButtonExpanded,
      required this.isLikeButtonExpanded,
      required this.isToughnessButtonExpanded,
      required this.is_identity_visible,
      required this.last_name,
      required this.like_count,
      required this.note_reference,
      required this.ocr_image,
      required this.profilepic,
      required this.question,
      required this.question_credit,
      required this.question_id,
      required this.question_type,
      required this.school_name,
      required this.subject,
      required this.tag_list,
      required this.text_reference,
      required this.topic,
      required this.toughness_count,
      required this.user_id,
      required this.video_reference,
      required this.view_count,
      required this.like_type,
      required this.examlikelyhood_type,
      required this.toughness_type,
      required this.is_save,
      required this.is_bookmark,
      required this.high_toughness_count,
      required this.medium_toughness_count,
      required this.low_toughness_count,
      required this.high_examlike_count,
      required this.medium_examlike_count,
      required this.low_examlike_count});

  factory SharedQuestion.fromJson(Map<String, dynamic> json) {
    return SharedQuestion(
        answer_count: json['answer_count'],
        answer_credit: json['answer_credit'],
        answer_preference:
            json['answer_preference'] == null ? "" : json['answer_preference'],
        audio_reference:
            json['audio_reference'] == null ? "" : json['audio_reference'],
        call_date: json['call_date'] == null ? "" : json['call_date'],
        call_end_time:
            json['call_end_time'] == null ? "" : json['call_end_time'],
        call_now: json['call_now'] == null ? "" : json['call_now'],
        call_preferred_lang: json['call_preferred_lang'],
        call_start_time:
            json['call_start_time'] == null ? "" : json['call_start_time'],
        city: json['city'] == null ? "" : json['city'],
        compare_date: json['compare_date'] == null ? "" : json['compare_date'],
        examlikelyhood_count: json['examlikelyhood_count'],
        first_name: json['first_name'] == null ? "" : json['first_name'],
        grade: json['grade'],
        impression_count: json['impression_count'],
        isExamlikelyhoodButtonExpanded:
            json['isExamlikelyhoodButtonExpanded'] == null
                ? "false"
                : json['isExamlikelyhoodButtonExpanded'],
        isLikeButtonExpanded: json['isLikeButtonExpanded'] == null
            ? "false"
            : json['isLikeButtonExpanded'],
        isToughnessButtonExpanded: json['isToughnessButtonExpanded'] == null
            ? "false"
            : json['isToughnessButtonExpanded'],
        is_identity_visible: json['is_identity_visible'] == null
            ? "false"
            : json['is_identity_visible'],
        last_name: json['last_name'] == null ? "" : json['last_name'],
        like_count: json['like_count'],
        note_reference:
            json['note_reference'] == null ? "" : json['note_reference'],
        ocr_image: json['ocr_image'] == null ? "" : json['ocr_image'],
        profilepic: json['profilepic'] == null ? "" : json['profilepic'],
        question: json['question'] == null ? "" : json['question'],
        question_credit: json['question_credit'],
        question_id: json['question_id'] == null ? "" : json['question_id'],
        question_type:
            json['question_type'] == null ? "" : json['question_type'],
        school_name: json['school_name'] == null ? "" : json['school_name'],
        subject: json['subject'] == null ? "" : json['subject'],
        tag_list: json['tag_list'] == null ? [] : json['tag_list'],
        text_reference:
            json['text_reference'] == null ? "" : json['text_reference'],
        topic: json['topic'] == null ? "" : json['topic'],
        toughness_count: json['toughness_count'],
        user_id: json['user_id'] == null ? "" : json['user_id'],
        video_reference:
            json['video_reference'] == null ? "" : json['video_reference'],
        view_count: json['view_count'],
        like_type: json['like_type'] == null ? "" : json['like_type'],
        examlikelyhood_type: json['examlikelyhood_level'] == null
            ? ""
            : json['examlikelyhood_level'],
        toughness_type:
            json['toughness_level'] == null ? "" : json['toughness_level'],
        is_save: json['is_save'] == null ? "" : json['is_save'],
        is_bookmark: json['is_bookmark'] == null ? "" : json['is_bookmark'],
        high_toughness_count: json['high_toughness_count'],
        medium_toughness_count: json['medium_toughness_count'],
        low_toughness_count: json['low_toughness_count'],
        high_examlike_count: json['high_examlike_count'],
        medium_examlike_count: json['medium_examlike_count'],
        low_examlike_count: json['low_examlike_count']);
  }
}
