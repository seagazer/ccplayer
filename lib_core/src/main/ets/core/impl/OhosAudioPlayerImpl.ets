import media from '@ohos.multimedia.media';
import { BasePlayer } from './BasePlayer';
import { MediaLogger, MediaSource, PlayerState } from '@seagazer/ccplayer_base';

const TAG = "[OhosAudioPlayer]"


/**
 * Audio player impl for OpenHarmony 3.0+.
 *
 * Author: Seagazer
 * Date: 2022/3/17
 *
 * @deprecated since v1.0.4
 */
export class OhosAudioPlayerImpl extends BasePlayer {
    private player: media.AudioPlayer | null = null
    private isPlayed = false
    private onReady?: () => void = undefined

    private constructor() {
        super()
        this.player! = media.createAudioPlayer()
        this.init()
    }

    static create(): OhosAudioPlayerImpl {
        return new OhosAudioPlayerImpl()
    }

    init() {
        this.changePlayerState(PlayerState.STATE_IDLE)
        this.player!!.on('reset', () => {
            MediaLogger.d(TAG, "System callback: reset")
            this.isPrepared = false
            this.changePlayerState(PlayerState.STATE_IDLE)
        })
        this.player!.on('dataLoad', () => {
            MediaLogger.d(TAG, "System callback: dataLoad")
            this.isPrepared = true
            this.changePlayerState(PlayerState.STATE_PREPARED)
            if (this.preparedListeners.length > 0) {
                this.preparedListeners.forEach((callback) => {
                    callback()
                })
            }
            this.onReady?.()
            this.onReady = undefined
        })
        this.player!.on('play', () => {
            MediaLogger.d(TAG, "System callback: play")
            this.changePlayerState(PlayerState.STATE_STARTED)
            this.startProgressTimer()
            if (this.startPosition != -1) {
                this.seekTo(this.startPosition)
                this.startPosition = -1
            }
        })
        this.player!.on('pause', () => {
            MediaLogger.d(TAG, "System callback: pause")
            this.changePlayerState(PlayerState.STATE_PAUSED)
        })
        this.player!.on('stop', () => {
            MediaLogger.d(TAG, "System callback: stop")
            this.isPrepared = false
            this.changePlayerState(PlayerState.STATE_STOPPED)
        })
        this.player!.on('finish', () => {
            MediaLogger.d(TAG, "System callback: finish")
            this.changePlayerState(PlayerState.STATE_COMPLETED)
            this.stopProgressTimer()
            if (this.completedListeners.length > 0) {
                this.completedListeners.forEach((callback) => {
                    callback()
                })
            }
        })
        this.player!.on('error', (error) => {
            MediaLogger.e(TAG, "System callback: error = " + JSON.stringify(error))
            this.isPrepared = false
            this.changePlayerState(PlayerState.STATE_ERROR)
            if (this.errorListeners.length > 0) {
                this.errorListeners.forEach((callback) => {
                    callback(error.code, error.message)
                })
            }
        })
        this.player!.on('volumeChange', () => {
            if (this.volumeChangedListeners.length > 0) {
                this.volumeChangedListeners.forEach((callback) => {
                    callback(-1)
                })
            }
        })
    }

    setMediaSource(mediaSource: MediaSource, onReady?: () => void) {
        MediaLogger.d(TAG, "setMediaSource = " + JSON.stringify(mediaSource))
        this.onReady = onReady
        if (this.isPlayed) {
            this.reset()
        }
        this.isPlayed = true
        this.player!.src = mediaSource.url!
    }

    async start() {
        if (this.isPrepared) {
            MediaLogger.d(TAG, ">> start")
            this.player!.play()
        } else {
            MediaLogger.e(TAG, "You must set datasource before call start!")
        }
    }

    async pause() {
        MediaLogger.d(TAG, ">> pause")
        this.player!.pause()
        super.pause()
    }

    async stop() {
        MediaLogger.d(TAG, ">> stop")
        this.player!.stop()
        super.stop()
    }

    async reset() {
        MediaLogger.d(TAG, ">> reset")
        this.player!.reset()
        this.changePlayerState(PlayerState.STATE_IDLE)
        super.reset()
    }

    async release() {
        MediaLogger.d(TAG, ">> release")
        this.player!.release()
        this.changePlayerState(PlayerState.STATE_NOT_INIT)
        super.release()
    }

    seekTo(position: number) {
        MediaLogger.d(TAG, ">> seek to: " + position)
        this.player!.seek(position)
        if (this.seekChangedListeners.length > 0) {
            this.seekChangedListeners.forEach((callback) => {
                callback(position)
            })
        }
    }

    setVolume(vol: number) {
        MediaLogger.d(TAG, ">> set volume: " + vol)
        this.player!.setVolume(vol)
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
        throw new Error(`The audio player not support to bind this surface: ${surfaceId}!`)
    }

}

