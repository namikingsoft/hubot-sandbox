import {Robot, Response} from 'hubot'
import Config from './config/Twit'
const Twitter = require("twitter") // @todo d.ts

interface FetchData {
  statuses: Array<Tweet>
}

interface Tweet {
  id_str: number
  text: string
  user: {
    name: string
    screen_name: string
  }
}

interface Search {
  name: string
  text: string
  sinceId: number
}

interface BrainData {
  searchList: Array<Search>
}

module.exports = (robot: Robot<BrainData>) => {

  const queue: Array<string> = []

  const send = () => {
    if (queue.length > 0) {
      const message = queue.shift()
      robot.messageRoom(Config.MENTION_ROOM, message)
    }
  }

  const fetch = () => {
    const client = new Twitter(Config.API_KEYS)
    const searchList = robot.brain.data.searchList
    searchList.forEach((search: Search, index: number) => {
      const param = {
        q: search.text,
        count: Config.MAX_FETCH_COUNT,
        since_id: search.sinceId,
      }
      client.get('search/tweets', param, (err: Error, data: FetchData) => {
        const tweets = data.statuses
        if (err) {
          const message = JSON.stringify(err, null, '  ')
          console.log(`Error getting tweets: ${message}`)
          return
        }
        if (tweets.length === 0) {
          return
        }
        search.sinceId = tweets[0].id_str
        robot.brain.data.searchList[index] = search
        tweets.reverse().forEach(tweet => {
          const user = tweet.user
          const text = `${tweet.text} - ${user.name}@${user.screen_name}`
          const url = `http://twitter.com/${user.screen_name}/status/${tweet.id_str}`
          const message = `${text}\n${url}`
          queue.push(message)
        })
      })
    })
  }

  robot.brain.on('loaded', () => {
    if (!robot.brain.data.searchList) {
      robot.brain.data.searchList = []
    }
    setInterval(fetch, 1000 * 30)
    setInterval(send, 1000 * 10)
  })

  robot.respond(/twit fetch/i, fetch)

  robot.respond(/twit reset/i, res => {
    robot.brain.data.searchList = []
    res.reply("OK. Search list was cleared")
  })

  robot.respond(/twit add ([a-zA-Z0-9_]+) (.*)/i, res => {
    const name = res.match[1]
    const text = res.match[2]
    robot.brain.data.searchList.push({
      name,
      text,
      sinceId: 1,
    })
    res.reply(`Added: ${name} -> ${text}`)
  })

  robot.respond(/twit rm ([a-zA-Z0-9_]+)/i, res => {
    name = res.match[1]
    robot.brain.data.searchList =
      robot.brain.data.searchList.filter((x: Search) => x.name != name)
    res.reply(`Removed: ${name}`)
  })

  robot.respond(/twit list/i, res => {
    res.reply("\n" + JSON.stringify(robot.brain.data.searchList, null, '  '))
  })
}
