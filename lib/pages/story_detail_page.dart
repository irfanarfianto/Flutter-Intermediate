import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:story/model/story.dart';

class StoryDetailPage extends StatefulWidget {
  final Story story;
  final VoidCallback onBack;

  const StoryDetailPage({
    super.key,
    required this.story,
    required this.onBack,
  });

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.story.lat != null && widget.story.lon != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('story_location'),
          position: LatLng(widget.story.lat!, widget.story.lon!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedCreationTime =
        DateFormat.yMMMMd().add_jm().format(widget.story.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onBack();
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
                    widget.story.photoUrl,
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
                widget.story.name,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.story.description,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8),
              Text(
                'Created on: $formattedCreationTime',
                style: const TextStyle(fontSize: 14.0, color: Colors.grey),
              ),
              if (widget.story.lat != null && widget.story.lon != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Location: (${widget.story.lat}, ${widget.story.lon})',
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      setState(() {});
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.story.lat!, widget.story.lon!),
                      zoom: 15,
                    ),
                    markers: _markers,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
