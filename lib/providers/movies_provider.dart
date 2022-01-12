//Servicio o provider de movie
import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  String _apiKey = 'ed77000fe1d336b36f9667ef9da09807';
  String _baseUrl = 'api.themoviedb.org';
  String _language = 'es-Es';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int popularPage = 0;

  //stream
  final debouncer = Debouncer(duration: Duration(milliseconds: 1000));

  final StreamController<List<Movie>> _suggestioStreamController =
      new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream =>
      this._suggestioStreamController.stream;

  MoviesProvider() {
    print('Movies providers inicializado');
    getOnDisplayMovies();
    getPopularMovies();
  }

  Future<String> _getJsonData(client, String endpoint, {int page = 1}) async {
    var uri = Uri.https(_baseUrl, endpoint, {
      'api_key': _apiKey,
      'language': _language,
      'page': '$page',
    });
    final response = await client.get(uri);
    return response.body;
  }

  getOnDisplayMovies() async {
    print('GetMovies');
    var client = http.Client();
    try {
      final jsonData = await _getJsonData(client, '3/movie/now_playing');
      final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);

      onDisplayMovies = nowPlayingResponse.results;
      notifyListeners(); //para cualquier widget que use los datos se redibuje
    } finally {
      client.close();
    }
  }

  getPopularMovies() async {
    var client = http.Client();
    try {
      popularPage++;
      final jsondata =
          await _getJsonData(client, '3/movie/now_playing', page: popularPage);
      final popularResponse = PopularResponse.fromJson(jsondata);

      popularMovies = [...popularMovies, ...popularResponse.results];
      notifyListeners(); //para cualquier widget que use los datos se redibuje
    } finally {
      client.close();
    }
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    //Todo revisar el map
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;
    print('pidiendo');
    var client = http.Client();
    try {
      final jsondata = await _getJsonData(client, '3/movie/$movieId/credits',
          page: popularPage);
      final creditsResponse = CreditsResponse.fromJson(jsondata);
      moviesCast[movieId] = creditsResponse.cast;
      return creditsResponse.cast;
    } finally {
      client.close();
    }
  }

  Future<List<Movie>> searchMovie(String query) async {
    var client = http.Client();
    try {
      var uri = Uri.https(_baseUrl, '3/search/movie', {
        'api_key': _apiKey,
        'language': _language,
        'query': query,
      });
      final response = await client.get(uri);
      final searchRespoense = SearchResponse.fromJson(response.body);

      return searchRespoense.results;
    } finally {
      client.close();
    }
  }

  int i = 0;
  void getSuggestioByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      i++;
      print('tenemos valor a buscar $value $i');
      final result = await this.searchMovie(value);
      this._suggestioStreamController.add(result);
    };

    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });
    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
}
