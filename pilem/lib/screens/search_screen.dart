import 'package:flutter/material.dart';
import 'package:pilems/models/movie.dart';
import 'package:pilems/screens/detail_screen.dart';
import 'package:pilems/services/api_services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  ApiServices _apiServices = ApiServices();
  List<Movie> _searchedMovie = [];

  void _searchMovie() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchedMovie = [];
      });
    } else {
      final List<Map<String, dynamic>> searchResults = await _apiServices
          .searchMovies(_searchController.text);
      setState(() {
        _searchedMovie = searchResults.map((e) => Movie.fromJson(e)).toList();
      });
    }
  }

  @override
  void initState() {
    _searchController.addListener(_searchMovie);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Movie")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search Movies. . .",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _searchController.text.isNotEmpty,
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchedMovie.clear();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _searchedMovie.length,
                itemBuilder: (context, index) {
                  final movie = _searchedMovie[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: Image.network(
                        movie.imgurl + movie.posterPath,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 150,),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(movie.title),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(movie: movie),)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
