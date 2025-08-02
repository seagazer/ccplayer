import { AudioFocusEvent, IPlayer, MediaLogger, MediaSource, MediaSourceType, PlayerState } from '@seagazer/ccplayer_base';
import media from '@ohos.multimedia.media';
import {
    IjkMediaPlayer,
    InterruptEvent,
    InterruptHintType,
    OnBufferingUpdateListener,
    OnCompletionListener,
    OnErrorListener,
    OnInfoListener,
    OnPreparedListener,
    OnSeekCompleteListener,
    OnVideoSizeChangedListener
} from '@ohos/ijkplayer';

const TAG = "[IjkPlayerImpl]"

export class IjkPlayerImpl implements IPlayer {
    private readonly MEDIA_INFO_VIDEO_RENDERING_START = 3
    private static readonly NAPI = "ijkplayer_napi"
    private static readonly ID = "IjkPlayerImpl"
    private player: IjkMediaPlayer
    private surfaceId?: object = undefined
    private currentState = PlayerState.STATE_NOT_INIT
    private mediaSource?: MediaSource = undefined
    private seekPosition = 0
    private isPlayed = false
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
    private isSetupListener = false

    static getLibrary(): string {
        return IjkPlayerImpl.NAPI
    }

    static getXComponentId(): string {
        return IjkPlayerImpl.ID
    }

    constructor() {
        const id = "IjkPlayerImpl_" + new Date().getTime()
        this.player = new IjkMediaPlayer(id)
        if (MediaLogger.isDebug()) {
            this.player.setDebug(true)
        }
        this.changePlayerState(PlayerState.STATE_IDLE)
    }

    private initListeners() {
        MediaLogger.d(TAG, ">> initListeners")
        this.isSetupListener = true
        MediaLogger.d(TAG, ">> native set context= " + this.surfaceId)
        this.player.setContext(this.surfaceId, IjkPlayerImpl.ID)
        MediaLogger.d(TAG, ">> native setup")
        this.player.native_setup()
        MediaLogger.d(TAG, ">> native setup listeners")
        const mOnVideoSizeChangedListener: OnVideoSizeChangedListener = {
            onVideoSizeChanged: (width: number, height: number, sar_num: number, sar_den: number) => {
                MediaLogger.d(TAG, ">> System callback: onVideoSizeChanged")
                this.videoSizeChangedListeners.forEach((callback) => {
                    callback(width, height)
                })
            }
        }
        const mOnPreparedListener: OnPreparedListener = {
            onPrepared: () => {
                MediaLogger.d(TAG, ">> System callback: onPrepared")
                this.isPlayed = true
                this.changePlayerState(PlayerState.STATE_PREPARED)
                this.preparedListeners.forEach((callback) => {
                    callback()
                })
            }
        }
        const mOnCompletionListener: OnCompletionListener = {
            onCompletion: () => {
                MediaLogger.d(TAG, ">> System callback: onCompletion")
                this.changePlayerState(PlayerState.STATE_COMPLETED)
                this.completedListeners.forEach((callback) => {
                    callback()
                })
            }
        }
        const mOnBufferingUpdateListener: OnBufferingUpdateListener = {
            onBufferingUpdate: (percent: number) => {
                MediaLogger.d(TAG, ">> System callback: onBufferingUpdate= " + percent)
                this.bufferProgressChangedListeners.forEach((callback) => {
                    callback(percent)
                })
            }
        }
        const mOnSeekCompleteListener: OnSeekCompleteListener = {
            onSeekComplete: () => {
                MediaLogger.d(TAG, ">> System callback: onSeekComplete")
                this.seekChangedListeners.forEach((callback) => {
                    callback(this.seekPosition)
                })
            }
        }
        const mOnInfoListener: OnInfoListener = {
            onInfo: (what: number, extra: number) => {
                MediaLogger.d(TAG, ">> System callback: onInfo= " + what)
                // todo handle other state code
                if (what == this.MEDIA_INFO_VIDEO_RENDERING_START) {
                    this.renderFirstFrameListeners.forEach((callback) => {
                        callback()
                    })
                }
            }
        }
        const mOnErrorListener: OnErrorListener = {
            onError: (what: number, extra: number) => {
                MediaLogger.d(TAG, ">> System callback: onError= " + what)
                this.changePlayerState(PlayerState.STATE_ERROR)
                this.errorListeners.forEach((callback) => {
                    callback(what, extra.toString())
                })
            }
        }
        this.player.setOnVideoSizeChangedListener(mOnVideoSizeChangedListener)
        this.player.setOnPreparedListener(mOnPreparedListener)
        this.player.setOnCompletionListener(mOnCompletionListener)
        this.player.setOnBufferingUpdateListener(mOnBufferingUpdateListener)
        this.player.setOnSeekCompleteListener(mOnSeekCompleteListener)
        this.player.setOnInfoListener(mOnInfoListener)
        this.player.setOnErrorListener(mOnErrorListener)
        this.player.setMessageListener()
        const audioFocusEvent: Callback<InterruptEvent> = (event) => {
            MediaLogger.d(TAG, ">> audioFocusChanged= " + event)
            // INTERRUPT_HINT_NONE	0	无提示。
            // INTERRUPT_HINT_RESUME	1	提示音频恢复。
            // INTERRUPT_HINT_PAUSE	2	提示音频暂停。
            // INTERRUPT_HINT_STOP	3	提示音频停止。
            // INTERRUPT_HINT_DUCK	4	提示音频躲避。（躲避：音量减弱，而不会停止）
            // INTERRUPT_HINT_UNDUCK	5	提示音量恢复。
            let state = AudioFocusEvent.AUDIO_FOCUS_GAIN
            switch (event.hintType) {
                case InterruptHintType.INTERRUPT_HINT_PAUSE:
                case InterruptHintType.INTERRUPT_HINT_STOP:
                case InterruptHintType.INTERRUPT_HINT_DUCK:
                    state = AudioFocusEvent.AUDIO_FOCUS_LOST
                    break
                case InterruptHintType.INTERRUPT_HINT_RESUME:
                case InterruptHintType.INTERRUPT_HINT_UNDUCK:
                default:
                    state = AudioFocusEvent.AUDIO_FOCUS_GAIN
                    break
            }
            this.audioFocusChangeListener.forEach((callback) => {
                callback(state)
            })
        }
        // 设置监听音频中断事件
        this.player.on('audioInterrupt', audioFocusEvent)
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

    setMediaSource(mediaSource: MediaSource, onReady?: () => void): void {
        MediaLogger.d(TAG, ">> setMediaSource = " + JSON.stringify(mediaSource))
        this.mediaSource = mediaSource
        if (this.isPlayed && this.player) {
            this.reset()
            this.player.native_setup()
        }
        // todo
        if (mediaSource.type != MediaSourceType.NETWORK) {
            MediaLogger.w(TAG, "The ijkPlayer is only support network source!")
            return
        }
        this.player.setDataSource(mediaSource.url)
        MediaLogger.d(TAG, ">> prepareAsync")
        this.player.prepareAsync()
        onReady?.()
    }

    getMediaSource(): MediaSource | undefined {
        return this.mediaSource
    }

    start(): void {
        MediaLogger.d(TAG, ">> start")
        this.player.start()
    }

    startTo(position: number): void {
        // todo
        throw new Error("Method not implemented.");
    }

    pause(): void {
        MediaLogger.d(TAG, ">> pause")
        this.player.pause()
    }

    stop(): void {
        MediaLogger.d(TAG, ">> stop")
        this.player.stop()
    }

    reset(): void {
        MediaLogger.d(TAG, ">> reset")
        this.player.reset()
    }

    release(): void {
        MediaLogger.d(TAG, ">> release")
        this.player.setOnVideoSizeChangedListener(null)
        this.player.setOnPreparedListener(null)
        this.player.setOnCompletionListener(null)
        this.player.setOnBufferingUpdateListener(null)
        this.player.setOnSeekCompleteListener(null)
        this.player.setOnInfoListener(null)
        this.player.setOnErrorListener(null)
        this.player.off('audioInterrupt')
        this.player.release()
    }

    seekTo(position: number): void {
        this.seekPosition = position
        this.player.seekTo(position.toString())
    }

    setSeekMode(mode: media.SeekMode): void {
        if (mode == media.SeekMode.SEEK_CLOSEST) {
            this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "enable-accurate-seek", "1")
        }
    }

    setLooper(isLoop: boolean): void {
        MediaLogger.d(TAG, ">> setLooper: " + isLoop)
        this.player.setLoopCount(isLoop)
    }

    setVolume(vol: number): void {
        const volStr = vol.toString()
        this.player.setVolume(volStr, volStr)
    }

    setPlaySpeed(speed: number): void {
        // todo
        throw new Error("Method not implemented.");
    }

    isPlaying(): boolean {
        // todo
        return this.currentState == PlayerState.STATE_STARTED || this.currentState == PlayerState.STATE_BUFFER_START
            || this.currentState == PlayerState.STATE_BUFFER_UPDATE || this.currentState == PlayerState.STATE_BUFFER_END
    }

    getDuration(): number {
        const duration = this.player.getDuration()
        MediaLogger.d(TAG, "duration = " + duration)
        return duration
    }

    getCurrentPosition(): number {
        return this.player.getCurrentPosition()
    }

    getBufferPosition(): number {
        // todo
        throw new Error("Method not implemented.");
    }

    getPlayerState(): PlayerState {
        MediaLogger.i(TAG, ">> currentState: " + this.currentState)
        return this.currentState
    }

    getSystemPlayer(): IPlayer | media.AVPlayer {
        return this
    }

    setSurface(surfaceId: string | object): void {
        // todo
        this.surfaceId = surfaceId as object
        if (!this.isSetupListener) {
            this.initListeners()
        }
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