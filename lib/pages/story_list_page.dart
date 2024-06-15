import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/model/story.dart';
import 'package:story/provider/auth_provider.dart';
import 'package:story/provider/story_provider.dart';

class StoryListPage extends StatefulWidget {
  final Function() onLogout;
  final void Function(Story) onStorySelected;
  final Function() onAddStory;

  const StoryListPage(
      {super.key,
      required this.onLogout,
      required this.onStorySelected,
      required this.onAddStory});

  @override
  _StoryListPageState createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Menunda fetchStories sampai build selesai
    Future.microtask(() {
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);
      storyProvider.fetchStories();
    });

    _scrollController.addListener(() {
      final storyProvider = Provider.of<StoryProvider>(context, listen: false);
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (storyProvider.hasMore) {
          storyProvider.fetchStories(page: storyProvider.currentPage + 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshStories(BuildContext context) async {
    await Provider.of<StoryProvider>(context, listen: false).fetchStories();
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Keluar dari aplikasi?'),
          actions: [
            TextButton(
              child: const Text('Keluar'),
              onPressed: () async {
                await Provider.of<AuthProvider>(context, listen: false)
                    .logout();
                widget.onLogout();
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
          title: const Text('Story App'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, semanticLabel: 'Logout'),
              tooltip: 'Logout',
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: Consumer<StoryProvider>(
          builder: (context, storyProvider, child) {
            if (storyProvider.isLoading && storyProvider.stories.isEmpty) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => _buildStoryPlaceholder(),
              );
            } else if (storyProvider.stories.isEmpty) {
              return const Center(child: Text('No stories available.'));
            } else {
              final stories = storyProvider.stories;
              return RefreshIndicator(
                onRefresh: () => _refreshStories(context),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: storyProvider.stories.length +
                      (storyProvider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == stories.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final story = stories[index];
                    return InkWell(
                      onTap: () {
                        widget.onStorySelected(story);
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
                                  story.photoUrl,
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
                              story.name,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              story.description,
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
          onPressed: () => widget.onAddStory(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
