import 'package:flutter/material.dart';

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
