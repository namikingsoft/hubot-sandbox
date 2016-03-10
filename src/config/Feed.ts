export default class FeedConfig {

  static MENTION_ROOM = process.env.FEED_MENTION_ROOM || "#feed"
  static MAX_FETCH_COUNT = 5
  static MAX_SHOWN_LIST_COUNT = 1000
}
