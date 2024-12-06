import { MediaLogger } from '../../../Index';
import { CcPlayer } from './CcPlayer';

const TAG = "[CcPlayerPool]"

/**
 * A cache manager to handle player list for list player.
 *
 * Author: Seagazer
 * Date: 2024/12/5
 */
export class CcPlayerPool {
    private static sInstance?: CcPlayerPool = undefined
    private idleCache = new Array<CcPlayer>()
    private runningCache = new Array<CcPlayer>()
    private context?: Context = undefined
    private cacheSize: number = 1

    private constructor() {
    }

    /**
     * Get the single instance of CcPlayerPool.
     * @returns The instance of CcPlayerPool.
     */
    public static getInstance(): CcPlayerPool {
        if (!CcPlayerPool.sInstance) {
            CcPlayerPool.sInstance = new CcPlayerPool()
        }
        return CcPlayerPool.sInstance
    }

    /**
     * Init the config of player pool.
     * @param context The context of application.
     * @param cacheSize The max size to cache player instances. If there is any idle player and the size of pool is more than cache size,
     * the idle player will be released and recycled.
     */
    public init(context: Context, cacheSize: number): void {
        MediaLogger.d(TAG, "set cache size= " + cacheSize)
        this.context = context
        this.cacheSize = cacheSize
    }

    /**
     * Get a player instance from pool.
     * @returns The instance of player.{@link CcPlayer}
     */
    public get(): CcPlayer {
        if (!this.context) {
            throw new Error("The context is null, must call #init first!")
        }
        let ideSize = this.idleCache.length
        if (ideSize > 0) {
            let idlePlayer = this.idleCache[0]
            this.idleCache.splice(0, 1)
            this.runningCache.push(idlePlayer)
            MediaLogger.d(TAG, "get player from cache")
            return idlePlayer
        } else {
            let player = new CcPlayer(this.context)
            this.runningCache.push(player)
            MediaLogger.d(TAG, "create new player, idle size= " + this.idleCache.length + ", running size= " + this.runningCache.length)
            return player
        }
    }

    /**
     * Release the player. This method will detach the player from running cache or recycle the instance.
     * @param player The instance of player.{@link CcPlayer}
     */
    public release(player: CcPlayer): void {
        if (player.isPlaying()) {
            player.stop()
        }
        player.reset()
        let index = this.runningCache.indexOf(player)
        if (index >= 0) {
            MediaLogger.d(TAG, "release the player= " + player)
            this.runningCache.splice(index, 1)
        }
        this.idleCache.push(player)
        this.checkSize()
    }

    private checkSize() {
        let totalSize = this.idleCache.length + this.runningCache.length
        if (totalSize > this.cacheSize) {
            let overSize = totalSize - this.cacheSize
            let recycleSize = Math.min(overSize, this.idleCache.length)
            for (let i = 0; i < recycleSize; i++) {
                let player = this.idleCache.shift()
                if (player) {
                    player.release()
                    MediaLogger.d(TAG, "recycle the player= " + player)
                }
            }
            MediaLogger.d(TAG, "recycle completed, idle size= " + this.idleCache.length + ", running size= " + this.runningCache.length)
        }
    }

    /**
     * Clear the pool. All the players will be released and recycle, call this method when app is destroy.
     */
    public clear() {
        MediaLogger.d(TAG, "clear the pool")
        this.idleCache.forEach((player) => {
            player.release()
        })
        this.runningCache.forEach((player) => {
            player.release()
        })
        this.idleCache = []
        this.runningCache = []
    }
}