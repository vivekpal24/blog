import 'dart:io';
import 'package:blog/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'blog_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.orange,
      ),
      home: const MyHomePage(title: 'Blog Explorer Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LikedBlogsManager likedBlogsManager = LikedBlogsManager();
  List<Map<String, dynamic>> blogData = [];

  // Add a GlobalKey for the RefreshIndicator
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Fetch blogs when the app starts
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    final url = Uri.parse('https://intent-kit-16.hasura.app/api/rest/blogs');
    final adminSecret =
        '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';

    try {
      final response = await http.get(
        url,
        headers: {
          'x-hasura-admin-secret': adminSecret,
        },
      );

      if (response.statusCode == 200) {
        // Successfully fetched data.
        final List<dynamic> data = json.decode(response.body)['blogs'];

        setState(() {
          blogData = List<Map<String, dynamic>>.from(data);
        });
      } else {
        // Handle errors
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      // Handle network errors or exceptions
      print('Error: $error');
    }
  }


  void _navigateToBlogDetail(Map<String, dynamic> blog) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlogDetailPage(blogData: blog),
      ),
    );
  }

  void _navigateToLikedBlogs(BuildContext context, LikedBlogsManager likedBlogsManager) {
    final likedBlogs = blogData
        .where((blog) => blog['index'] != null && likedBlogsManager.isBlogLiked(blog['index']))
        .toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LikedBlogsPage(
          likedBlogs: likedBlogs,
          likedBlogsManager: likedBlogsManager,
        ),
      ),
    );
  }



  Future<void> _refreshData() async {
    // Simulate a network request or any data fetching operation.
    await Future.delayed(Duration(seconds: 2));

    // Replace this with your actual data fetching logic.
    fetchBlogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              _navigateToLikedBlogs(context, likedBlogsManager);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Vivek pal"),
              accountEmail: Text("vivekpal2407@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.purple,
                  size: 40.0,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
            ),
            ListTile(
              title: Text('Log In'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Feedback'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          child: ListView.builder(
            itemCount: blogData.length,
            itemBuilder: (ctx, index) {
              final blog = blogData[index];
              final blogId = blog['id'].toString();

              return GestureDetector(
                onTap: () {
                  _navigateToBlogDetail(blog);
                },
                child: BlogCard(
                  title: blog['title'] as String,
                  imageUrl: blog['image_url'] as String,
                  isLiked: likedBlogsManager.isBlogLiked(blogId),
                  onToggleLike: () {
                    likedBlogsManager.toggleLikeBlog(blogId);
                    setState(() {});
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

  class LikedBlogsManager {
  final Set<String> likedBlogIds = Set();

  // Check if a blog is liked
  bool isBlogLiked(String blogId) {
    return likedBlogIds.contains(blogId);
  }

  // Like or unlike a blog
  void toggleLikeBlog(String blogId) {
    if (likedBlogIds.contains(blogId)) {
      likedBlogIds.remove(blogId);
    } else {
      likedBlogIds.add(blogId);
    }
    saveLikedBlogs();
  }

  // Load liked blog IDs from persistent storage
  Future<void> loadLikedBlogs() async {
    final prefs = await SharedPreferences.getInstance();
    final likedBlogIdsList = prefs.getStringList('likedBlogIds') ?? [];
    likedBlogIds.addAll(likedBlogIdsList);
  }

  // Save liked blog IDs to persistent storage
  Future<void> saveLikedBlogs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('likedBlogIds', likedBlogIds.toList());
  }
}

class BlogCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isLiked;
  final VoidCallback onToggleLike;

  BlogCard({
    required this.title,
    required this.imageUrl,
    required this.isLiked,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
                onPressed: () {
                  onToggleLike();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// class LikedBlogsManager {
//   final Set<String> likedBlogIds = Set();
//
//   // Check if a blog is liked
//   bool isBlogLiked(String blogId) {
//     return likedBlogIds.contains(blogId);
//   }
//
//   // Like or unlike a blog
//   void toggleLikeBlog(String blogId) {
//     if (likedBlogIds.contains(blogId)) {
//       likedBlogIds.remove(blogId);
//     } else {
//       likedBlogIds.add(blogId);
//     }
//   }
// }

class BlogDetailPage extends StatelessWidget {
  final Map<String, dynamic> blogData;

  BlogDetailPage({required this.blogData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(blogData['title'] as String),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(blogData['image_url'] as String),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                blogData['title'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            // Add additional details about the blog post here
          ],
        ),
      ),
    );
  }
}

class LikedBlogsPage extends StatelessWidget {
  final List<Map<String, dynamic>> likedBlogs;
  final LikedBlogsManager likedBlogsManager;

  LikedBlogsPage({required this.likedBlogs, required this.likedBlogsManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Blogs'),
      ),
      body: ListView.builder(
        itemCount: likedBlogs.length,
        itemBuilder: (ctx, index) {
          final blog = likedBlogs[index];
          return BlogCard(
            title: blog['title'] as String,
            imageUrl: blog['image_url'] as String,
            isLiked: true,
            onToggleLike: () {
              // You can add the logic to remove the blog from the liked list here
              likedBlogsManager.toggleLikeBlog(blog['id'].toString()); // Pass the blog ID as a string
              likedBlogs.removeAt(index); // Remove the blog from the likedBlogs list
              Navigator.of(context).pop(); // Navigate back to the previous page
            },
          );
        },
      ),
    );
  }
}

