

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app1/utils/db_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class NewsDetailsScreen extends StatefulWidget {
  final String newsImage;
  final String newsTitle;
  final String newsDate;
  final String author;
  final String description;
  final String content;
  final String source;
  final bool isFavorite; 
  final bool isSaved; 

  const NewsDetailsScreen({
    Key? key,
    required this.newsImage,
    required this.newsTitle,
    required this.newsDate,
    required this.author,
    required this.description,
    required this.content,
    required this.source,
    this.isFavorite = false, 
    this.isSaved = false, 
  }) : super(key: key);

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  final DateFormat format = DateFormat('MMMM dd, yyyy');
  bool isFavorite = false;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite; 
    isSaved = widget.isSaved; 
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final dateTime = DateTime.tryParse(widget.newsDate) ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Favorite Icon
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: toggleFavorite,
          ),
          // Saved Icon
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? Colors.blue : Colors.black,
            ),
            onPressed: toggleSaved,
          ),
          // Share Icon
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: shareNews,
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: height * 0.45,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.newsImage.isNotEmpty ? widget.newsImage : '',
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          Container(
            height: height * 0.6,
            margin: EdgeInsets.only(top: height * 0.4),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.newsTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Source: ${widget.source}",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        format.format(dateTime),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Description",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.description.isNotEmpty
                        ? widget.description
                        : "No Description Available",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.content,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleFavorite() async {
    setState(() => isFavorite = !isFavorite);
    if (isFavorite) {
      await addToFavorites();
    } else {
      await removeFromFavorites();
    }
  }

  void toggleSaved() async {
    setState(() => isSaved = !isSaved);
    if (isSaved) {
      await saveNews();
    } else {
      await removeSavedNews();
    }
  }

  Future<void> addToFavorites() async {
    try {
      final newsData = {
        'title': widget.newsTitle,
        'source': widget.source,
        'image_url': widget.newsImage,
        'description': widget.description,
        'content': widget.content,
      };
      await DBHelper().insertNews(DBHelper().favoriteNewsTable, newsData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to Favorites")),
      );
    } catch (e) {
      debugPrint("Error adding to favorites: $e");
    }
  }

  Future<void> removeFromFavorites() async {
    try {
      await DBHelper().deleteNewsByTitle(
        DBHelper().favoriteNewsTable,
        widget.newsTitle,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from Favorites")),
      );
    } catch (e) {
      debugPrint("Error removing from favorites: $e");
    }
  }

  Future<void> saveNews() async {
    try {
      final newsData = {
        'title': widget.newsTitle,
        'source': widget.source,
        'image_url': widget.newsImage,
        'description': widget.description,
        'content': widget.content,
      };
      await DBHelper().insertNews(DBHelper().savedNewsTable, newsData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("News Saved")),
      );
    } catch (e) {
      debugPrint("Error saving news: $e");
    }
  }

  Future<void> removeSavedNews() async {
    try {
      await DBHelper().deleteNewsByTitle(
        DBHelper().savedNewsTable,
        widget.newsTitle,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed Saved News")),
      );
    } catch (e) {
      debugPrint("Error removing saved news: $e");
    }
  }


void shareNews() async {
   final newsUrl = "https://example.com/news?title=${Uri.encodeComponent(widget.newsTitle)}";
  try {
    if (widget.newsImage.isNotEmpty) {
      
      final tempDir = await getTemporaryDirectory();
      final imagePath = '${tempDir.path}/shared_image.jpg';

      final response = await http.get(Uri.parse(widget.newsImage));
      if (response.statusCode == 200) {
        final file = File(imagePath);
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles(
          [XFile(imagePath)],
          text: """
          Title: ${widget.newsTitle}

          Source: ${widget.source}

          Description: ${widget.description}

          Content: ${widget.content}

          Read more: $newsUrl

          Shared via NewsApp
          """,
        );
      } else {
        throw Exception("Failed to load image");
      }
    } else {
      
      final shareContent = """
        Title: ${widget.newsTitle}

        Source: ${widget.source}

        Description: ${widget.description}

        Content: ${widget.content}

        Shared via NewsApp
        """;

      await Share.share(shareContent);
    }

    
    await saveSharedNews();
  } catch (e) {
    debugPrint("Error sharing news: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to share news")),
    );
  }
}

Future<void> saveSharedNews() async {
  try {
    final newsData = {
      'title': widget.newsTitle,
      'source': widget.source,
      'image_url': widget.newsImage,
      'description': widget.description,
      'content': widget.content,
    };
  
    await DBHelper().insertNews(DBHelper().sharedNewsTable, newsData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Shared news saved to share list")),
    );
  } catch (e) {
    debugPrint("Error saving shared news: $e");
  }
}


}
