import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:story/model/story.dart';
import 'package:story/routes/router_delegate.dart';

class StoryDetailPage extends StatelessWidget {
  final Story story;

  const StoryDetailPage({
    super.key,
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    String formattedCreationTime =
        DateFormat.yMMMMd().add_jm().format(story.createdAt);

    final routerDelegate =
        Router.of(context).routerDelegate as StoryAppRouterDelegate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            routerDelegate.navigateToStoryList();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 300.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    story.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
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
              const SizedBox(height: 16),
              Text(
                story.name,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                story.description,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8),
              Text(
                'Created on: $formattedCreationTime',
                style: const TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
              if (story.lat != null && story.lon != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Location: (${story.lat}, ${story.lon})',
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
