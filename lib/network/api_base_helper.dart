import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'app_exceptions.dart';

class ApiBaseHelper {
  // final String _baseUrl = "https://hys-api.herokuapp.com/";

  final String _baseUrl =
      "https://cros-anywhere.herokuapp.com/https://hys.today/";

  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      final response = await http.get(Uri.parse(_baseUrl + url));
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String url, dynamic body) async {
    var responseJson;
    var headers = <String, String>{
      'Content-Type': 'application/json',
      "Access-Control_Allow_Origin": "*"
    };
    try {
      final response = await http.post(Uri.parse(_baseUrl + url),
          headers: headers, body: json.encode(body));
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post2(
      String url, String query, String subject, String grade) async {
    var responseJson;
    var headers = {'Content-Type': 'application/json'};
    var requestBody = json.encode(
        {"query": query, "grade": grade, "subject": subject.toLowerCase()});

    try {
      final response = await http.post(
          Uri.parse("http://20.127.142.14:8080/predict_concept"),
          body: requestBody,
          headers: headers);
      if (response.statusCode == 500) {
        responseJson = [];
      } else {
        responseJson = _returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post3(String url, dynamic body) async {
    var responseJson;
    var headers = {'Content-Type': 'application/json'};
    var requestBody = json.encode(body);

    try {
      final response = await http.post(
          Uri.parse("http://20.127.142.14:8080/predict_concept"),
          body: requestBody,
          headers: headers);
      if (response.statusCode == 500) {
        responseJson = [];
      } else {
        responseJson = _returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> put(String url, dynamic body) async {
    var responseJson;
    var headers = <String, String>{
      'Content-Type': 'application/json',
      "Access-Control_Allow_Origin": "*"
    };
    try {
      final response = await http.put(Uri.parse(_baseUrl + url),
          headers: headers, body: body);
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body);
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
