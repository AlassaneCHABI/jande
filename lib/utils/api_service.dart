import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:jande/utils/constants.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:http/http.dart' as http;


class ApiService {
  final String baseUrl = API_BASE_URL;
  PreferenceManager pref_manager = PreferenceManager();
  DbManager db_manager = DbManager();

  Future getApi(String url) async {

    var urlApi = Uri.parse("${API_BASE_URL}/${url}");

    final response = await http.get(
      urlApi,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    print('--------------urlApi-----------');
    print(urlApi);

    dynamic apiResponse = jsonDecode(response.body);

    /*print("**********-----apiResponse ");
    print(apiResponse);*/

    return apiResponse;
  }


  Future<dynamic> postApi(String url, data) async {
    // print(data);
    var apiResponse;
    try {
      final http.Response response = await http.post(
        Uri.parse(this.baseUrl + url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader:
              'Bearer ${pref_manager.getPrefItem('access_token').toString()}',
        },
        body: jsonEncode(data),
      );
      apiResponse = jsonDecode(response.body);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return apiResponse;
  }


  Future<dynamic> putApi(url, data) async {
    var apiResponse;
    try {
      final http.Response response = await http.put(
        Uri.parse(this.baseUrl + url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader:
              'Bearer ${pref_manager.getPrefItem('access_token').toString()}',
        },
        body: jsonEncode(data),
      );
      apiResponse = jsonDecode(response.body);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    //print(apiResponse);
    return apiResponse;
  }


  Future<dynamic> deleteApi(String url) async {
    var apiResponse;
    try {
      final http.Response response = await http.delete(
        Uri.parse(this.baseUrl + url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader:
              'Bearer ${pref_manager.getPrefItem('access_token').toString()}',
        },
      );
      apiResponse = jsonDecode(response.body);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return apiResponse;
  }
}



class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([message]) : super(message, "Invalid Input: ");
}

class UnauthorizedException extends AppException {
  UnauthorizedException([message]) : super(message, "Unauthorised: ");
}

class ForbiddenException extends AppException {
  ForbiddenException([message]) : super(message, "Forbidden: ");
}

class NotFoundException extends AppException {
  NotFoundException([message]) : super(message, "Not Found: ");
}

class MethodNotAllowedException extends AppException {
  MethodNotAllowedException([message]) : super(message, "Method Not Allowed: ");
}

class UnprocessableEntityException extends AppException {
  UnprocessableEntityException([message])
      : super(message, "Unprocessable Entity: ");
}
