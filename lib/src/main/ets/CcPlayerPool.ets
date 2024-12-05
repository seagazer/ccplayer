import { CcPlayer } from './CcPlayer';

/**
 * A cache manager to handle player list for list player.
 *
 * Author: Seagazer
 * Date: 2024/12/5
 */
export class CcPlayerPool {
    private static sInstance?: CcPlayerPool = undefined
    private idleCache = new Array<CcPlayer>()
    private playingCache = new Array<CcPlayer>()
    private context?: Context = undefined

    private constructor() {
    }

    public static getInstance(): CcPlayerPool {
        if (!CcPlayerPool.sInstance) {
            CcPlayerPool.sInstance = new CcPlayerPool()
        }
        return CcPlayerPool.sInstance
    }

    public init(context: Context) {
        this.context = context
    }

    public get(): CcPlayer {
        if (!this.context) {
            throw new Error("The context is null, must call #init first!")
        }
        let ideSize = this.idleCache.length
        if (ideSize > 0) {
            let player = this.idleCache[0]
            this.idleCache.splice(0, 1)
            this.playingCache.push(player)
            return player
        } else {
            let player = new CcPlayer(this.context)
            this.playingCache.push(player)
            return player
        }
    }

    public release(player: CcPlayer): void {
        if (player.isPlaying()) {
            player.stop()
        }
        player.reset()
        let index = this.playingCache.indexOf(player)
        if (index >= 0) {
            this.playingCache.splice(index, 1)
        }
        this.idleCache.push(player)
    }

    public clear() {
        this.idleCache.forEach((player) => {
            player.release()
        })
        this.playingCache.forEach((player) => {
            player.release()
        })
    }
}