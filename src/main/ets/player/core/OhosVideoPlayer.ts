import { MediaSource } from '../data/MediaSource';
import media from '@ohos.multimedia.media'
import { Logger } from '../common/Logger';
import { PlayerState } from '../config/PlayerState'
import { BasePlayer } from './BasePlayer';

const TAG = "OhosVideoPlayer"

/**
 * Video player impl for OpenHarmony 3.0+.
 * The process is: reset -> setMediaSource -> setSurface -> prepare -> play
 */
export class OhosVideoPlayer extends BasePlayer {
    private player: media.VideoPlayer = null
    private curSurfaceId: string = null
    private lastSurfaceId: string = null
    private isPlayed = false

    private constructor() {
        super()
        media.createVideoPlayer((err, data) => {
            if (err) {
                Logger.e(TAG, "init video player error = " + JSON.stringify(err))
            }
            this.changePlayerState(PlayerState.STATE_IDLE)
            this.player = data
            this.player.on("playbackCompleted", () => {
                Logger.i(TAG, "System callback: completed")
                this.stopProgressTimer()
                this.changePlayerState(PlayerState.STATE_COMPLETED)
                if (this.completedListeners.length > 0) {
                    this.completedListeners.forEach((callback) => {
                        callback()
                    })
                }
            })
            this.player.on("videoSizeChanged", (width: number, height: number) => {
                Logger.i(TAG, "System callback: videoSizeChanged: " + width + " x " + height)
                if (this.videoSizeChangedListeners.length > 0) {
                    this.videoSizeChangedListeners.forEach((callback) => {
                        callback(width, height)
                    })
                }
            })
            this.player.on("startRenderFrame", () => {
                Logger.i(TAG, "System callback: render first frame ")
                if (this.renderFirstFrameListeners.length > 0) {
                    this.renderFirstFrameListeners.forEach((callback) => {
                        callback()
                    })
                }
            })
            this.player.on("error", (error) => {
                Logger.i(TAG, "System callback: error ")
                if (this.errorListeners.length > 0) {
                    this.errorListeners.forEach((callback) => {
                        callback(error.code, error.message)
                    })
                }
            })
        })
    }

    static create(): OhosVideoPlayer {
        return new OhosVideoPlayer()
    }

    setMediaSource(mediaSource: MediaSource, onReady?: () => void) {
        Logger.d(TAG, "setMediaSource = " + JSON.stringify(mediaSource))
        if (this.isPlayed) {
            this.player.reset((err) => {
                if (this.unError(err)) {
                    this.setMediaSourceInner(mediaSource, onReady)
                }
            })
        } else {
            this.setMediaSourceInner(mediaSource, onReady)
        }
    }

    private setMediaSourceInner(mediaSource: MediaSource, onReady?: () => void) {
        if (this.curSurfaceId == null) {
            throw new Error("You must call setSurfaceId(surfaceId) before call this function.")
        }
        Logger.d(TAG, "set url = " + mediaSource.source)
        // the action set surface must between set url and prepare.
        this.player.url = mediaSource.source
        if (this.curSurfaceId != this.lastSurfaceId) {
            this.lastSurfaceId = this.curSurfaceId
            Logger.d(TAG, ">> set surface: " + this.curSurfaceId)
            this.player.setDisplaySurface(this.curSurfaceId, (err) => {
                if (this.unError(err)) {
                    if (onReady) {
                        onReady?.()
                    }
                }
            })
        } else {
            onReady?.()
        }
    }

    start() {
        Logger.d(TAG, ">> start")
        if (this.isPrepared == false) {
            this.player.prepare((err) => {
                if (this.unError(err)) {
                    Logger.i(TAG, "System callback: prepared")
                    this.isPrepared = true
                    this.changePlayerState(PlayerState.STATE_PREPARED)
                    if (this.preparedListeners.length > 0) {
                        this.preparedListeners.forEach((callback) => {
                            callback()
                        })
                    }
                    this.player.play((err) => {
                        Logger.i(TAG, "System callback: play")
                        if (this.unError(err)) {
                            this.isPlayed = true
                            this.changePlayerState(PlayerState.STATE_STARTED)
                            if (this.startPosition != -1) {
                                this.seekTo(this.startPosition)
                                this.startPosition = -1
                            }
                            this.startProgressTimer()
                        }
                    })
                }
            })
        } else {
            this.player.play((err) => {
                Logger.i(TAG, "System callback: play")
                if (this.unError(err)) {
                    this.changePlayerState(PlayerState.STATE_STARTED)
                    this.startProgressTimer()
                }
            })
        }
        super.start()
    }

    pause() {
        Logger.d(TAG, ">> pause")
        this.player.pause((err) => {
            Logger.i(TAG, "System callback: pause")
            if (this.unError(err)) {
                this.changePlayerState(PlayerState.STATE_PAUSED)
            }
        })
        super.pause()
    }

    stop() {
        Logger.d(TAG, ">> stop")
        this.player.stop((err) => {
            Logger.i(TAG, "System callback: stop")
            if (this.unError(err)) {
                this.changePlayerState(PlayerState.STATE_STOPPED)
            }
        })
        this.isPrepared = false
        super.stop()
    }

    reset() {
        Logger.d(TAG, ">> reset")
        this.player.reset((err) => {
            Logger.i(TAG, "System callback: reset")
            if (this.unError(err)) {
                this.changePlayerState(PlayerState.STATE_IDLE)
            }
        })
        this.isPrepared = false
        super.reset()
    }

    release() {
        Logger.d(TAG, ">> release")
        this.player.stop()
        this.player.release((err) => {
            Logger.i(TAG, "System callback: release")
            if (this.unError(err)) {
                this.changePlayerState(PlayerState.STATE_NOT_INIT)
            }
        })
        super.release()
    }

    seekTo(position: number) {
        Logger.d(TAG, ">> seek to: " + position)
        this.player.seek(position, (err, duration) => {
            Logger.i(TAG, "System callback: seek completed")
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
            if (this.volumeChangedListeners.length > 0) {
                this.volumeChangedListeners.forEach((callback) => {
                    callback()
                })
            }
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
            Logger.e(TAG, "system error = " + JSON.stringify(err))
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

    getSystemPlayer(): media.VideoPlayer {
        return this.player
    }
}