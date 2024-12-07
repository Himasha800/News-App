

import 'package:news_app1/models/categories_news_model.dart';
import 'package:news_app1/models/news_channel_headlines_model.dart';
import 'package:news_app1/models/search_news_model.dart';
import 'package:news_app1/repository/news_repository.dart';

class NewsViewModel {
  final _rep = NewsRepository();

  // Fetch news headlines based on the channel name
  Future<NewsChannelsHeadlinesModel> fetchNewsChannelHeadlinesApi(String channelName) async {
    final response = await _rep.fetchNewsChannelHeadlinesApi(channelName);
    return response;
  }

  // Fetch news articles based on a specific category
  Future<CategoriesNewsModel> fetchNewsCategoriesNewsApi(String category) async {
    final response = await _rep.fetchNewsCategoriesNewsApi(category);
    return response;
  }

  // Fetch news articles based on a search query
  Future<SearchNewsModel> fetchNewsSearchApi(String searchQuery, String selectedNewsType) async {
    final response = await _rep.fetchNewsSearchApi(searchQuery);
    return response;
  }

  
}
