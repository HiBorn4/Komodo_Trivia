import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import '../api_services.dart'; // Replace this with the correct import path

void main() {
  group('getQuiz', () {
    test('should fetch quiz data successfully', () async {
      // Mock response for a successful API call
      const mockResponse = '''
        {
          "results": [
            {
              "question": "What is the capital of France?",
              "correct_answer": "Paris",
              "incorrect_answers": ["Berlin", "Rome", "Madrid"]
            },
            {
              "question": "Which planet is known as the Red Planet?",
              "correct_answer": "Mars",
              "incorrect_answers": ["Venus", "Jupiter", "Saturn"]
            }
          ]
        }
      ''';

      // Mock HTTP client to simulate successful response
      MockClient.mockResponse(200, mockResponse);

      // Call the getQuiz function
      final quizData = await getQuiz("easy");

      // Verify that the quiz data is not null
      expect(quizData, isNotNull);

      // Validate the structure of the returned data
      expect(quizData['results'], isList);
      expect(quizData['results'].length,
          equals(2)); // Assuming 2 results in the mocked response
    });

    // Add more test cases to cover error scenarios, decoding errors, network issues, etc.
  });
}

class MockClient {
  static late MockClientFunction mockFunction;

  static void mockResponse(int statusCode, String body) {
    mockFunction = MockClientFunction(
      (http.BaseRequest request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode(body)),
          statusCode,
        );
      },
    );
  }

  static Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return await mockFunction.mockFunction(request);
  }
}

class MockClientFunction {
  Future<http.StreamedResponse> Function(http.BaseRequest) mockFunction;

  MockClientFunction(this.mockFunction);
}
