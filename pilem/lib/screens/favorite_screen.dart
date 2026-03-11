import 'package:flutter/material.dart';
import 'package:pilems/models/movie.dart';
import 'package:pilems/screens/detail_screen.dart';
import 'package:pilems/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  Future<List<String>> _loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("favorite_movie") ?? [];
  }

  List<Movie> _allMovies = [];
  List<Movie> _favoriteMovies = [];

  void loadFavorites() async {
    final favIds = await _loadFavorites();
    final List<Map<String, dynamic>> allMoviesData = await ApiServices()
        .getAllMovies();
    _allMovies = allMoviesData.map((e) => Movie.fromJson(e)).toList();
    setState(() {
      _favoriteMovies = _allMovies
          .where((movie) => favIds.contains(movie.id.toString()))
          .toList();
    });
  }

  @override
  void initState() {
    loadFavorites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favorite Movie")),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: _favoriteMovies.length,
        itemBuilder: (context, index) {
          final Movie movie = _favoriteMovies[index];
          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(movie: movie),
                ),
              );

              loadFavorites();
            },
            child: Column(
              children: [
                Image.network(
                  movie.imgurl + movie.posterPath,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 5),
                Text(
                  movie.title.length > 14
                      ? movie.title.substring(0, 10)
                      : movie.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
