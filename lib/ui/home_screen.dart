import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/post_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  List<PostModel> _posts = [];
  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      if (_currentPage < _totalPages) {
        _fetchPosts();
      }
    }
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?_start=$_currentPage&_limit=2'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<PostModel> fetchedPosts = [];
      for (var post in jsonData) {
        fetchedPosts.add(PostModel.fromJson(post));
      }

      setState(() {
        _posts.addAll(fetchedPosts);
        _currentPage++;
        _totalPages = response.headers['x-total-count'] != null
            ? (int.parse(response.headers['x-total-count']!) ~/ 2)
            : 1;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to fetch posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _posts.length,
            itemBuilder: (context, index) {
          if (index < _posts.length) {
            final post = _posts[index];
            return ListTile(
              title: Text(post.title),
              subtitle: Text(post.body),
              leading: Text(post.id.toString()),
            );
          }

          if (_currentPage < _totalPages) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator(),),
            );
          }

          return const SizedBox.shrink();
        }),
      ),
    );
  }


}
