import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/constants/url_api.dart';
import 'package:story/model/story.dart';
import 'package:flutter/foundation.dart';

class StoryProvider with ChangeNotifier {
  List<Story> _stories = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int currentPage = 1;

  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> fetchStories({int page = 1}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final String? token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token is missing');
      }

      final response = await http.get(
        Uri.parse('${UrlApi.baseUrl}/stories?page=$page'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Story> fetchedStories = List<Story>.from(
          data['listStory'].map((x) => Story.fromJson(x)),
        );

        if (fetchedStories.isNotEmpty) {
          if (page == 1) {
            _stories = fetchedStories;
          } else {
            _stories.addAll(fetchedStories);
          }
          currentPage = page;
        } else {
          _hasMore = false;
        }
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

  Future<int> addStory(
      String description, File image, double? lat, double? lon) async {
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

      if (lat != null && lon != null) {
        request.fields['lat'] = lat.toString();
        request.fields['lon'] = lon.toString();
      }

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
