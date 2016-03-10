import {Robot, Response} from 'hubot'
import Config from './config/Twit'
const Twitter = require("twitter") // @todo d.ts

interface Tweet {
  id_str: number
  text: string
  user: {
    name: string
    screen_name: string
  }
  lang: string
}

module.exports = (robot: Robot<any>) => {

  const queue: Array<string> = []

  const send = () => {
    if (queue.length > 0) {
      const message = queue.shift()
      robot.messageRoom(Config.MENTION_ROOM, message)
    }
  }

  const fetch = () => {
    const client = new Twitter(Config.API_KEYS)
    const option = {
      track: 'docker,react,redux,electron,typescript,javascript,css',
    }
    client.stream('statuses/filter', option, (stream: any) => {
      stream.on('data', (tweet: Tweet) => {
        if (tweet.lang === 'ja') {
          const user = tweet.user
          const text = `${tweet.text} - ${user.name}@${user.screen_name}`
          const url = `http://twitter.com/${user.screen_name}/status/${tweet.id_str}`
          const message = `${text}\n${url}`
          queue.push(message)
        }
      })
      stream.on('error', (err: Error) => {
        console.log('Twitter Streaming API Error:')
        console.log(err)
        setTimeout(15000, fetch)
      })
    })
  }

  robot.brain.on('loaded', () => {
    fetch()
    setInterval(send, 1000 * 10)
  })
}
