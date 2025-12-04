// lib/tweets.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TweetsPage extends StatefulWidget {
  @override
  _TweetsPageState createState() => _TweetsPageState();
}

class _TweetsPageState extends State<TweetsPage> {
  late Future<Map<String,dynamic>> _timelineFuture;

  @override
  void initState() {
    super.initState();
    _timelineFuture = fetchTimeline();
  }

  Future<Map<String,dynamic>> fetchTimeline() async {
    final uri = Uri.parse('https://your.backend.api/timeline');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load tweets');
    }
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Timeline')),
      body: FutureBuilder<Map<String,dynamic>>(
        future: _timelineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final timelineJson = snapshot.data!;
          final tweets = timelineJson['data'] as List<dynamic>? ?? [];
          final includes = timelineJson['includes'] as Map<String,dynamic>? ?? {};
          final mediaList = (includes['media'] as List<dynamic>?) ?? [];
          final usersList = (includes['users'] as List<dynamic>?) ?? [];
          // Build lookup maps
          final mediaMap = { for (var m in mediaList) m['media_key']: m };
          final userMap = { for (var u in usersList) u['id']: u };

          return ListView.builder(
            itemCount: tweets.length,
            itemBuilder: (context, index) {
              final tweet = tweets[index] as Map<String,dynamic>;
              final author = userMap[tweet['author_id']] as Map<String,dynamic>?;
              final text = tweet['text'] as String? ?? '';
              final created = tweet['created_at'] as String? ?? '';
              final metrics = tweet['public_metrics'] as Map<String,dynamic>? ?? {};
              final likeCount = metrics['like_count'] ?? 0;
              final retweetCount = metrics['retweet_count'] ?? 0;

              // Collect media URLs for this tweet
              List<String> mediaUrls = [];
              if (tweet.containsKey('attachments')) {
                final keys = (tweet['attachments']['media_keys'] as List<dynamic>?) ?? [];
                for (var mk in keys) {
                  final media = mediaMap[mk];
                  if (media != null) {
                    // For photos: 'url'; for videos/GIFs: use 'preview_image_url'
                    final type = media['type'];
                    final url = media['url'] ??
                                media['preview_image_url'] ??
                                '';
                    if (url.isNotEmpty) mediaUrls.add(url);
                  }
                }
              }

              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (author != null)
                        Text(
                          author['name'] + ' @' + author['username'],
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                      SizedBox(height: 4),
                      Text(text),
                      SizedBox(height: 8),
                      // Display images (if any)
                      for (var url in mediaUrls)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Image.network(url),
                        ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.favorite, size: 16, color: Colors.red),
                          SizedBox(width:4),
                          Text(likeCount.toString()),
                          SizedBox(width:16),
                          Icon(Icons.repeat, size: 16),
                          SizedBox(width:4),
                          Text(retweetCount.toString()),
                          Spacer(),
                          Text(created, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
