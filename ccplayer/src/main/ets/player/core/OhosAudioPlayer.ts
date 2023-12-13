import { MediaSource } from '../data/MediaSource';
import media from '@ohos.multimedia.media'
import { BasePlayer } from './baseplayer';
import { Logger } from '../common/Logger'
import { PlayerState } from '../config/PlayerState'

const TAG = "[OhosAudioPlayer]"

/**
 * Audio player impl for OpenHarmony 3.0+.
 */
export class OhosAudioPlayer extends BasePlayer {
    private player: media.AudioPlayer = null
    private isPlayed = false
    private onReady: () => void = null

    private constructor() {
        super()
        this.player = media.createAudioPlayer()
        this.init()
    }

    static create(): OhosAudioPlayer {
        return new OhosAudioPlayer()
    }

    init() {
        this.changePlayerState(PlayerState.STATE_IDLE)
        this.player.on('reset', () => {
            Logger.d(TAG, "System callback: reset")
            this.isPrepared = false
            this.changePlayerState(PlayerState.STATE_IDLE)
        })
        this.player.on('dataLoad', () => {
            Logger.d(TAG, "System callback: dataLoad")
            this.isPrepared = true
            this.changePlayerState(PlayerState.STATE_PREPARED)
            if (this.preparedListeners.length > 0) {
                this.preparedListeners.forEach((callback) => {
                    callback()
                })
            }
            this.onReady?.()
            this.onReady = null
        })
        this.player.on('play', () => {
            Logger.d(TAG, "System callback: play")
            this.changePlayerState(PlayerState.STATE_STARTED)
            this.startProgressTimer()
            if (this.startPosition != -1) {
                this.seekTo(this.startPosition)
                this.startPosition = -1
            }
        })
        this.player.on('pause', () => {
            Logger.d(TAG, "System callback: pause")
            this.changePlayerState(PlayerState.STATE_PAUSED)
        })
        this.player.on('stop', () => {
            Logger.d(TAG, "System callback: stop")
            this.isPrepared = false
            this.changePlayerState(PlayerState.STATE_STOPPED)
        })
        this.player.on('finish', () => {
            Logger.d(TAG, "System callback: finish")
            this.changePlayerState(PlayerState.STATE_COMPLETED)
            this.stopProgressTimer()
            if (this.completedListeners.length > 0) {
                this.completedListeners.forEach((callback) => {
                    callback()
                })
            }
        })
        this.player.on('error', (error) => {
            Logger.e(TAG, "System callback: error = " + JSON.stringify(error))
            this.isPrepared = false
            this.changePlayerState(PlayerState.STATE_ERROR)
            if (this.errorListeners.length > 0) {
                this.errorListeners.forEach((callback) => {
                    callback(error.code, error.message)
                })
            }
        })
        this.player.on('volumeChange', () => {
            if (this.volumeChangedListeners.length > 0) {
                this.volumeChangedListeners.forEach((callback) => {
                    callback()
                })
            }
        })
    }

    setMediaSource(mediaSource: MediaSource, onReady?: () => void) {
        Logger.d(TAG, "setMediaSource = " + JSON.stringify(mediaSource))
        this.onReady = onReady
        if (this.isPlayed) {
            this.reset()
        }
        this.isPlayed = true
        this.player.src = mediaSource.source
    }

    async start() {
        if (this.isPrepared) {
            Logger.d(TAG, ">> start")
            this.player.play()
        } else {
            Logger.e(TAG, "You must set datasource before call start!")
        }
    }

    async pause() {
        Logger.d(TAG, ">> pause")
        this.player.pause()
        super.pause()
    }

    async stop() {
        Logger.d(TAG, ">> stop")
        this.player.stop()
        super.stop()
    }

    async reset() {
        Logger.d(TAG, ">> reset")
        this.player.reset()
        this.changePlayerState(PlayerState.STATE_IDLE)
        super.reset()
    }

    async release() {
        Logger.d(TAG, ">> release")
        this.player.release()
        this.changePlayerState(PlayerState.STATE_NOT_INIT)
        super.release()
    }

    seekTo(position: number) {
        Logger.d(TAG, ">> seek to: " + position)
        this.player.seek(position)
        if (this.seekChangedListeners.length > 0) {
            this.seekChangedListeners.forEach((callback) => {
                callback(position)
            })
        }
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
        throw new Error(`The audio player not support to bind this surface: ${surfaceId}!`)
    }

    addOnVideoSizeChangedListener(_: (newWidth, newHeight) => void) {
        throw new Error(`The audio player not support to observe the video size!`)
    }

    removeOnVideoSizeChangedListener(_: (newWidth, newHeight) => void) {
        throw new Error(`The audio player not support to observe the video size!`)
    }

    getSystemPlayer(): media.AudioPlayer {
        return this.player
    }
}

