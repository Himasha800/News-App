
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:news_app1/models/categories_news_model.dart';
import 'package:news_app1/models/news_channel_headlines_model.dart';
import 'package:news_app1/models/search_news_model.dart';

class NewsRepository {
  Future<NewsChannelsHeadlinesModel> fetchNewsChannelHeadlinesApi(String channelName) async {
    String url = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=26f55278bbf64da18eeebdf1fcb9c730';
    print(url);

    final response = await http.get(Uri.parse(url));
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return NewsChannelsHeadlinesModel.fromJson(body);
    }
    throw Exception('Error');
  }




  Future<CategoriesNewsModel> fetchNewsCategoriesNewsApi(String Category) async {
    String url = 'https://newsapi.org/v2/everything?q=${Category}&apiKey=26f55278bbf64da18eeebdf1fcb9c730';
    print(url);

    final response = await http.get(Uri.parse(url));
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return CategoriesNewsModel.fromJson(body);
    }
    throw Exception('Error');
  }

  
  
  



  Future<SearchNewsModel> fetchNewsSearchApi(String search) async {
  final url = 'https://newsapi.org/v2/everything?q=$search&apiKey=26f55278bbf64da18eeebdf1fcb9c730';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return SearchNewsModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load search results');
  }
}


}
