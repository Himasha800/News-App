

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:news_app1/models/categories_news_model.dart';
import 'package:news_app1/view/news_details_screen.dart';
import 'package:news_app1/view_model/news_view_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  NewsViewModel newsViewModel = NewsViewModel();

  final format = DateFormat('MMMM dd, yyyy');
  String categoryName = 'general';

  List<String> categoriesList = [
    'General',
    'Health',
    'Sports',
    'Entertainment',
    'Business',
    'Technology',
    'Science'
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoriesList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        categoryName = categoriesList[index];
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryName == categoriesList[index]
                              ? const Color.fromARGB(255, 179, 99, 206)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Center(
                            child: Text(
                              categoriesList[index],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<CategoriesNewsModel>(
                future: newsViewModel.fetchNewsCategoriesNewsApi(categoryName),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SpinKitCircle(
                        size: 50,
                        color: Color.fromARGB(255, 89, 76, 175),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading news',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.articles == null) {
                    return Center(
                      child: Text(
                        'No news available',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.articles!.length,
                      itemBuilder: (context, index) {
                        DateTime dateTime = DateTime.parse(
                          snapshot.data!.articles![index].publishedAt.toString(),
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to NewsDetailsScreen 
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsDetailsScreen(
                                    newsImage: snapshot.data!.articles![index].urlToImage ?? '',
                                    newsTitle: snapshot.data!.articles![index].title ?? 'No Title',
                                    newsDate: snapshot.data!.articles![index].publishedAt ?? '',
                                    author: snapshot.data!.articles![index].author ?? 'Unknown Author',
                                    description: snapshot.data!.articles![index].description ?? '',
                                    content: snapshot.data!.articles![index].content ?? '',
                                    source: snapshot.data!.articles![index].source?.name ?? 'Unknown Source',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 155, 152, 152),
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data!.articles![index].urlToImage.toString(),
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
                                            snapshot.data!.articles![index].title ?? 'No Title',
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
                                            '${format.format(dateTime)} | ${snapshot.data!.articles![index].source?.name ?? 'Unknown Source'}',
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
