import media from '@ohos.multimedia.media';
import { BasePlayer } from './BasePlayer';
import { BusinessError } from '@kit.BasicServicesKit';
import { MediaLogger, MediaSource, PlayerState } from '@seagazer/ccplayer-base';

const TAG = "[OhosVideoPlayer]"

/**
 * Video player impl for OpenHarmony 3.0+.
 * The process is: reset -> setMediaSource -> setSurface -> prepare -> play
 *
 * Author: Seagazer
 * Date: 2022/3/17
 *
 * @deprecated since v1.0.4
 */
export class OhosVideoPlayerImpl extends BasePlayer {
    private player: media.VideoPlayer | null = null
    private curSurfaceId: string | null = null
    private lastSurfaceId: string | null = null
    private isPlayed = false

    private constructor() {
        super()
        media.createVideoPlayer((err, data) => {
            if (err) {
                MediaLogger.e(TAG, "init video player error = " + JSON.stringify(err))
            }
            this.changePlayerState(PlayerState.STATE_IDLE)
            this.player! = data
            this.player!.on("playbackCompleted", () => {
                MediaLogger.d(TAG, "System callback: completed")
                this.stopProgressTimer()
                this.changePlayerState(PlayerState.STATE_COMPLETED)
                if (this.completedListeners.length > 0) {
                    this.completedListeners.forEach((callback) => {
                        callback()
                    })
                }
            })
            this.player!.on("videoSizeChanged", (width: number, height: number) => {
                MediaLogger.d(TAG, "System callback: videoSizeChanged: " + width + " x " + height)
                if (this.videoSizeChangedListeners.length > 0) {
                    this.videoSizeChangedListeners.forEach((callback) => {
                        callback(width, height)
                    })
                }
            })
            this.player!.on("startRenderFrame", () => {
                MediaLogger.d(TAG, "System callback: render first frame ")
                if (this.renderFirstFrameListeners.length > 0) {
                    this.renderFirstFrameListeners.forEach((callback) => {
                        callback()
                    })
                }
            })
            this.player!.on("error", (error) => {
                MediaLogger.e(TAG, "System callback: error ")
                if (this.errorListeners.length > 0) {
                    this.errorListeners.forEach((callback) => {
                        callback(error.code, error.message)
                    })
                }
            })
        })
    }

    static create(): OhosVideoPlayerImpl {
        return new OhosVideoPlayerImpl()
    }

    async setMediaSource(mediaSource: MediaSource, onReady?: () => void) {
        MediaLogger.d(TAG, "setMediaSource = " + JSON.stringify(mediaSource))
        if (this.isPlayed) {
            try {
                await this.player!.reset()
                this.setMediaSourceInner(mediaSource, onReady)
            } catch (err) {
                this.checkError(err)
            }
        } else {
            this.setMediaSourceInner(mediaSource, onReady)
        }
    }

    private async setMediaSourceInner(mediaSource: MediaSource, onReady?: () => void) {
        if (this.curSurfaceId == null) {
            throw new Error("You must call setSurfaceId(surfaceId) before call this function.")
        }
        MediaLogger.d(TAG, "set url = " + mediaSource.url)
        // the action set surface must between set url and prepare.
        this.player!.url = mediaSource.url!
        if (this.curSurfaceId != this.lastSurfaceId) {
            this.lastSurfaceId = this.curSurfaceId
            MediaLogger.d(TAG, ">> set surface: " + this.curSurfaceId)
            try {
                await this.player!.setDisplaySurface(this.curSurfaceId)
                if (onReady) {
                    onReady?.()
                }
            } catch (err) {
                this.checkError(err)
            }
        } else {
            onReady?.()
        }
    }

    async start() {
        MediaLogger.d(TAG, ">> start")
        if (this.isPrepared == false) {
            try {
                await this.player!.prepare()
                MediaLogger.d(TAG, "System callback: prepared")
                this.isPrepared = true
                this.changePlayerState(PlayerState.STATE_PREPARED)
                if (this.preparedListeners.length > 0) {
                    this.preparedListeners.forEach((callback) => {
                        callback()
                    })
                }
                await this.player!.play()
                MediaLogger.d(TAG, "System callback: play")
                this.isPlayed = true
                this.changePlayerState(PlayerState.STATE_STARTED)
                if (this.startPosition != -1) {
                    this.seekTo(this.startPosition)
                    this.startPosition = -1
                }
                this.startProgressTimer()
                super.start()
            } catch (err) {
                this.checkError(err)
            }
        } else {
            try {
                await this.player!.play()
                MediaLogger.d(TAG, "System callback: play")
                this.changePlayerState(PlayerState.STATE_STARTED)
                this.startProgressTimer()
                super.start()
            } catch (err) {
                this.checkError(err)
                return
            }
        }
    }

    async pause() {
        MediaLogger.d(TAG, ">> pause")
        try {
            await this.player!.pause()
            MediaLogger.d(TAG, "System callback: pause")
            this.changePlayerState(PlayerState.STATE_PAUSED)
            super.pause()
        } catch (err) {
            this.checkError(err)
            return
        }
    }

    async stop() {
        MediaLogger.d(TAG, ">> stop")
        try {
            await this.player!.stop()
            MediaLogger.d(TAG, "System callback: stop")
            this.changePlayerState(PlayerState.STATE_STOPPED)
            this.isPrepared = false
            super.stop()
        } catch (err) {
            this.checkError(err)
        }
    }

    async reset() {
        MediaLogger.d(TAG, ">> reset")
        try {
            await this.player!.reset()
            MediaLogger.d(TAG, "System callback: reset")
            this.changePlayerState(PlayerState.STATE_IDLE)
            this.isPrepared = false
            super.reset()
        } catch (err) {
            this.checkError(err)
        }
    }

    async release() {
        MediaLogger.d(TAG, ">> release")
        try {
            await this.player!.stop()
            await this.player!.release()
            MediaLogger.d(TAG, "System callback: release")
            this.changePlayerState(PlayerState.STATE_NOT_INIT)
            super.release()
        } catch (err) {
            this.checkError(err)
        }
    }

    async seekTo(position: number) {
        MediaLogger.d(TAG, ">> seek to: " + position)
        try {
            let duration = await this.player!.seek(position)
            MediaLogger.d(TAG, "System callback: seek completed")
            if (this.seekChangedListeners.length > 0) {
                this.seekChangedListeners.forEach((callback) => {
                    callback(duration)
                })
            }
        } catch (err) {
            this.checkError(err)
        }
    }

    async setVolume(vol: number) {
        MediaLogger.d(TAG, ">> set volume: " + vol)
        try {
            await this.player!.setVolume(vol)
            if (this.volumeChangedListeners.length > 0) {
                this.volumeChangedListeners.forEach((callback) => {
                    callback(-1)
                })
            }
        } catch (err) {
            this.checkError(err)
        }
    }

    setLooper(isLoop: boolean) {
        MediaLogger.d(TAG, ">> set loop: " + isLoop)
        this.player!.loop = isLoop
    }

    getDuration(): number {
        MediaLogger.d(TAG, "duration = " + this.player!.duration)
        return Math.round(this.player!.duration)
    }

    getCurrentPosition(): number {
        return Math.round(this.player!.currentTime)
    }

    getPlayerState(): PlayerState {
        MediaLogger.d(TAG, "system state = " + this.player!.state)
        return super.getPlayerState()
    }

    setSurface(surfaceId: string) {
        this.curSurfaceId = surfaceId
    }

    private checkError(err: BusinessError): boolean {
        if (err) {
            MediaLogger.e(TAG, "system error = " + JSON.stringify(err))
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