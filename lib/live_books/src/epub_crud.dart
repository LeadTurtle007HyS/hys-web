import 'dart:convert';
import 'package:http/http.dart' as http;

class EpubCRUD {
  Future<bool> addUserTextSelectionDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys.today/add_user_epub_selected_text'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "book_id": data[0],
        "chapter_id": data[1],
        "user_id": data[2],
        "base_offset": data[3],
        "extent_offset": data[4],
        "tag_index": data[5],
        "color": data[6],
        "selection_type": data[7],
        "level": data[8],
        "text_selected": data[9]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteUserTextSelectionDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys.today/delete_user_epub_selected_text'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "book_id": data[0],
        "chapter_id": data[1],
        "user_id": data[2],
        "base_offset": data[3],
        "extent_offset": data[4],
        "tag_index": data[5],
        "selection_type": data[6]
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
