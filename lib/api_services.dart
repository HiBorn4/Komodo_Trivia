import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

// Function to fetch quiz questions based on difficulty level
Future<dynamic> getQuiz(String difficulty) async {
  const baseUrl = "https://opentdb.com/api.php";
  const amount = "10";
  const category = "21";

  final link =
      "$baseUrl?amount=$amount&category=$category&difficulty=$difficulty";

  try {
    final response = await http.get(Uri.parse(link));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body.toString());
      if (kDebugMode) {
        print("Data is loaded");
      }
      return _decodeHtmlEntities(data);
    } else {
      // Handle non-200 status code errors
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (error) {
    // Handle network errors, timeouts, and other exceptions
    throw Exception('Failed to fetch data: $error');
  }
}

// Function to decode HTML entities in the retrieved data
dynamic _decodeHtmlEntities(dynamic data) {
  try {
    if (data is Map) {
      return data.map((key, value) {
        if (value is String) {
          return MapEntry(key, HtmlUnescape().convert(value));
        } else {
          return MapEntry(key, _decodeHtmlEntities(value));
        }
      });
    } else if (data is List) {
      return data.map((item) => _decodeHtmlEntities(item)).toList();
    } else {
      return data;
    }
  } catch (error) {
    // Handle decoding errors
    throw Exception('Failed to decode data: $error');
  }
}
