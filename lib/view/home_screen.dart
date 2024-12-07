
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:news_app1/models/categories_news_model.dart';
import 'package:news_app1/models/news_channel_headlines_model.dart';
import 'package:news_app1/news_provider.dart';
import 'package:news_app1/view/categories_screen.dart';
import 'package:news_app1/view/favorites_list_screen.dart';
import 'package:news_app1/view/news_details_screen.dart';
import 'package:news_app1/view/save_list_screen.dart';
import 'package:news_app1/view/search_news_screen.dart';
import 'package:news_app1/view/share_list_screen.dart';
import 'package:news_app1/view_model/news_view_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum FilterList { bbcNews, abcNews, aftenposten, aryNews, axios, cnn, cbcNews }

class _HomeScreenState extends State<HomeScreen> {
  NewsViewModel newsViewModel = NewsViewModel();
  FilterList? selectedMenu;
  
  final format = DateFormat('MMMM dd, yyyy');

  String name = 'bbc-news';
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 1 ;
    final height = MediaQuery.sizeOf(context).height * 1 ;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen()));
          },
          icon: Image.asset(
            'images/category_icon.png',
            height: 30,
            width: 30,
          ),
        ),
        title: Text(
          'News',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchNewsScreen()), 
              );
            },
          ),
         PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert, color: Colors.black),
  onSelected: (String choice) {
    if (choice == 'Saved News') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SaveListScreen()), 
      );
    } else if (choice == 'Favorite News') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FavoritesListScreen()), 
      );
    } else if (choice == 'Shared News') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ShareListScreen()), 
      );
    }
  },
  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
    const PopupMenuItem<String>(
      value: 'Saved News',
      child: Text('Saved News'),
    ),
    const PopupMenuItem<String>(
      value: 'Favorite News',
      child: Text('Favorite News'),
    ),
    const PopupMenuItem<String>(
      value: 'Shared News',
      child: Text('Shared News'),
    ),
  ],
)

        ],
      ),
      body: ListView(
        children: [
         

SizedBox(
  height: height * .6, 
  width: width,
  child: FutureBuilder<NewsChannelsHeadlinesModel>(
    future: newsViewModel.fetchNewsChannelHeadlinesApi(name),
    builder: (BuildContext context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: SpinKitCircle(
            size: 50,
            color: Color.fromARGB(255, 89, 76, 175),
          ),
        );
      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.articles == null) {
        return Center(
          child: Text(
            'Error loading news',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
        );
      } else {
        int _currentIndex = 0; 
        ValueNotifier<int> pageNotifier = ValueNotifier<int>(_currentIndex);

        return Column(
          children: [
            CarouselSlider.builder(
              itemCount: snapshot.data!.articles!.length,
              itemBuilder: (context, index, realIndex) {
                final article = snapshot.data!.articles![index];
                DateTime dateTime = DateTime.parse(article.publishedAt.toString());

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailsScreen(
                          newsImage: article.urlToImage.toString(),
                          newsTitle: article.title.toString(),
                          newsDate: article.publishedAt.toString(),
                          author: article.author.toString(),
                          description: article.description.toString(),
                          content: article.content.toString(),
                          source: article.source?.name.toString() ?? 'Unknown Source',
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: height * 0.6,
                        width: width * .9,
                        padding: EdgeInsets.symmetric(
                          horizontal: height * .02,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: article.urlToImage.toString(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => spinKit2,
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        child: Card(
                          elevation: 5,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            padding: const EdgeInsets.all(15),
                            height: height * .22,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: width * 0.7,
                                  child: Text(
                                    article.title.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: width * 0.7,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        article.source!.name.toString(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        format.format(dateTime),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              options: CarouselOptions(
                height: height * .55,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                viewportFraction: 0.9,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  pageNotifier.value = index;
                },
              ),
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<int>(
              valueListenable: pageNotifier,
              builder: (context, value, child) {
                return SmoothPageIndicator(
                  controller: PageController(initialPage: value), 
                  count: snapshot.data!.articles!.length,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Color.fromARGB(255, 89, 76, 175),
                    dotHeight: 8,
                    dotWidth: 8,
                    dotColor: Color.fromARGB(255, 113, 113, 113),
                  ),
                );
              },
            ),
          ],
        );
      }
    },
  ),
),






Padding(
  padding: const EdgeInsets.all(20),
  child: SingleChildScrollView(
    child: FutureBuilder<CategoriesNewsModel>(
      future: newsViewModel.fetchNewsCategoriesNewsApi('General'),
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              DateTime dateTime = DateTime.parse(
                snapshot.data!.articles![index].publishedAt.toString(),
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailsScreen(
                          newsImage: snapshot.data!.articles![index].urlToImage.toString(),
                          newsTitle: snapshot.data!.articles![index].title.toString(),
                          newsDate: snapshot.data!.articles![index].publishedAt.toString(),
                          author: snapshot.data!.articles![index].author.toString(),
                          description: snapshot.data!.articles![index].description.toString(),
                          content: snapshot.data!.articles![index].content.toString(),
                          source: snapshot.data!.articles![index].source?.name.toString() ?? 'Unknown Source',
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
                            height: height * 0.16,
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
)],



      
      ),
    );
  }
}

const spinKit2 = SpinKitFadingCircle(
  color: Colors.amber,
  size: 50,
);
        



