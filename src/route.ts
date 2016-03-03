import {Robot} from 'hubot'

export = (robot: Robot<any>) => {

  robot.router.get('/', (req: any, res: any) => {
    res.type('html')
    res.send("Hubot Homepage")
  })
}
