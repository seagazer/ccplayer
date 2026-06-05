import { MediaLogger } from '@seagazer/ccplayer-base';
import { CcPlayer } from './CcPlayer';

const TAG = "[CcPlayerPool]"

/**
 * A manager to handle many instances of CcPlayer, can auto create or recycle instance.
 *
 * Author: Seagazer
 * Date: 2024/12/5
 */
export class CcPlayerPool {
    private static sInstance?: CcPlayerPool = undefined
    private idleCache = new Array<ReuseCcPlayer>()
    private runningCache = new Array<ReuseCcPlayer>()
    private context?: Context = undefined
    private cacheSize: number = 1
    private createCount: number = 0

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
            MediaLogger.d(TAG, "get player from cache= " + idlePlayer.id)
            return idlePlayer
        } else {
            let id = this.generateId()
            let player = new ReuseCcPlayer(this.context, id)
            MediaLogger.d(TAG, "create new player= " + player.id)
            this.createCount++
            this.runningCache.push(player)
            MediaLogger.d(TAG, "Cache size: idle= " + this.idleCache.length + ", running= " + this.runningCache.length)
            return player
        }
    }

    private generateId(): string {
        let timestamp = new Date().getTime()
        return timestamp + "_" + this.createCount
    }

    /**
     * Release the player. This method will detach the player from running cache or recycle the instance.
     * @param player The instance of player.{@link CcPlayer}
     */
    public async recycle(player: CcPlayer): Promise<void> {
        if (!(player instanceof ReuseCcPlayer)) {
            MediaLogger.attentionW(TAG, "The instance of player is not get from CcPlayerPool.")
            return
        }
        const innerPlayer = player as ReuseCcPlayer
        const index = this.runningCache.indexOf(innerPlayer)
        if (index < 0) {
            MediaLogger.attentionW(TAG, "The player is not in running cache, skip recycle.")
            return
        }

        this.runningCache.splice(index, 1)
        MediaLogger.d(TAG, "detach player from running cache= " + innerPlayer.id)

        try {
            if (innerPlayer.isPlaying()) {
                await innerPlayer.stop()
            }
            await innerPlayer.reset()
            this.idleCache.push(innerPlayer)
            MediaLogger.d(TAG, "recycle the player= " + innerPlayer.id)
            await this.checkSize()
        } catch (e) {
            MediaLogger.attentionE(TAG, "recycle player error= " + JSON.stringify(e))
            try {
                await innerPlayer.release()
            } catch (releaseErr) {
                MediaLogger.attentionE(TAG, "release failed during recycle error= " + JSON.stringify(releaseErr))
            }
        }
    }

    private async checkSize() {
        const totalSize = this.idleCache.length + this.runningCache.length
        if (totalSize > this.cacheSize) {
            const overSize = totalSize - this.cacheSize
            const recycleSize = Math.min(overSize, this.idleCache.length)
            for (let i = 0; i < recycleSize; i++) {
                const player = this.idleCache.shift()
                if (player) {
                    await player.release()
                    MediaLogger.d(TAG, "recycle the player= " + player.id)
                }
            }
            MediaLogger.d(TAG, "Cache size: idle= " + this.idleCache.length + ", running= " + this.runningCache.length)
        }
    }

    /**
     * Destroy the pool. All the players will be released and recycle, call this method when app is destroy.
     */
    public destroy() {
        MediaLogger.d(TAG, "clear the pool")
        this.idleCache.forEach((player) => {
            player.release()
        })
        this.runningCache.forEach((player) => {
            player.release()
        })
        this.idleCache = []
        this.runningCache = []
        this.createCount = 0
        CcPlayerPool.sInstance = undefined
    }
}

class ReuseCcPlayer extends CcPlayer {
    id: string

    constructor(context: Context, id: string) {
        super(context)
        this.id = id
    }
}