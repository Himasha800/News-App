
import 'package:flutter/material.dart';
import 'package:news_app1/models/categories_news_model.dart';
import 'package:news_app1/models/news_channel_headlines_model.dart';
import 'package:news_app1/view_model/news_view_model.dart';
import 'package:news_app1/utils/db_helper.dart';
import 'package:news_app1/models/search_news_model.dart';
import 'package:intl/intl.dart'; 

class NewsProvider with ChangeNotifier {
  
  final NewsViewModel _newsViewModel = NewsViewModel();
  NewsChannelsHeadlinesModel? _headlines;
  CategoriesNewsModel? _categoriesNews;
  SearchNewsModel? _searchResults;

  bool _isLoadingHeadlines = false;
  bool _isLoadingCategoriesNews = false;
  bool _isLoadingSearchNews = false;

  NewsChannelsHeadlinesModel? get headlines => _headlines;
  CategoriesNewsModel? get categoriesNews => _categoriesNews;
  SearchNewsModel? get searchResults => _searchResults;
  bool get isLoadingHeadlines => _isLoadingHeadlines;
  bool get isLoadingCategoriesNews => _isLoadingCategoriesNews;
  bool get isLoadingSearchNews => _isLoadingSearchNews;

  Future<void> fetchHeadlines(String channelName) async {
    _isLoadingHeadlines = true;
    notifyListeners();
    try {
      _headlines = await _newsViewModel.fetchNewsChannelHeadlinesApi(channelName);
    } catch (error) {
      print('Error fetching headlines: $error');
    } finally {
      _isLoadingHeadlines = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategoriesNews(String category) async {
    _isLoadingCategoriesNews = true;
    notifyListeners();
    try {
      _categoriesNews = await _newsViewModel.fetchNewsCategoriesNewsApi(category);
    } catch (error) {
      print('Error fetching categories news: $error');
    } finally {
      _isLoadingCategoriesNews = false;
      notifyListeners();
    }
  }


  Future<void> searchNews(String query, String selectedNewsType) async {
    _isLoadingSearchNews = true;
    notifyListeners();
    try {
      _searchResults = await _newsViewModel.fetchNewsSearchApi(query, selectedNewsType);
      _searchResults?.articles = _searchResults?.articles?.where((article) {
        final lowerQuery = query.toLowerCase();
        final title = article.title?.toLowerCase() ?? '';
        final source = article.source?.name?.toLowerCase() ?? '';
        final description = article.description?.toLowerCase() ?? '';
        final author = article.author?.toLowerCase() ?? '';
        final publishedAt = DateFormat('MMMM dd, yyyy').format(DateTime.parse(article.publishedAt ?? '')).toLowerCase();

        return title.contains(lowerQuery) ||
               source.contains(lowerQuery) ||
               description.contains(lowerQuery) ||
               author.contains(lowerQuery) ||
               publishedAt.contains(lowerQuery);
      }).toList();
    } catch (error) {
      print('Error fetching search news: $error');
    } finally {
      _isLoadingSearchNews = false;
      notifyListeners();
    }
  }


  Future<void> toggleFavorite(String newsTitle, String newsImage, String newsDescription, String newsContent, String newsSource) async {
    try {
      bool isFavorite = await DBHelper().checkIfNewsExists(DBHelper().favoriteNewsTable, newsTitle);
      if (isFavorite) {
        await removeFromFavorites(newsTitle);
      } else {
        await addToFavorites(newsTitle, newsImage, newsDescription, newsContent, newsSource);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<void> addToFavorites(String newsTitle, String newsImage, String newsDescription, String newsContent, String newsSource) async {
    final newsData = {
      'title': newsTitle,
      'source': newsSource,
      'image_url': newsImage,
      'description': newsDescription,
      'content': newsContent,
    };
    try {
      await DBHelper().insertNews(DBHelper().favoriteNewsTable, newsData);
      print("Added to favorites");
    } catch (e) {
      print("Error adding to favorites: $e");
    }
  }

  Future<void> removeFromFavorites(String newsTitle) async {
    try {
      await DBHelper().deleteNewsByTitle(DBHelper().favoriteNewsTable, newsTitle);
      print("Removed from favorites");
    } catch (e) {
      print("Error removing from favorites: $e");
    }
  }

  Future<void> toggleSaved(String newsTitle, String newsImage, String newsDescription, String newsContent, String newsSource) async {
    try {
      bool isSaved = await DBHelper().checkIfNewsExists(DBHelper().savedNewsTable, newsTitle);
      if (isSaved) {
        await removeSavedNews(newsTitle);
      } else {
        await saveNews(newsTitle, newsImage, newsDescription, newsContent, newsSource);
      }
    } catch (e) {
      print('Error toggling saved: $e');
    }
  }

  Future<void> saveNews(String newsTitle, String newsImage, String newsDescription, String newsContent, String newsSource) async {
    final newsData = {
      'title': newsTitle,
      'source': newsSource,
      'image_url': newsImage,
      'description': newsDescription,
      'content': newsContent,
    };
    try {
      await DBHelper().insertNews(DBHelper().savedNewsTable, newsData);
      print("News Saved");
    } catch (e) {
      print("Error saving news: $e");
    }
  }

  Future<void> removeSavedNews(String newsTitle) async {
    try {
      await DBHelper().deleteNewsByTitle(DBHelper().savedNewsTable, newsTitle);
      print("Removed saved news");
    } catch (e) {
      print("Error removing saved news: $e");
    }
  }

  
  Future<void> shareNews(String newsTitle, String newsImage, String newsDescription, String newsContent, String newsSource) async {
    try {
      
      print('Shared news: $newsTitle');
    
      await saveSharedNews(newsTitle, newsImage, newsDescription, newsContent, newsSource);
    } catch (e) {
      print("Error sharing news: $e");
    }
  }

  Future<void> saveSharedNews(String newsTitle, String newsImage, String newsDescription, String newsContent, String newsSource) async {
    final newsData = {
      'title': newsTitle,
      'source': newsSource,
      'image_url': newsImage,
      'description': newsDescription,
      'content': newsContent,
    };
    try {
      await DBHelper().insertNews(DBHelper().sharedNewsTable, newsData);
      print("Shared news saved");
    } catch (e) {
      print("Error saving shared news: $e");
    }
  }
}
