
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DBHelper {
  static DBHelper? _dbHelper; 
  static Database? _database; 

  
  String savedNewsTable = 'saved_news_table';
  String favoriteNewsTable = 'favorite_news_table';
  String sharedNewsTable = 'shared_news_table';

  // Column names
  String colId = 'id';
  String colTitle = 'title';
  String colSource = 'source';
  String colImageUrl = 'image_url';
  String colNewsDate = 'news_date';
  String colAuthor = 'author';
  String colDescription = 'description';
  String colContent = 'content';

  DBHelper._createInstance(); 

  factory DBHelper() {
    _dbHelper ??= DBHelper._createInstance();
    return _dbHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/news.db';

    var newsDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return newsDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    // Create tables for saved, favorite, and shared news with detailed fields
    await db.execute(
      'CREATE TABLE $savedNewsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colSource TEXT, $colImageUrl TEXT, $colNewsDate TEXT, $colAuthor TEXT, $colDescription TEXT, $colContent TEXT)',
    );
    await db.execute(
      'CREATE TABLE $favoriteNewsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colSource TEXT, $colImageUrl TEXT, $colNewsDate TEXT, $colAuthor TEXT, $colDescription TEXT, $colContent TEXT)',
    );
    await db.execute(
      'CREATE TABLE $sharedNewsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colSource TEXT, $colImageUrl TEXT, $colNewsDate TEXT, $colAuthor TEXT, $colDescription TEXT, $colContent TEXT)',
    );
  }

  // insert data 
  Future<int> insertNews(String tableName, Map<String, dynamic> newsData) async {
    Database db = await database;
    return await db.insert(tableName, newsData);
  }

  // Save news 
  Future<int> saveNews(Map<String, dynamic> newsData) async {
    return await insertNews(savedNewsTable, newsData);
  }

  // Fetch news from newapi.org and insert into the database
  Future<void> fetchAndSaveNews() async {
    try {
      
      final response = await http.get(
        Uri.parse('https://newsapi.org/v2/top-headlines?country=us&apiKey=26f55278bbf64da18eeebdf1fcb9c730'),
      );

      if (response.statusCode == 200) {
       
        Map<String, dynamic> data = json.decode(response.body);
        List articles = data['articles'];

        // Insert each article into the saved news table
        for (var article in articles) {
          Map<String, dynamic> newsData = {
            colTitle: article['title'],
            colSource: article['source']['name'],
            colImageUrl: article['urlToImage'],
            colNewsDate: article['publishedAt'],
            colAuthor: article['author'] ?? 'Unknown',
            colDescription: article['description'] ?? 'No description',
            colContent: article['content'] ?? 'No content',
          };
          await saveNews(newsData);
        }
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  
  Future<void> deleteNews(String tableName, int id) async {
    final db = await database;
    try {
      await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      rethrow;
    }
  }


  Future<List<Map<String, dynamic>>> getNewsList(String tableName) async {
    Database db = await database;
    return await db.query(tableName, orderBy: '$colId DESC');
  }


  Future<int?> getCount(String tableName) async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(x);
  }

  // Delete news by title
  Future<int> deleteNewsByTitle(String table, String title) async {
    final db = await database;
    return await db.delete(table, where: '$colTitle = ?', whereArgs: [title]);
  }

  Future<List<Map<String, dynamic>>> getAllNews(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }


  
  Future<bool> checkIfNewsExists(String table, String newsTitle) async {
    final db = await database;
    var result = await db.query(
      table,
      where: '$colTitle = ?',
      whereArgs: [newsTitle],
    );

    return result.isNotEmpty;
  }


  
}
