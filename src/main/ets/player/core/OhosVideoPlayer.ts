import { Logger } from '../helper/logger';
import { PlayerState } from './playerstate'
import { BasePlayer } from './baseplayer';
import media from '@ohos.multimedia.media'

const TAG = "OhosVideoPlayer"

/**
 * Video player for ohos.
 * reset -> setSurface/setDataSource -> prepare -> play
 */
export class OhosVideoPlayer extends BasePlayer {
    private player: media.VideoPlayer = null
    private curSurfaceId: string = null
    private lastSurfaceId: string = null

    private constructor() {
        super()
        media.createVideoPlayer((err, data) => {
            if (err) {
                Logger.e(TAG, "init video player error = " + JSON.stringify(err))
            }
            this.player = data
            this.player.on("playbackCompleted", () => {
                Logger.d(TAG, "System callback: completed")
                this.stopProgressTimer()
                this.changePlayerState(PlayerState.STATE_COMPLETED)
                if (this.completedListeners.length > 0) {
                    this.completedListeners.forEach((callback) => {
                        callback()
                    })
                }
            })
        })
    }

    static create(): OhosVideoPlayer{
        return new OhosVideoPlayer()
    }

    setDataSourceUrl(url: string) {
        this.setDataSourceFile(url)
    }

    setDataSourceFile(sourcePath: string) {
        this.player.reset((err) => {
            if (this.unError(err)) {
                if (this.curSurfaceId == null) {
                    throw new Error("You must call setSurfaceId(surfaceId) before call this function.")
                }
                if (this.curSurfaceId != this.lastSurfaceId) {
                    this.lastSurfaceId = this.curSurfaceId
                    Logger.d(TAG, ">> set surface: " + this.curSurfaceId)
                    this.player.setDisplaySurface(this.curSurfaceId, (err) => {
                        Logger.d(TAG, ">> set surface error: " + JSON.stringify(err))
                    })
                }
                this.player.url = sourcePath
            }
        })
    }

    start() {
        Logger.d(TAG, ">> start")
        if (this.isPrepared == false) {
            this.player.prepare((err) => {
                if (this.unError(err)) {
                    Logger.d(TAG, "System callback: prepared")
                    this.isPrepared = true
                    this.changePlayerState(PlayerState.STATE_PREPARED)
                    if (this.preparedListeners.length > 0) {
                        this.preparedListeners.forEach((callback) => {
                            callback()
                        })
                    }
                    this.player.play((err) => {
                        Logger.d(TAG, "System callback: play")
                        if (this.unError(err)) {
                            this.changePlayerState(PlayerState.STATE_STARTED)
                            if (this.startPosition != -1) {
                                this.seekTo(this.startPosition)
                                this.startPosition = -1
                            } else {
                                this.startProgressTimer()
                            }
                        }
                    })
                }
            })
        } else {
            this.player.play((err) => {
                Logger.d(TAG, "System callback: play")
                if (this.unError(err)) {
                    this.changePlayerState(PlayerState.STATE_STARTED)
                    this.startProgressTimer()
                }
            })
        }
    }

    startTo(position: number) {
        Logger.d(TAG, ">> start to: " + position)
        this.startPosition = position
        this.start()
    }

    pause() {
        Logger.d(TAG, ">> pause")
        this.player.pause((err) => {
            Logger.d(TAG, "System callback: pause")
            if (this.unError(err)) {
                this.changePlayerState(PlayerState.STATE_PAUSED)
                this.stopProgressTimer()
            }
        })
    }

    stop() {
        Logger.d(TAG, ">> stop")
        this.player.stop((err) => {
            Logger.d(TAG, "System callback: stop")
            this.isPrepared = false
            if (this.unError(err)) {
                this.changePlayerState(PlayerState.STATE_STOPPED)
                this.stopProgressTimer()
            }
        })
    }

    reset() {
        Logger.d(TAG, ">> reset")
        this.player.reset((err) => {
            Logger.d(TAG, "System callback: reset")
            this.isPrepared = false
            if (this.unError(err)) {
                this.changePlayerState(PlayerState.STATE_IDLE)
            }
        })
    }

    release() {
        Logger.d(TAG, ">> release")
        this.player.release((err) => {
            Logger.d(TAG, "System callback: release")
            if (this.unError(err)) {
                this.changePlayerState(PlayerState.STATE_IDLE)
            }
        })
        super.release()
    }

    seekTo(position: number) {
        Logger.d(TAG, ">> seek to: " + position)
        this.player.seek(position, (err, duration) => {
            Logger.d(TAG, "System callback: seek completed")
            if (this.unError(err)) {
                if (this.seekChangedListeners.length > 0) {
                    this.seekChangedListeners.forEach((callback) => {
                        callback(duration)
                    })
                }
            }
        })
    }

    setVolume(vol: number) {
        Logger.d(TAG, ">> set volume: " + vol)
        this.player.setVolume(vol, () => {

        })
    }

    setLooper(isLoop: boolean) {
        Logger.d(TAG, ">> set loop: " + isLoop)
        this.player.loop = isLoop
    }

    getDuration(): number {
        Logger.d(TAG, "duration = " + this.player.duration)
        return Math.floor(this.player.duration)
    }

    getCurrentPosition(): number {
        return Math.floor(this.player.currentTime)
    }

    getPlayerState(): PlayerState {
        Logger.d(TAG, "system state = " + this.player.state)
        return super.getPlayerState()
    }

    setSurface(surfaceId: string) {
        this.curSurfaceId = surfaceId
    }

    private unError(err): boolean {
        if (typeof (err) != "undefined") {
            this.changePlayerState(PlayerState.STATE_ERROR)
            this.isPrepared = false
            if (this.errorListeners.length > 0) {
                this.errorListeners.forEach((callback) => {
                    callback(err.code, err.message)
                })
            }
            return false
        }
        return true
    }
}