import { MediaSource } from '../../data/MediaSource';
import { MediaLogger } from '../../common/MediaLogger';
import { PlayerState } from '../config/PlayerState';
import media from '@ohos.multimedia.media';
import { IPlayer } from '../../interface/IPlayer';
import { MediaSourceType } from '../../data/MediaSourceType';
import { audio } from '@kit.AudioKit';
import { AudioFocusEvent } from '../config/AudioFocusEvent';

const TAG = "[OhosAvPlayer]"

/**
 * A player impl include audio and video for OpenHarmony 4.0+.
 *
 * Author: Seagazer
 * Date: 2024/9/18
 */
export class AvPlayerImpl implements IPlayer {
    private player?: media.AVPlayer = undefined
    private mediaSource?: MediaSource = undefined
    private curSurfaceId?: string = undefined
    private lastSurfaceId?: string = undefined
    private onReady?: () => void = undefined
    private isLazyInitForPlay = false
    private isPlayed = false
    private isLoop = false
    private currentState = PlayerState.STATE_NOT_INIT
    private isPrepared = false
    private startPosition = -1
    private preparedListeners: Array<() => void> = []
    private completedListeners: Array<() => void> = []
    private progressChangedListeners: Array<(position: number) => void> = []
    private bufferProgressChangedListeners: Array<(position: number) => void> = []
    private errorListeners: Array<(code: number, message: string) => void> = []
    private seekChangedListeners: Array<(position: number) => void> = []
    private volumeChangedListeners: Array<(volume: number) => void> = []
    private stateChangedListeners: Array<(newState: PlayerState) => void> = []
    private videoSizeChangedListeners: Array<(width: number, height: number) => void> = []
    private renderFirstFrameListeners: Array<() => void> = []
    private audioFocusChangeListener: Array<(event: AudioFocusEvent) => void> = []
    private context: Context
    private bufferPosition: number = 0

    private constructor(context: Context) {
        this.context = context
        media.createAVPlayer((err, player) => {
            if (err) {
                MediaLogger.attentionE(TAG, "init video player error = " + JSON.stringify(err))
                this.changePlayerState(PlayerState.STATE_NOT_INIT)
                return
            }
            MediaLogger.d(TAG, "create player success")
            this.player = player
            this.changePlayerState(PlayerState.STATE_IDLE)
            this.init()
            if (this.isLazyInitForPlay && this.mediaSource) {
                MediaLogger.w(TAG,
                    "the player is call start before instance is created, need to play now, url = " +
                    JSON.stringify(this.mediaSource))
                this.setMediaSourceInner(this.mediaSource)
                this.isLazyInitForPlay = false
            }
        })
    }

    static create(context: Context): IPlayer {
        return new AvPlayerImpl(context)
    }

    init() {
        this.player!.on("stateChange", (newState, _) => {
            switch (newState) {
                case "idle":
                    MediaLogger.d(TAG, ">> System callback: idle")
                    this.changePlayerState(PlayerState.STATE_IDLE)
                    this.isPrepared = false
                    break
                case "initialized": // src ready -> initialized
                    MediaLogger.d(TAG, ">> System callback: initialized")
                    if (this.curSurfaceId && this.curSurfaceId != this.lastSurfaceId) {
                        MediaLogger.d(TAG, ">> set surface: " + this.curSurfaceId)
                        this.player!.surfaceId = this.curSurfaceId
                        this.lastSurfaceId = this.curSurfaceId
                    }
                    this.player!.prepare()
                    break
                case "prepared":
                    MediaLogger.d(TAG, ">> System callback: prepared")
                    this.isPrepared = true
                    this.player!.loop = this.isLoop
                    this.changePlayerState(PlayerState.STATE_PREPARED)
                    if (this.preparedListeners.length > 0) {
                        this.preparedListeners.forEach((callback) => {
                            callback()
                        })
                    }
                    this.onReady?.()
                    this.onReady = undefined
                    break
                case "playing":
                    MediaLogger.d(TAG, ">> System callback: playing")
                    this.isPlayed = true
                    this.player!.loop = this.isLoop
                    this.changePlayerState(PlayerState.STATE_STARTED)
                    break
                case "paused":
                    MediaLogger.d(TAG, ">> System callback: paused")
                    this.player!.loop = this.isLoop
                    this.changePlayerState(PlayerState.STATE_PAUSED)
                    break
                case "completed":
                    MediaLogger.d(TAG, ">> System callback: completed")
                    this.player!.loop = this.isLoop
                    this.changePlayerState(PlayerState.STATE_COMPLETED)
                    if (this.completedListeners.length > 0) {
                        this.completedListeners.forEach((callback) => {
                            callback()
                        })
                    }
                    break
                case "stopped":
                    MediaLogger.d(TAG, ">> System callback: stopped")
                    this.changePlayerState(PlayerState.STATE_STOPPED)
                    this.isPrepared = false
                    break
                case "released":
                    MediaLogger.d(TAG, ">> System callback: released")
                    this.changePlayerState(PlayerState.STATE_NOT_INIT)
                    break
                case "error":
                    MediaLogger.attentionE(TAG, ">> System callback: error")
                    if (this.errorListeners.length > 0) {
                        this.errorListeners.forEach((callback) => {
                            callback(-1, "state error")
                        })
                    }
                    break
            }
        })
        this.player!.on("error", (err) => {
            MediaLogger.attentionE(TAG, ">> System callback: error = " + JSON.stringify(err))
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
        this.player!.on("startRenderFrame", () => {
            MediaLogger.d(TAG, ">> System callback: render first frame ")
            if (this.renderFirstFrameListeners.length > 0) {
                this.renderFirstFrameListeners.forEach((callback) => {
                    callback()
                })
            }
        })
        this.player!.on("videoSizeChange", (width: number, height: number) => {
            MediaLogger.d(TAG, ">> System callback: videoSizeChanged: " + width + " x " + height)
            if (this.videoSizeChangedListeners.length > 0) {
                this.videoSizeChangedListeners.forEach((callback) => {
                    callback(width, height)
                })
            }
        })
        this.player!.on("seekDone", (position) => {
            MediaLogger.d(TAG, ">> System callback: seekDone: " + position)
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
        this.player!.on("volumeChange", (volume) => {
            MediaLogger.d(TAG, ">> System callback: volumeChange: " + volume)
            if (this.volumeChangedListeners.length > 0) {
                this.volumeChangedListeners.forEach((callback) => {
                    callback(volume)
                })
            }
        })
        this.player!.on("timeUpdate", (time) => {
            this.progressChangedListeners.forEach((callback) => {
                callback(time)
            })
        })
        this.player!.on("audioInterrupt", (event: audio.InterruptEvent) => {
            MediaLogger.d(TAG, ">> System callback: audioFocusChange: " + JSON.stringify(event))
            if (event.forceType == audio.InterruptForceType.INTERRUPT_FORCE) {
                switch (event.hintType) {
                    case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
                    case audio.InterruptHint.INTERRUPT_HINT_STOP:
                        this.audioFocusChangeListener.forEach((listener) => {
                            listener(AudioFocusEvent.AUDIO_FOCUS_LOST)
                        })
                        break
                }
            } else { //audio.InterruptForceType.INTERRUPT_SHARE
                switch (event.hintType) {
                    case audio.InterruptHint.INTERRUPT_HINT_RESUME:
                        this.audioFocusChangeListener.forEach((listener) => {
                            listener(AudioFocusEvent.AUDIO_FOCUS_GAIN)
                        })
                        break
                }
            }
        })
        this.player!.on("bufferingUpdate", (type: media.BufferingInfoType, value: number) => {
            switch (type) {
                case media.BufferingInfoType.BUFFERING_START:
                    this.isPlayingBeforeBufferState = this.isPlaying()
                    MediaLogger.d(TAG, ">> System callback: BUFFERING_START")
                    this.changePlayerState(PlayerState.STATE_BUFFER_START)
                    break
                case media.BufferingInfoType.BUFFERING_PERCENT:
                    MediaLogger.d(TAG, ">> System callback: BUFFERING_PERCENT, value= " + value)
                    this.changePlayerState(PlayerState.STATE_BUFFER_UPDATE)
                    break
                case media.BufferingInfoType.BUFFERING_END:
                    MediaLogger.d(TAG, ">> System callback: BUFFERING_END")
                    this.changePlayerState(PlayerState.STATE_BUFFER_END)
                    if (this.isPlayingBeforeBufferState) {
                        this.changePlayerState(PlayerState.STATE_STARTED)
                    } else {
                        this.changePlayerState(PlayerState.STATE_PAUSED)
                    }
                    break
                case media.BufferingInfoType.CACHED_DURATION:
                    const current = this.getCurrentPosition();
                    const buffer = current + value > 0 ? value : 0;
                    if (buffer > this.bufferPosition) { // 防止回跳
                        this.bufferPosition = buffer;
                    }
                    this.bufferProgressChangedListeners.forEach((callback) => callback(this.bufferPosition))
                    break
            }
        })
    }

    private isPlayingBeforeBufferState: boolean = false

    isPlaying(): boolean {
        return this.currentState == PlayerState.STATE_STARTED || this.currentState == PlayerState.STATE_BUFFER_START
            || this.currentState == PlayerState.STATE_BUFFER_UPDATE || this.currentState == PlayerState.STATE_BUFFER_END
    }

    getPlayerState(): PlayerState {
        MediaLogger.i(TAG, ">> currentState: " + this.currentState)
        return this.currentState
    }

    private changePlayerState(state: PlayerState) {
        if (this.currentState == state) {
            return
        }
        this.currentState = state
        this.stateChangedListeners.forEach((callback) => {
            callback(state)
        })
    }

    async setMediaSource(mediaSource: MediaSource, onReady?: () => void) {
        MediaLogger.d(TAG, ">> setMediaSource = " + JSON.stringify(mediaSource))
        this.mediaSource?.release(this.context)
        this.mediaSource = mediaSource
        this.onReady = onReady
        if (this.isPlayed && this.player) {
            await this.player.reset()
        }
        await this.setMediaSourceInner(mediaSource)
    }

    getMediaSource(): MediaSource | undefined {
        return this.mediaSource
    }

    private async setMediaSourceInner(mediaSource: MediaSource) {
        if (mediaSource.type == MediaSourceType.NETWORK && mediaSource.httpHeaders) {
            // impl set media source for api12+
            this.setMediaSourceInner12Impl(mediaSource)
        } else {
            // the action set surface must between set url and prepare.
            if (this.player) {
                switch (mediaSource.type) {
                    case MediaSourceType.ASSETS:
                        const rawFd = this.context.resourceManager.getRawFdSync(mediaSource.rawAssetsPath)
                        let avFileDescriptor: media.AVFileDescriptor =
                            {
                                fd: rawFd.fd,
                                offset: rawFd.offset,
                                length: rawFd.length
                            };
                        this.player.fdSrc = avFileDescriptor
                        break
                    case MediaSourceType.FILE:
                    case MediaSourceType.NETWORK:
                    case MediaSourceType.STREAM:
                        this.player.url = mediaSource.url
                        break
                }
            } else {
                MediaLogger.w(TAG,
                    "the player is not created finish, mark lazy to play when the player instance is created!")
                this.isLazyInitForPlay = true
            }
        }
    }

    private async setMediaSourceInner12Impl(mediaSource: MediaSource) {
        const source = media.createMediaSourceWithUrl(mediaSource.url, mediaSource.httpHeaders)
        let playStrategy: media.PlaybackStrategy
        if (mediaSource.strategy) {
            playStrategy = mediaSource.strategy
        } else {
            playStrategy = {
                preferredWidth: 1920,
                preferredHeight: 1080,
                preferredBufferDuration: 3,
                preferredHdr: false
            }
        }
        await this.player!.setMediaSource(source, playStrategy)
    }

    async start() {
        MediaLogger.d(TAG, ">> start, isPrepared = " + this.isPrepared)
        if (this.startPosition != -1) { // start with seek action
            MediaLogger.d(TAG, "start to " + this.startPosition)
            this.seekTo(this.startPosition)
        } else {
            this.player!.play()
        }
    }

    async startTo(position: number) {
        MediaLogger.d(TAG, ">> start to: " + position)
        this.startPosition = position
        await this.start()
        if (this.currentState == PlayerState.STATE_BUFFER_UPDATE || this.currentState == PlayerState.STATE_BUFFER_START) {
            this.isPlayingBeforeBufferState = true
        }
    }

    async pause() {
        MediaLogger.d(TAG, ">> pause")
        await this.player!.pause()
        if (this.currentState == PlayerState.STATE_BUFFER_UPDATE || this.currentState == PlayerState.STATE_BUFFER_START) {
            this.isPlayingBeforeBufferState = false
        }
    }

    async stop() {
        MediaLogger.d(TAG, ">> stop")
        await this.player!.stop()
    }

    async reset() {
        MediaLogger.d(TAG, ">> reset")
        await this.player!.reset()
    }

    async release() {
        MediaLogger.d(TAG, ">> release")
        if (this.player) {
            this.player.off("stateChange")
            this.player.off("error")
            this.player.off("startRenderFrame")
            this.player.off("videoSizeChange")
            this.player.off("seekDone")
            this.player.off("volumeChange")
            this.player.off("timeUpdate")
            this.player.off("audioInterrupt")
            this.player.off("bufferingUpdate")
            this.preparedListeners = []
            this.completedListeners = []
            this.progressChangedListeners = []
            this.errorListeners = []
            this.seekChangedListeners = []
            this.volumeChangedListeners = []
            this.stateChangedListeners = []
            this.videoSizeChangedListeners = []
            this.renderFirstFrameListeners = []
            this.audioFocusChangeListener = []
            await this.player.stop()
            await this.player.reset()
            await this.player.release()
        }
    }

    seekTo(position: number) {
        MediaLogger.d(TAG, ">> seek to: " + position)
        this.player!.seek(position)
    }

    setVolume(vol: number) {
        MediaLogger.d(TAG, ">> set volume: " + vol)
        this.player!.setVolume(vol)
    }

    setPlaySpeed(speed: number | media.PlaybackSpeed): void {
        MediaLogger.d(TAG, ">> set play speed: " + speed)
        this.player!.setSpeed(speed)
    }

    setLooper(isLoop: boolean) {
        MediaLogger.d(TAG, ">> set loop: " + isLoop)
        this.isLoop = isLoop
    }

    getDuration(): number {
        MediaLogger.d(TAG, "duration = " + this.player!.duration)
        return Math.round(this.player!.duration)
    }

    getCurrentPosition(): number {
        return Math.round(this.player!.currentTime)
    }

    getBufferPosition(): number {
        return Math.round(this.bufferPosition)
    }

    setSurface(surfaceId: string) {
        this.curSurfaceId = surfaceId
    }

    getSystemPlayer(): media.AVPlayer | IPlayer {
        return this.player!
    }

    addOnPreparedListener(listener: () => void): IPlayer {
        this.preparedListeners.push(listener)
        return this
    }

    removeOnPreparedListener(listener: () => void): IPlayer {
        let index = this.preparedListeners.indexOf(listener)
        if (index >= 0) {
            this.preparedListeners.splice(index, 1)
        }
        return this
    }

    addOnCompletionListener(listener: () => void): IPlayer {
        this.completedListeners.push(listener)
        return this
    }

    removeOnCompletionListener(listener: () => void): IPlayer {
        let index = this.completedListeners.indexOf(listener)
        if (index >= 0) {
            this.completedListeners.splice(index, 1)
        }
        return this
    }

    addOnErrorListener(listener: (code: number, message: string) => void): IPlayer {
        this.errorListeners.push(listener)
        return this
    }

    removeOnErrorListener(listener: (code: number, message: string) => void): IPlayer {
        let index = this.errorListeners.indexOf(listener)
        if (index >= 0) {
            this.errorListeners.splice(index, 1)
        }
        return this
    }

    addOnProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.progressChangedListeners.push(listener)
        return this
    }

    removeOnProgressChangedListener(listener: (duration: number) => void): IPlayer {
        let index = this.progressChangedListeners.indexOf(listener)
        if (index >= 0) {
            this.progressChangedListeners.splice(index, 1)
        }
        return this
    }

    addOnBufferProgressChangedListener(listener: (duration: number) => void): IPlayer {
        this.bufferProgressChangedListeners.push(listener)
        return this
    }

    removeOnBufferProgressChangedListener(listener: (duration: number) => void): IPlayer {
        let index = this.bufferProgressChangedListeners.indexOf(listener)
        if (index >= 0) {
            this.bufferProgressChangedListeners.splice(index, 1)
        }
        return this
    }

    addOnSeekChangedListener(listener: (duration: number) => void): IPlayer {
        this.seekChangedListeners.push(listener)
        return this
    }

    removeOnSeekChangedListener(listener: (duration: number) => void): IPlayer {
        let index = this.seekChangedListeners.indexOf(listener)
        if (index >= 0) {
            this.seekChangedListeners.splice(index, 1)
        }
        return this
    }

    addOnVolumeChangedListener(listener: (volume: number) => void): IPlayer {
        this.volumeChangedListeners.push(listener)
        return this
    }

    removeOnVolumeChangedListener(listener: (volume: number) => void): IPlayer {
        let index = this.volumeChangedListeners.indexOf(listener)
        if (index >= 0) {
            this.volumeChangedListeners.splice(index, 1)
        }
        return this
    }

    addOnStateChangedListener(listener: (state: PlayerState) => void): IPlayer {
        this.stateChangedListeners.push(listener)
        return this
    }

    removeOnStateChangedListener(listener: (state: PlayerState) => void): IPlayer {
        let index = this.stateChangedListeners.indexOf(listener)
        if (index >= 0) {
            this.stateChangedListeners.splice(index, 1)
        }
        return this
    }

    addOnVideoSizeChangedListener(listener: (width: number, height: number) => void): IPlayer {
        this.videoSizeChangedListeners.push(listener)
        return this
    }

    removeOnVideoSizeChangedListener(listener: (width: number, height: number) => void): IPlayer {
        let index = this.videoSizeChangedListeners.indexOf(listener)
        if (index >= 0) {
            this.videoSizeChangedListeners.splice(index, 1)
        }
        return this
    }

    addOnRenderFirstFrameListener(listener: () => void): IPlayer {
        this.renderFirstFrameListeners.push(listener)
        return this
    }

    removeOnRenderFirstFrameListener(listener: () => void): IPlayer {
        let index = this.renderFirstFrameListeners.indexOf(listener)
        if (index >= 0) {
            this.renderFirstFrameListeners.splice(index, 1)
        }
        return this
    }

    addOnAudioFocusChangedListener(listener: (event: AudioFocusEvent) => void): IPlayer {
        this.audioFocusChangeListener.push(listener)
        return this
    }

    removeOnAudioFocusChangedListener(listener: (event: AudioFocusEvent) => void): IPlayer {
        let index = this.audioFocusChangeListener.indexOf(listener)
        if (index >= 0) {
            this.audioFocusChangeListener.splice(index, 1)
        }
        return this
    }
}