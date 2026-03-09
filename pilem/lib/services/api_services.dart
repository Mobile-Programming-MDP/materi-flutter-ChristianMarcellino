import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServices {
  static const String baseUrl = "https://api.themoviedb.org/3/";
  static const String apiKey = "e3352507dfa095e841e5bdb481fc34db";

  // Get All Movie JSON
  Future<List<Map<String, dynamic>>> getAllMovies() async {
    String url = "${baseUrl}movie/now_playing";
    final response = await http.get(Uri.parse("$url?api_key=$apiKey"));
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }

  // Get All Trending Movie
  Future<List<Map<String, dynamic>>> getTrendingMovies() async {
    String url = "${baseUrl}trending/movie/week";
    final response = await http.get(Uri.parse("$url?api_key=$apiKey"));
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }

  // Get All Popular Movie
  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    String url = "${baseUrl}movie/popular";
    final response = await http.get(Uri.parse("$url?api_key=$apiKey"));
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }

  // Search
  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    String url = "${baseUrl}search/movie?query=${query}&";
    final response = await http.get(Uri.parse("${url}api_key=$apiKey"));
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['results']);
  }
}
