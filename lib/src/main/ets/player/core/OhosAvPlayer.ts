import { PlayerType } from '../config/PlayerType';
import { MediaSource } from '../data/MediaSource';
import { Logger } from '../common/Logger';
import { PlayerState } from '../config/PlayerState';
import media from '@ohos.multimedia.media';
import { BasePlayer } from './BasePlayer';


const TAG = "[OhosAvPlayer]"

/**
 * A player impl include audio and video for OpenHarmony 3.2+.
 */
export class OhosAvPlayer extends BasePlayer {
    private player: media.AVPlayer = null
    private curSurfaceId: string = null
    private lastSurfaceId: string = null
    private isPlayed = false
    private onReady: () => void = null
    private playType: PlayerType

    private constructor(type: PlayerType) {
        super()
        this.playType = type
        media.createAVPlayer((err, player) => {
            if (err) {
                Logger.e(TAG, "init video player error = " + JSON.stringify(err))
                this.changePlayerState(PlayerState.STATE_NOT_INIT)
                return
            }
            this.player = player
            this.changePlayerState(PlayerState.STATE_IDLE)
            this.init()
        })
    }

    static create(type: PlayerType): OhosAvPlayer {
        return new OhosAvPlayer(type)
    }

    init() {
        this.player.on('stateChange', (newState, _) => {
            switch (newState) {
                case "idle":
                    Logger.d(TAG, "System callback: idle")
                    this.changePlayerState(PlayerState.STATE_IDLE)
                    this.isPrepared = false
                    break
                case "initialized": // src ready -> initialized
                    Logger.d(TAG, "System callback: datasource ready")
                    if (this.playType == PlayerType.VIDEO && this.curSurfaceId != this.lastSurfaceId) {
                        Logger.d(TAG, ">> set surface: " + this.curSurfaceId)
                        this.player.surfaceId = this.curSurfaceId
                        this.lastSurfaceId = this.curSurfaceId
                    }
                    this.onReady?.()
                    this.onReady = null
                    break
                case "prepared":
                    Logger.d(TAG, "System callback: prepared")
                    this.changePlayerState(PlayerState.STATE_PREPARED)
                    this.isPrepared = true
                    if (this.preparedListeners.length > 0) {
                        this.preparedListeners.forEach((callback) => {
                            callback()
                        })
                    }
                // Must seek in [prepared] state before call play! This is different with old api like AudioPlayer and VideoPlayer.
                // The old api must seek in [started] state after call play!
                    if (this.startPosition != -1) { // start with seek action
                        Logger.d(TAG, "start to " + this.startPosition)
                        this.seekTo(this.startPosition)
                    } else {
                        this.player.play()
                    }
                    break
                case "playing":
                    Logger.d(TAG, "System callback: playing")
                    this.isPlayed = true
                    this.changePlayerState(PlayerState.STATE_STARTED)
                    break
                case "paused":
                    Logger.d(TAG, "System callback: pause")
                    this.changePlayerState(PlayerState.STATE_PAUSED)
                    break
                case "completed":
                    Logger.d(TAG, "System callback: completed")
                    this.changePlayerState(PlayerState.STATE_COMPLETED)
                    if (this.completedListeners.length > 0) {
                        this.completedListeners.forEach((callback) => {
                            callback()
                        })
                    }
                    break
                case "stopped":
                    Logger.d(TAG, "System callback: stopped")
                    this.changePlayerState(PlayerState.STATE_STOPPED)
                    this.isPrepared = false
                    break
                case "released":
                    Logger.d(TAG, "System callback: released")
                    this.changePlayerState(PlayerState.STATE_NOT_INIT)
                    break
                case "error":
                    Logger.e(TAG, "System callback: error")
                    if (this.errorListeners.length > 0) {
                        this.errorListeners.forEach((callback) => {
                            callback(-1, "state error")
                        })
                    }
                    break
            }
        })
        this.player.on("error", (err) => {
            Logger.e(TAG, "System callback: error = " + JSON.stringify(err))
            if (this.errorListeners.length > 0) {
                this.errorListeners.forEach((callback) => {
                    if (err) {
                        callback(err.code, err.message)
                    } else {
                        callback(-1, "unknown error")
                    }
                })
            }
        })
        this.player.on('startRenderFrame', () => {
            Logger.d(TAG, "System callback: render first frame ")
            if (this.renderFirstFrameListeners.length > 0) {
                this.renderFirstFrameListeners.forEach((callback) => {
                    callback()
                })
            }
        })
        this.player.on('videoSizeChange', (width: number, height: number) => {
            Logger.d(TAG, "System callback: videoSizeChanged: " + width + " x " + height)
            if (this.videoSizeChangedListeners.length > 0) {
                this.videoSizeChangedListeners.forEach((callback) => {
                    callback(width, height)
                })
            }
        })
        this.player.on("seekDone", (position) => {
            Logger.d(TAG, "System callback: seekDone: " + position)
            if (this.seekChangedListeners.length > 0) {
                this.seekChangedListeners.forEach((callback) => {
                    callback(position)
                })
            }
            if (this.startPosition != -1) { // start with seek action
                this.startPosition = -1
                this.start()
                this.changePlayerState(PlayerState.STATE_STARTED)
            }
        })
        this.player.on("volumeChange", (volume) => {
            Logger.d(TAG, "System callback: volumeChange: " + volume)
            if (this.volumeChangedListeners.length > 0) {
                this.volumeChangedListeners.forEach((callback) => {
                    callback()
                })
            }
        })
        this.player.on("timeUpdate", (time) => {
            this.progressChangedListeners.forEach((callback) => {
                callback(time)
            })
        })
    }

    async setMediaSource(mediaSource: MediaSource, onReady?: () => void) {
        Logger.d(TAG, "setMediaSource = " + JSON.stringify(mediaSource))
        this.onReady = onReady
        if (this.isPlayed) {
            await this.player.reset()
            this.setMediaSourceInner(mediaSource)
        } else {
            this.setMediaSourceInner(mediaSource)
        }
    }

    private setMediaSourceInner(mediaSource: MediaSource) {
        if (this.playType == PlayerType.VIDEO && this.curSurfaceId == null) {
            throw new Error("You must call setSurfaceId(surfaceId) before call this function.")
        }
        Logger.d(TAG, "set url = " + mediaSource.source)
        // the action set surface must between set url and prepare.
        this.player.url = mediaSource.source
    }

    async start() {
        Logger.d(TAG, ">> start, isPrepared = " + this.isPrepared)
        if (this.isPrepared == false) {
            await this.player.prepare()
        } else {
            await this.player.play()
        }
    }

    async pause() {
        Logger.d(TAG, ">> pause")
        await this.player.pause()
    }

    async stop() {
        Logger.d(TAG, ">> stop")
        await this.player.stop()
    }

    async reset() {
        Logger.d(TAG, ">> reset")
        await this.player.reset()
    }

    async release() {
        Logger.d(TAG, ">> release")
        this.player.off("stateChange")
        this.player.off("startRenderFrame")
        this.player.off("videoSizeChange")
        this.player.off("seekDone")
        this.player.off("volumeChange")
        await this.player.stop()
        await this.player.reset()
        await this.player.release()
        super.release()
    }

    seekTo(position: number) {
        Logger.d(TAG, ">> seek to: " + position)
        this.player.seek(position)
    }

    setVolume(vol: number) {
        Logger.d(TAG, ">> set volume: " + vol)
        this.player.setVolume(vol)
    }

    setLooper(isLoop: boolean) {
        Logger.d(TAG, ">> set loop: " + isLoop)
        this.player.loop = isLoop
    }

    getDuration(): number {
        Logger.d(TAG, "duration = " + this.player.duration)
        return Math.round(this.player.duration)
    }

    getCurrentPosition(): number {
        return Math.round(this.player.currentTime)
    }

    getPlayerState(): PlayerState {
        Logger.d(TAG, "system state = " + this.player.state)
        return super.getPlayerState()
    }

    setSurface(surfaceId: string) {
        if (this.playType != PlayerType.VIDEO) {
            Logger.w(TAG, "Current player type is AUDIO, not support to bind a surface")
            return
        }
        this.curSurfaceId = surfaceId
    }

    getSystemPlayer(): media.AVPlayer {
        return this.player
    }
}