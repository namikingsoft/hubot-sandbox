export default class TwitConfig {

  static MENTION_ROOM = process.env.TWIT_MENTION_ROOM || "#general"
  static MAX_FETCH_COUNT = 5
  static API_KEYS = {
    consumer_key: process.env.TWIT_CONSUMER_KEY,
    consumer_secret: process.env.TWIT_CONSUMER_SECRET,
    access_token: process.env.TWIT_ACCESS_TOKEN_KEY,
    access_token_secret: process.env.TWIT_ACCESS_TOKEN_SECRET,
  }
}
