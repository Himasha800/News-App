

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:news_app1/models/search_news_model.dart';
import 'package:news_app1/view/news_details_screen.dart';
import 'package:news_app1/view_model/news_view_model.dart';

class SearchNewsScreen extends StatefulWidget {
  const SearchNewsScreen({Key? key}) : super(key: key);

  @override
  _SearchNewsScreenState createState() => _SearchNewsScreenState();
}

class _SearchNewsScreenState extends State<SearchNewsScreen> {
  final _newsViewModel = NewsViewModel();
  String selectedNewsType = 'bbcNews'; 
  Future<SearchNewsModel>? _searchResults;
  TextEditingController _searchController = TextEditingController();
  final format = DateFormat('MMMM dd, yyyy'); 

  void _searchNews(String query) {
    setState(() {
      _searchResults = _newsViewModel.fetchNewsSearchApi(query, selectedNewsType).then((model) {
        model.articles = model.articles?.where((article) {
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
        return model;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 213, 196, 243), 
        title: Text(
          'Search News',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for news...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = null;
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchNews(value);
                } else {
                  setState(() {
                    _searchResults = null;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<SearchNewsModel>(
                future: _searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.articles!.isEmpty) {
                    return const Center(child: Text('No news found.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.articles!.length,
                      itemBuilder: (context, index) {
                        final article = snapshot.data!.articles![index];
                        DateTime dateTime = DateTime.parse(article.publishedAt.toString());

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsDetailsScreen(
                                    newsImage: article.urlToImage ?? '',
                                    newsTitle: article.title ?? 'No Title',
                                    newsDate: article.publishedAt ?? '',
                                    author: article.author ?? 'Unknown Author',
                                    description: article.description ?? '',
                                    content: article.content ?? '',
                                    source: article.source?.name ?? 'Unknown Source',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl: article.urlToImage ?? '',
                                      fit: BoxFit.cover,
                                      height: height * 0.18,
                                      width: width * 0.3,
                                      placeholder: (context, url) => const Center(
                                        child: SpinKitCircle(
                                          size: 50,
                                          color: Color.fromARGB(255, 89, 76, 175),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.title ?? 'No Title',
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${format.format(dateTime)} | ${article.source?.name ?? 'Unknown Source'}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
