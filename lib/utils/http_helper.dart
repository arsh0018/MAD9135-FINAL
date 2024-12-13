import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class HttpHelper {
  static String movieNightBaseUrl = 'https://movie-night-api.onrender.com';

  static startSession(String? deviceId) async {
    var response = await http
        .get(Uri.parse('$movieNightBaseUrl/start-session?device_id=$deviceId'));
    return jsonDecode(response.body);
  }

  static joinSession(String? deviceId, int code) async {
    var response = await http.get(Uri.parse(
        '$movieNightBaseUrl/join-session?device_id=$deviceId&code=$code'));
    return jsonDecode(response.body);
  }

  static fetchMovies(baseUrl) async {
    var apiKey = dotenv.env['TMDB_API_KEY'];
    var response = await http.get(Uri.parse('$baseUrl&api_key=$apiKey'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['results'];
    } else {
      return jsonDecode(response.body);
    }
  }

  static voteMovie(session, movie, vote) async {
    var response = await http.get(Uri.parse(
        '$movieNightBaseUrl/vote-movie?session_id=$session&movie_id=$movie&vote=$vote'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return [data["data"]];
    } else {
      return [];
    }
  }
}
