//Servicio o provider de movie
import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/models/models.dart';

class MoviesProvider extends ChangeNotifier {
  String _apiKey = 'ed77000fe1d336b36f9667ef9da09807';
  String _baseUrl = 'api.themoviedb.org';
  String _language = 'es-Es';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  int popularPage = 0;

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
}
