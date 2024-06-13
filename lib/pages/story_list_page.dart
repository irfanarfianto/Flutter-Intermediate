// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/constants/url_api.dart';
import 'package:story/pages/add_story_page.dart';
import 'package:story/pages/login_page.dart';
import 'package:story/pages/story_detail_page.dart';

class StoryListPage extends StatefulWidget {
  const StoryListPage({super.key});

  @override
  _StoryListPageState createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> _fetchStories() async {
    final token = await _getToken();
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
      // Convert createdAt to DateTime
      List<dynamic> stories = List<dynamic>.from(data['listStory']
          .map((x) => {...x, 'createdAt': DateTime.parse(x['createdAt'])}));
      return stories;
    } else {
      throw Exception('Failed to load stories');
    }
  }

  Future<void> _refreshStories() async {
    setState(() {});
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Keluar dari aplikasi?'),
          actions: [
            TextButton(
              child: const Text('Keluar'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await _showLogoutDialog();
  }

  Widget _buildStoryPlaceholder() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200.0,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 20.0,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 20.0,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Story App',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, semanticLabel: 'Logout'),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _fetchStories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => _buildStoryPlaceholder(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final stories = snapshot.data!;
              return RefreshIndicator(
                onRefresh: _refreshStories,
                child: ListView.builder(
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => StoryDetailPage(
                              id: story['id'],
                              photoUrl: story['photoUrl'],
                              name: story['name'],
                              description: story['description'],
                              creationTime: story['createdAt'],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 200.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  story['photoUrl'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error);
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              story['name'],
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              story['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14.0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddStoryPage(),
              ),
            );
          },
          child: const Icon(Icons.add,
              color: Colors.white, semanticLabel: 'Add Story'),
        ),
      ),
    );
  }
}
