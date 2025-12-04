import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final String? userName;
  final String? profileImage;

  const DashboardScreen({
    super.key,
    this.userName,
    this.profileImage,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<dynamic> tweets = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimeline();
    });
  }

  /// -------------------------
  /// INITIALIZE DASHBOARD
  /// -------------------------
  Future<void> _loadTimeline() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "Not authenticated.";
          isLoading = false;
        });
        return;
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        setState(() {
          errorMessage = "Firebase token is null.";
          isLoading = false;
        });
        return;
      }

      await _fetchTweets(token);
    } catch (e) {
      setState(() {
        errorMessage = "Dashboard error: $e";
        isLoading = false;
      });
    }
  }

  /// -------------------------
  /// FETCH TWEETS FROM BACKEND
  /// -------------------------
  Future<void> _fetchTweets(String token) async {
    try {
      final user = _auth.currentUser!;
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/timeline?userId=${user.uid}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          tweets = body['tweets'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Server error: ${response.statusCode}\n${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error: $e";
        isLoading = false;
      });
    }
  }

  /// -------------------------
  /// TWEET CARD UI
  /// -------------------------
  Widget _buildTweetCard(dynamic tweet) {
    final user = tweet['user'] ?? {};
    final mediaList = tweet['media'] ?? [];

    String formattedTime = '';
    if (tweet['created_at'] != null) {
      final dt = DateTime.parse(tweet['created_at']).toLocal();
      formattedTime = DateFormat("MMM d, yyyy h:mm a").format(dt);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// User Row
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: user['profile_image'] != null
                      ? NetworkImage(user['profile_image'])
                      : null,
                  child: user['profile_image'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${user['name'] ?? 'Unknown'} @${user['handle'] ?? ''}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// Tweet Text
            Text(tweet['text'] ?? ""),
            const SizedBox(height: 8),

            /// Media Grid
            if (mediaList.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: mediaList.length,
                itemBuilder: (_, i) {
                  final media = mediaList[i];
                  if (media['type'] == 'photo') {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: media['url'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    );
                  } else if (media['type'] == 'video' ||
                      media['type'] == 'animated_gif') {
                    return Container(
                      color: Colors.black12,
                      child: const Center(
                        child: Icon(Icons.play_arrow, size: 40),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            const SizedBox(height: 8),

            /// Metrics & Timestamp
            Row(
              children: [
                const Icon(Icons.favorite, size: 16, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text("${tweet['metrics']?['like_count'] ?? 0}"),
                const SizedBox(width: 16),
                const Icon(Icons.repeat, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text("${tweet['metrics']?['retweet_count'] ?? 0}"),
                const Spacer(),
                Text(
                  formattedTime,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  /// -------------------------
  /// MAIN UI
  /// -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${widget.userName ?? 'User'}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : tweets.isEmpty
                  ? const Center(child: Text("No tweets found."))
                  : ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (_, i) => _buildTweetCard(tweets[i]),
                    ),
    );
  }
}
