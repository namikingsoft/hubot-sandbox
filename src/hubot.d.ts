declare module "hubot" {

  export interface Robot<D> {
    listen(
      regex: RegExp,
      options: {[key: string]: any} | ((res: Response) => void),
      callback?: (res: Response) => void
    ): void
    hear(
      regex: RegExp,
      options: {[key: string]: any} | ((res: Response) => void),
      callback?: (res: Response) => void
    ): void
    respond(
      regex: RegExp,
      options: {[key: string]: any} | ((res: Response) => void),
      callback?: (res: Response) => void
    ): void
    send(user: string, ...string: string[]): void
    reply(user: string, ...string: string[]): void
    messageRoom(room: string, ...string: string[]): void
    brain: Brain<D>
    router: any // @todo
  }

  export interface Response {
    match: Array<string>
    send(...strings: string[]): void
    emote(...strings: string[]): void
    reply(...strings: string[]): void
    topic(...strings: string[]): void
    play(...strings: string[]): void
    locked(...strings: string[]): void
    random(items: any[]): any
    finish(): void
  }

  export interface Brain<D> {
    data: D
    on(name: string, callback: Function): void
  }
}
