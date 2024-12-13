import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arsh_final/utils/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovieCodeScreen extends StatefulWidget {
  const MovieCodeScreen({super.key});

  @override
  State<MovieCodeScreen> createState() => _MovieCodeScreenState();
}

class _MovieCodeScreenState extends State<MovieCodeScreen> {
  final String baseUrl =
      'https://api.themoviedb.org/3/movie/popular?language=en-US&page=1';
  final String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  List movies = [];
  List currentMovie = [];
  bool isLoading = true;
  bool matchFound = false;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie Choice',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (!matchFound
              ? Dismissible(
                  key: Key(movies[0]['id'].toString()),
                  onDismissed: (direction) {
                    setState(() {
                      if (currentMovie.isNotEmpty) {
                        currentMovie.removeLast();
                        currentMovie.add(movies[0]);
                        movies.removeAt(0);
                      } else {
                        currentMovie.add(movies[0]);
                        movies.removeAt(0);
                      }
                    });

                    if (direction.name == "endToStart") {
                      _voteMovies(movies[0]['id'], false);
                      if (kDebugMode) {
                        print("Left Swipe");
                      }
                    } else if (direction.name == "startToEnd") {
                      _voteMovies(movies[0]['id'], true);
                      if (kDebugMode) {
                        print("Right Swipe");
                      }
                    }
                  },
                  secondaryBackground: Container(
                    color: null,
                    child: const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Icon(
                          Icons.thumb_down,
                          color: Colors.black,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  background: Container(
                    color: null,
                    child: const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.thumb_up,
                          color: Colors.black,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  child: Center(
                    child: Card(
                      elevation: 8,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15)),
                            child: Image.network(
                              '$imageBaseUrl${movies[0]['poster_path']}',
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movies[0]['title'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      movies[0]['release_date'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${movies[0]['vote_average'].toStringAsFixed(1)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Selected Movie",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          )),
                      Container(
                        color: Colors.lightBlue[200],
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              child: Image.network(
                                '$imageBaseUrl${currentMovie[0]['poster_path']}',
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentMovie[0]['title'],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        currentMovie[0]['release_date'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.amber, size: 18),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${currentMovie[0]['vote_average'].toStringAsFixed(1)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
    );
  }

  Future<void> _voteMovies(movieId, vote) async {
    final storageRef = await SharedPreferences.getInstance();
    final String? session = storageRef.getString("sessionId");
    if (session != null) {
      final response = await HttpHelper.voteMovie(session, movieId, vote);
      if (!response.isEmpty) {
        if (kDebugMode) {
          print("Movie voted successfully");
          setState(() {
            matchFound = true;
          });
        }
      } else {
        if (kDebugMode) {
          print("Something else");
          print(response);
          setState(() {
            matchFound = false;
          });
        }
      }
    }
  }

  Future<void> _fetchMovies() async {
    final response = await HttpHelper.fetchMovies(baseUrl);
    if (!response.isEmpty) {
      setState(() {
        movies = [...response]..shuffle();
        isLoading = false;
      });
      if (kDebugMode) {
        print('Movies fetched');
      }
    } else {
      setState(() {
        isLoading = true;
      });
      if (kDebugMode) {
        print('No movies fetched');
      }
    }
  }
}
