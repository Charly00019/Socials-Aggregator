class TweetCard extends StatelessWidget {
  final dynamic tweet;

  TweetCard(this.tweet);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tweet['text']),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.favorite, size: 16),
                Text(tweet['public_metrics']['like_count'].toString()),
                SizedBox(width: 16),
                Icon(Icons.repeat, size: 16),
                Text(tweet['public_metrics']['retweet_count'].toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}