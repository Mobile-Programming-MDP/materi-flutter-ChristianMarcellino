import 'dart:convert';
import 'package:fasum_app/models/post.dart';
import 'package:fasum_app/services/fasum_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geocoding/geocoding.dart';

class DetailScreen extends StatefulWidget {
  final Post post;

  const DetailScreen({super.key, required this.post});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _currentAddress;

  Future<void> _getAddressFromLatLng() async {
  try {
    final latStr = widget.post.latitude;
    final lngStr = widget.post.longitude;

    if (latStr == null || lngStr == null) {
      _setAddress('Location not available');
      return;
    }

    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);

    if (lat == null || lng == null) {
      _setAddress('Invalid coordinates');
      return;
    }

    // Optional: reject nonsense coordinates
    if (lat == 0 && lng == 0) {
      _setAddress('Unknown location');
      return;
    }

    final place = await placemarkFromCoordinates(lat, lng);

    if (place.isEmpty) {
      _setAddress('Address not found');
      return;
    }

    final p = place.first;

    _setAddress(
      '${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}',
    );
  } catch (e) {
    print('Geocoding error: $e');
    _setAddress('Failed to load location');
  }
}

void _setAddress(String value) {
  if (!mounted) return;
  setState(() => _currentAddress = value);
}

  Future<void> _deletePost(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FasumService.deletePost(widget.post);
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _sharePost() {
    final text =
        '${widget.post.category ?? ''}\n${widget.post.description ?? ''}\nPosted by: ${widget.post.fullName ?? ''}';
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  void initState() {
    _getAddressFromLatLng();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner =
        currentUserId != null && widget.post.userId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.category ?? 'Post Detail'),
        actions: [
          IconButton(
            onPressed: _sharePost,
            icon: const Icon(Icons.share),
            tooltip: 'Share',
          ),
          if (isOwner)
            IconButton(
              onPressed: () => _deletePost(context),
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
              color: Colors.red,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.post.image != null && widget.post.image!.isNotEmpty)
              Image.memory(
                base64Decode(widget.post.image!),
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 250,
                  child: Center(child: Icon(Icons.broken_image, size: 64)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.post.category != null)
                    Chip(label: Text(widget.post.category!)),
                  const SizedBox(height: 8),
                  Text(
                    widget.post.description ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.fullName ?? 'Unknown',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  if (widget.post.latitude != null &&
                      widget.post.longitude != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _currentAddress ?? 'Loading address...',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
