import { TwitterApi } from 'twitter-api-v2';

/**
 * Builds a Twitter client from a stored user account
 */
export function twitterClientFromAccount(accountDoc) {
  // If you stored oauth1 tokens:
  if (accountDoc.tokenType === 'oauth1') {
    return new TwitterApi({
      appKey: process.env.TWITTER_CONSUMER_KEY,
      appSecret: process.env.TWITTER_CONSUMER_SECRET,
      accessToken: accountDoc.accessToken,
      accessSecret: accountDoc.accessSecret,
    });
  }

  // If you stored OAuth2 user tokens (OAuth2 PKCE)
  if (accountDoc.tokenType === 'oauth2') {
    return new TwitterApi({
      clientId: process.env.TWITTER_CONSUMER_KEY,
      clientSecret: process.env.TWITTER_CONSUMER_SECRET,
      accessToken: accountDoc.accessToken,
      refreshToken: accountDoc.refreshToken,
    });
  }

  // fallback: app-only bearer token (read-only)
  return new TwitterApi(process.env.TWITTER_BEARER_TOKEN);
}

/**
 * Fetch user timeline using Twitter API v2 and return a unified format
 */
export async function fetchTwitterTimeline(accountDoc, opts = {}) {
  const client = twitterClientFromAccount(accountDoc);
  const rwClient = client.readOnly; // read-only context

  const userId = accountDoc.providerUserId;

  const params = {
    max_results: opts.max_results || 20,
    'tweet.fields': 'created_at,public_metrics,attachments,entities,conversation_id',
    expansions: 'attachments.media_keys,author_id',
    'media.fields': 'url,type,preview_image_url',
    'user.fields': 'profile_image_url,username,name',
  };

  try {
    const resp = await rwClient.v2.userTimeline(userId, params);

    const tweets = [];
    for await (const t of resp) {
      tweets.push({
        source: 'twitter',
        id: t.id,
        text: t.text,
        created_at: t.created_at,
        user: {
          id: t.author_id,
          name: (t.author && t.author.name) || accountDoc.displayName,
          handle: (t.author && t.author.username) || accountDoc.handle,
          profile_image: (t.author && t.author.profile_image_url) || accountDoc.profileImage,
        },
        media:
          t.attachments && t.attachments.media
            ? t.attachments.media.map((m) => ({
                type: m.type,
                url: m.url || m.preview_image_url,
              }))
            : [],
        metrics: t.public_metrics || {},
      });
    }

    return tweets;
  } catch (err) {
    console.error('Twitter v2 timeline error', err);
    return [];
  }
}

/**
 * Post a tweet on behalf of the authenticated user
 */
export async function postTweet(accountDoc, text) {
  if (!text || text.trim() === '') throw new Error('Tweet text cannot be empty');

  const client = twitterClientFromAccount(accountDoc);
  const rwClient = client.readWrite;

  try {
    const response = await rwClient.v2.tweet(text);
    return response;
  } catch (err) {
    console.error('Error posting tweet', err);
    throw err;
  }
}

// Named exports for backend routes
export const getTimeline = fetchTwitterTimeline;
