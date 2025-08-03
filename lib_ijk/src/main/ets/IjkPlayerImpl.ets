import { AudioFocusEvent, IPlayer, MediaLogger, MediaSource, MediaSourceType, PlayerState } from '@seagazer/ccplayer-base';
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
import { IjkPlugin } from './IjkPlugin';
import { StateCode } from './StateCode';

const TAG = "[IjkPlayerImpl]"

/**
 * The player impl of IjkPlayer.
 *
 * Author: Seagazer
 * Date: 2025/8/2
 */
export class IjkPlayerImpl implements IPlayer {
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
    private videoSize: number[] = [-1, -1]
    private progressTimer = -1

    constructor() {
        const id = "IjkPlayerImpl_" + new Date().getTime()
        this.player = new IjkMediaPlayer(id)
        if (MediaLogger.isDebug()) {
            this.player.setDebug(true)
        }
        this.changePlayerState(PlayerState.STATE_IDLE)
    }

    private initIjk() {
        MediaLogger.d(TAG, ">> init ijk")
        this.isSetupListener = true
        MediaLogger.d(TAG, ">> native set context= " + this.surfaceId)
        this.player.setContext(this.surfaceId, IjkPlugin.getXComponentId())
        MediaLogger.d(TAG, ">> native setup")
        this.player.native_setup()

        // //使用精确寻帧 例如，拖动播放后，会寻找最近的关键帧进行播放，很有可能关键帧的位置不是拖动后的位置，而是较前的位置.可以设置这个参数来解决问题
        // this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "enable-accurate-seek", "1");
        // //预读数据的缓冲区大小
        // this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max-buffer-size", "102400");
        // //停止预读的最小帧数
        // this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "min-frames", "100");
        // //启动预加载
        // this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "start-on-prepared", "1");
        // // 设置无缓冲，这是播放器的缓冲区，有数据就播放
        // this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "packet-buffering", "0");
        // //跳帧处理,放CPU处理较慢时，进行跳帧处理，保证播放流程，画面和声音同步
        // this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "framedrop", "5");
        // // 最大缓冲cache是3s， 有时候网络波动，会突然在短时间内收到好几秒的数据
        // // 因此需要播放器丢包，才不会累积延时
        // // 这个和第三个参数packet-buffering无关。
        // this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "max_cached_duration", "3000");
        // // 无限制收流
        // // this.mIjkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "infbuf", "1");
        // // this.mIjkMediaPlayer.setOptionLong(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "infbuf", "1")
        // // 设置超时
        // this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "timeout", "10000000");
        // this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "connect_timeout", "10000000");
        // this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "addrinfo_timeout", "10000000");
        // this.player.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "dns_cache_timeout", "10000000");

        MediaLogger.d(TAG, ">> native register listeners")
        const mOnVideoSizeChangedListener: OnVideoSizeChangedListener = {
            onVideoSizeChanged: (width: number, height: number, sar_num: number, sar_den: number) => {
                MediaLogger.d(TAG, ">> System callback: onVideoSizeChanged")
                if (this.videoSize[0] == width && this.videoSize[1] == height) {
                    MediaLogger.w(TAG, ">> System callback: onVideoSizeChanged, but size is not changed!")
                    return
                }
                this.videoSize[0] = width
                this.videoSize[1] = height
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
                this.startProgressTimer()
            }
        }
        const mOnCompletionListener: OnCompletionListener = {
            onCompletion: () => {
                MediaLogger.d(TAG, ">> System callback: onCompletion")
                this.changePlayerState(PlayerState.STATE_COMPLETED)
                this.completedListeners.forEach((callback) => {
                    callback()
                })
                this.stopProgressTimer()
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
                // 10000	缓冲开始	播放器开始缓冲数据
                // 10001	缓冲结束	缓冲完成，即将开始播放
                // 10002	正在缓冲中	extra 参数通常携带缓冲进度（百分比）
                // 10008	播放达到文件末尾（EOF）	媒体文件播放完成
                // 20001	网络带宽不足	可能导致播放卡顿
                // 20002	尝试重新连接网络	网络中断后重试连接
                // 20003	网络连接恢复	网络重新连接成功
                // 20004	开始尝试加载媒体数据	启动媒体加载流程
                // 30001	切换视频轨道	如从标清切换到高清
                // 30002	切换音频轨道	切换不同的音频流
                // 30003	视频解码器初始化完成	视频解码组件准备就绪
                // 30004	音频解码器初始化完成	音频解码组件准备就绪
                // 80001	硬解码开启成功	成功启用硬件解码
                // 80002	硬解码开启失败	自动切换到软件解码
                // 90001	播放器内部状态变化	如从暂停切换到播放状态
                if (what == StateCode.MEDIA_INFO_VIDEO_RENDERING_START) {
                    this.changePlayerState(PlayerState.STATE_STARTED)
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
            // INTERRUPT_HINT_NONE	    0	无提示。
            // INTERRUPT_HINT_RESUME	1	提示音频恢复。
            // INTERRUPT_HINT_PAUSE	    2	提示音频暂停。
            // INTERRUPT_HINT_STOP	    3	提示音频停止。
            // INTERRUPT_HINT_DUCK	    4	提示音频躲避。（躲避：音量减弱，而不会停止）
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
        this.startProgressTimer()
    }

    startTo(position: number): void {
        // todo
        throw new Error("Method not implemented.");
    }

    pause(): void {
        MediaLogger.d(TAG, ">> pause")
        this.player.pause()
        this.stopProgressTimer()
    }

    stop(): void {
        MediaLogger.d(TAG, ">> stop")
        this.player.stop()
        this.stopProgressTimer()
    }

    reset(): void {
        MediaLogger.d(TAG, ">> reset")
        this.player.reset()
    }

    release(): void {
        MediaLogger.d(TAG, ">> release")
        this.stopProgressTimer()
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

    private startProgressTimer() {
        MediaLogger.d(TAG, "startProgressTimer")
        this.stopProgressTimer()
        this.progressTimer = setInterval(() => {
            const position = this.getCurrentPosition()
            MediaLogger.d(TAG, "current position= " + position)
            this.progressChangedListeners.forEach((callback) => {
                callback(position)
            })
        }, 300)
    }

    private stopProgressTimer() {
        if (this.progressTimer == -1) {
            return
        }
        MediaLogger.d(TAG, "stopProgressTimer")
        clearInterval(this.progressTimer)
        this.progressTimer = -1
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
        MediaLogger.d(TAG, "currentState= " + this.currentState)
        // return this.currentState == PlayerState.STATE_STARTED || this.currentState == PlayerState.STATE_BUFFER_START
        //     || this.currentState == PlayerState.STATE_BUFFER_UPDATE || this.currentState == PlayerState.STATE_BUFFER_END
        return this.player.isPlaying()
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

    setSurface(surfaceId: string): void {
        throw new Error("The ijkPlayer is not support, user bindXComponent instead!")
    }

    bindXComponent(controller: XComponentController, loadContext: object): void {
        this.surfaceId = loadContext
        if (!this.isSetupListener) {
            this.initIjk()
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