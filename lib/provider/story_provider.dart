import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/constants/url_api.dart';
import 'package:flutter/foundation.dart';

class StoryProvider with ChangeNotifier {
  List<dynamic> _stories = [];
  bool _isLoading = false;

  List<dynamic> get stories => _stories;
  bool get isLoading => _isLoading;

  Future<void> fetchStories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token is missing');
      }

      final response = await http.get(
        Uri.parse('${UrlApi.baseUrl}/stories'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _stories = List<dynamic>.from(data['listStory'].map((x) => {
              ...x,
              'createdAt': DateTime.parse(x['createdAt']),
            }));
      } else {
        throw Exception('Failed to load stories');
      }
    } catch (e) {
      throw Exception('Failed to load stories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> addStory(String description, File image) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token is missing');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${UrlApi.baseUrl}/stories'),
      );
      request.fields['description'] = description;
      request.files.add(await http.MultipartFile.fromPath('photo', image.path));
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();

      if (response.statusCode == 201) {
        return response.statusCode;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        throw Exception('Failed to add story: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add story: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
