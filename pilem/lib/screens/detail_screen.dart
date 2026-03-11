import 'package:flutter/material.dart';
import 'package:pilems/models/movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Future<void> _toggleFavorite(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList("favorite_movie") ?? [];
    if (favorites.contains(id.toString())) {
      setState(() {
        isFavorite = false;
      });
      favorites.remove(id.toString());
    } else {
      setState(() {
        isFavorite = true;
      });
      favorites.add(id.toString());
    }

    await prefs.setStringList("favorite_movie", favorites);
  }

  Future<bool> _isFavorite(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList("favorite_movie") ?? [];
    return favorites.contains(id.toString());
  }

  bool isFavorite = false;

  void _checkFavorite() async {
    bool fav = await _isFavorite(widget.movie.id);
    setState(() {
      isFavorite = fav;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        actions: [
          IconButton(
            onPressed: () async {
              await _toggleFavorite(widget.movie.id);
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.movie.imgurl + widget.movie.backdropPath,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 300),
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(widget.movie.overview, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    "Release Date : ",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(widget.movie.releaseDate),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 10),
                  const Text(
                    'Rating : ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(widget.movie.voteAverage.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
