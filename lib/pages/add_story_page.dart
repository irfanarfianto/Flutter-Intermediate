// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/constants/button.dart';
import 'package:story/constants/loading_indicator.dart';
import 'package:story/constants/url_api.dart';
import 'package:story/pages/story_list_page.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key});

  @override
  _AddStoryPageState createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final _descriptionController = TextEditingController();
  File? _image;
  String? _authToken;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('token');
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected.')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _uploadStory() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    if (_authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Authentication token is missing. Please log in again.')),
      );
      return;
    }

    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('${UrlApi.baseUrl}/stories'));
      request.fields['description'] = _descriptionController.text;
      request.files
          .add(await http.MultipartFile.fromPath('photo', _image!.path));
      request.headers['Authorization'] = 'Bearer $_authToken';

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story uploaded successfully!')),
        );
        // navigasi ke halaman list story
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const StoryListPage()),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unauthorized. Please log in again.')),
        );
        // Handle token refresh or re-authentication logic here
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to upload story: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Story'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _image == null
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: double.infinity,
                    height: 200,
                    alignment: Alignment.center,
                    child: const Text('No image selected.'))
                : SizedBox(width: 200, height: 200, child: Image.file(_image!)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: primaryButtonStyle,
                  child: const Text('Camera'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: primaryButtonStyle,
                  child: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Description',
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _uploadStory().then((_) {
                  setState(() {
                    _isLoading = false;
                  });
                });
              },
              style: primaryButtonStyle,
              child: _isLoading
                  ? const LoadingIndicator()
                  : const Text('Upload Story'),
            ),
          ],
        ),
      ),
    );
  }
}
