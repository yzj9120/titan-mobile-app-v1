import 'package:dio/dio.dart';
import 'dart:convert';

class HttpUtil {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getRequest(
      String url, Map<String, String>? headers) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.toString());
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while making GET request: $e');
    }
  }
}
