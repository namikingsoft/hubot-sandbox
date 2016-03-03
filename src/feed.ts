import {Robot, Response} from 'hubot'
import Config from './config/Feed'

const Request = require('request')
const FeedParser = require('feedparser')

interface Item {
  title: string
  link: string
}

interface Feed {
  name: string
  url: string
}

interface BrainData {
  feedList: Array<Feed>
  feedShownList: Array<string>
}

export = (robot: Robot<BrainData>) => {

  const queue: Array<string> = []

  const send = () => {
    if (queue.length > 0) {
      const message = queue.shift()
      robot.messageRoom(Config.MENTION_ROOM, message)
    }
  }

  const fetch = () => {
    const feedList = robot.brain.data.feedList
    let  shownList = robot.brain.data.feedShownList
    feedList.forEach((row: Feed, index: number) => {
      const request = Request({
        url: row.url,
        headers: {
          'User-Agent':
            'Opera/9.80 (Windows NT 5.1; U; ja) Presto/2.7.62 Version/11.01'
        },
      })
      request.on('error', (err: Error) => {
        console.log(`Error fetch url: ${err}`)
      })
      request.on('response', function(res: any) {
        const stream: any = this
        if (res.statusCode !== 200) {
          return stream.emit('error', new Error('Bad status code'))
        }
        stream.pipe(feedparser)
      })
      let fetchCount = 0
      const feedparser = new FeedParser
      feedparser.on('error', (err: Error) => {
        console.log(`Error fetch url: ${err}`)
      })
      feedparser.on('readable', function() {
        const stream: any = this
        const feed: string = stream.meta.title
        let item: Item
        while (item = stream.read()) {
          const title = item.title
          const link = item.link
          if (shownList.filter(x => x === link)) {
            shownList = shownList.filter(x => x !== link)
            shownList.push(link)
            continue
          }
          fetchCount++
          const message = `${title} - ${feed}\n${link}`
          queue.push(message)
          // add link on shown list
          shownList.push(link)
          while (shownList.length > Config.MAX_SHOWN_LIST_COUNT) {
            shownList.shift()
          }
          if (fetchCount >= Config.MAX_FETCH_COUNT) {
            break
          }
        }
        // save new shown list
        robot.brain.data.feedShownList = shownList
      })
    })
  }

  robot.brain.on('loaded', () => {
    if (!robot.brain.data.feedList) {
      robot.brain.data.feedList = []
    }
    if (robot.brain.data.feedShownList) {
      robot.brain.data.feedShownList = []
    }
    setInterval(send, 1000 * 10)
    setInterval(fetch, 1000 * 60)
  })

  robot.respond(/feed fetch/i, fetch)

  robot.respond(/feed reset/i, res => {
    robot.brain.data.feedList = []
    res.reply('OK. Search list was cleared')
  })

  robot.respond(/feed add ([a-zA-Z0-9_]+) (.*)/i, res => {
    const name = res.match[1]
    const url  = res.match[2]
    robot.brain.data.feedList.push({
      name,
      url,
    })
    res.reply(`Added: ${name} -> ${url}`)
  })

  robot.respond(/feed rm ([a-zA-Z0-9_]+)/i, res => {
    const name = res.match[1]
    robot.brain.data.feedList =
      robot.brain.data.feedList.filter(row => row.name !== name)
    res.reply(`Removed: ${name}`)
  })

  robot.respond(/feed list/i, res => {
    res.reply("\n" + JSON.stringify(robot.brain.data.feedList, null, '  '))
  })
}
