import { PiPWindow } from '@kit.ArkUI';
import { AspectRatio, GestureAreaConfig, GestureType, IJK, MediaLogger, MediaSource } from '@seagazer/ccplayer-base';
import { CcPlayer } from '../CcPlayer';
import { PlayerType } from '../common/PlayerType';
import { AvPlayerImpl } from '../core/impl/AvPlayerImpl';
import { GestureHandler } from './GestureHandler';

export interface PlayerViewLogicOptions {
    tag: string
    player: CcPlayer
    gestureAreaConfig: GestureAreaConfig
    horizontalGestureDamping: number
    verticalGestureDamping: number
    defaultBrightness: number
    defaultVolume: number
    autoHideControllerDelay: number
    onSurfaceSizeChanged: (width: number, height: number) => void
    onSurfaceVisibleChanged: (visible: boolean) => void
    onPipStateChanged: (state: string) => void
    onGestureUIVisibleChanged: (visible: boolean) => void
    onGestureAction: (type: GestureType, percent: number, isTouchUp: boolean) => void
    onDoubleClickAction: () => void
    getAspectRatio: () => AspectRatio
}

export class PlayerViewLogic {
    private tag: string
    private player: CcPlayer
    private gestureAreaConfig: GestureAreaConfig
    private horizontalGestureDamping: number
    private verticalGestureDamping: number
    private defaultBrightness: number
    private defaultVolume: number
    private autoHideControllerDelay: number
    private onSurfaceSizeChanged: (width: number, height: number) => void
    private onSurfaceVisibleChanged: (visible: boolean) => void
    private onPipStateChanged: (state: string) => void
    private onGestureUIVisibleChanged: (visible: boolean) => void
    private onGestureAction: (type: GestureType, percent: number, isTouchUp: boolean) => void
    private onDoubleClickAction: () => void
    private getAspectRatioCallback: () => AspectRatio
    private playerType: PlayerType = PlayerType.AVPLAYER
    private viewWidth: number = 0
    private viewHeight: number = 0
    private videoWidth: number = 0
    private videoHeight: number = 0
    private totalDuration: number = 0
    private surfaceWidth: number = 0
    private surfaceHeight: number = 0
    private isDoingLayout: boolean = true
    private isShowSurface: boolean = false
    private isFrameReady: boolean = false
    private gestureHandler: GestureHandler | null = null

    private preparedListener = (): void => {
        this.totalDuration = this.player.getDuration()
        this.gestureHandler?.setTotalDuration(this.totalDuration)
    }

    private videoSizeChangedListener = (width: number, height: number): void => {
        this.videoWidth = width
        this.videoHeight = height
        MediaLogger.d(this.tag, "video size is " + width + " * " + height)
        if (this.getAspectRatio() === AspectRatio.AUTO || this.getAspectRatio() === AspectRatio.STRETCH) {
            this.onAspectRatioChanged()
        }
    }

    private renderFirstFrameListener = (): void => {
        this.isFrameReady = true
        this.setSurfaceVisible(!this.isDoingLayout)
        MediaLogger.i(this.tag, "render first frame, isShowSurface= " + this.isShowSurface)
    }

    private mediaChangedListener = (_source: MediaSource): void => {
        MediaLogger.d(this.tag, "mediaChanged, the first frame is not ready.")
        this.isFrameReady = false
        this.setSurfaceVisible(false)
    }

    private pipStateChangedListener = (state: PiPWindow.PiPState, _reason: string): void => {
        this.onPipStateChanged(state.toString())
    }

    constructor(options: PlayerViewLogicOptions) {
        this.tag = options.tag
        this.player = options.player
        this.gestureAreaConfig = options.gestureAreaConfig
        this.horizontalGestureDamping = options.horizontalGestureDamping
        this.verticalGestureDamping = options.verticalGestureDamping
        this.defaultBrightness = options.defaultBrightness
        this.defaultVolume = options.defaultVolume
        this.autoHideControllerDelay = options.autoHideControllerDelay
        this.onSurfaceSizeChanged = options.onSurfaceSizeChanged
        this.onSurfaceVisibleChanged = options.onSurfaceVisibleChanged
        this.onPipStateChanged = options.onPipStateChanged
        this.onGestureUIVisibleChanged = options.onGestureUIVisibleChanged
        this.onGestureAction = options.onGestureAction
        this.onDoubleClickAction = options.onDoubleClickAction
        this.getAspectRatioCallback = options.getAspectRatio
    }

    getPlayerType(): PlayerType {
        return this.playerType
    }

    getSurfaceWidth(): number {
        return this.surfaceWidth
    }

    getSurfaceHeight(): number {
        return this.surfaceHeight
    }

    getSurfaceVisible(): boolean {
        return this.isShowSurface
    }

    aboutToAppear(isSupportGesture: boolean): void {
        this.setPlayerType()
        MediaLogger.d(this.tag, "init, add the listeners")
        this.player.addOnPreparedListener(this.preparedListener)
            .addOnVideoSizeChangedListener(this.videoSizeChangedListener)
            .addOnRenderFirstFrameListener(this.renderFirstFrameListener)
        this.player.addOnMediaChangedListener(this.mediaChangedListener)
        if (this.player.canUsePip()) {
            this.player.addOnPipStateChangedListener(this.pipStateChangedListener)
        }
        if (isSupportGesture) {
            this.gestureHandler = new GestureHandler(
                this.player, this.gestureAreaConfig, this.horizontalGestureDamping, this.verticalGestureDamping,
                this.defaultBrightness, this.defaultVolume, this.autoHideControllerDelay,
                (visible: boolean): void => {
                    this.onGestureUIVisibleChanged(visible)
                },
                (type: GestureType, percent: number, isTouchUp: boolean): void => {
                    this.onGestureAction(type, percent, isTouchUp)
                },
                (): void => {
                    this.onDoubleClickAction()
                })
        }
    }

    aboutToDisappear(): void {
        MediaLogger.d(this.tag, "release, remove the listeners")
        this.gestureHandler?.release()
        this.player.removeOnPreparedListener(this.preparedListener)
            .removeOnVideoSizeChangedListener(this.videoSizeChangedListener)
            .removeOnRenderFirstFrameListener(this.renderFirstFrameListener)
        this.player.removeOnMediaChangedListener(this.mediaChangedListener)
        if (this.player.canUsePip()) {
            this.player.removeOnPipStateChangedListener(this.pipStateChangedListener)
        }
    }

    onAspectRatioChanged(): void {
        const videoRatio = this.getVideoRatio()
        MediaLogger.i(this.tag, "aspectRatioChanged = " + videoRatio + ", type = " + this.getAspectRatio())
        this.onMeasureSurface(videoRatio)
    }

    onSizeChange(width: number, height: number): boolean {
        this.viewWidth = width
        this.viewHeight = height
        if (this.viewWidth === 0 || this.viewHeight === 0) {
            MediaLogger.attentionW(this.tag, "The view size is " + JSON.stringify({ width: width, height: height }))
            MediaLogger.attentionE(this.tag, "You must set the width and height when create a instance of CcPlayerView!")
            return false
        }
        this.setSurfaceSize(this.viewWidth, this.viewHeight)
        MediaLogger.d(this.tag, "The player view default size is: " + this.viewWidth + " x " + this.viewHeight)
        if (this.getAspectRatio() !== AspectRatio.FILL) {
            this.onAspectRatioChanged()
        }
        this.gestureHandler?.setViewSize(this.viewWidth, this.viewHeight)
        return true
    }

    onResizeAnimationFinish(): void {
        this.isDoingLayout = false
        this.setSurfaceVisible(this.isFrameReady)
        MediaLogger.i(this.tag, "resize completed, show surface= " + this.isShowSurface)
    }

    handleDoubleClickEvent(): void {
        this.gestureHandler?.handleDoubleClickEvent()
    }

    handleTouchEvent(event: TouchEvent): void {
        this.gestureHandler?.handleTouchEvent(event)
    }

    bindIjkXComponent(controller: XComponentController, context: object): string {
        const surfaceId = controller.getXComponentSurfaceId()
        MediaLogger.d(this.tag, "bind surface= " + context)
        this.player.bindXComponent(controller, context)
        return surfaceId
    }

    bindAvPlayerXComponent(controller: XComponentController): string {
        const surfaceId = controller.getXComponentSurfaceId()
        MediaLogger.d(this.tag, "set surface= " + surfaceId)
        this.player.setSurface(surfaceId)
        this.player.setXComponentController(controller)
        return surfaceId
    }

    private setPlayerType(): void {
        const tag = this.player.getTag()
        switch (tag) {
            case IJK.TAG:
                this.playerType = PlayerType.IJKPLAYER
                break
            case AvPlayerImpl.TAG:
                this.playerType = PlayerType.AVPLAYER
                break
            default:
                this.playerType = PlayerType.CUSTOM
                break
        }
        MediaLogger.d(this.tag, "init, player tag= " + tag + ", type= " + this.playerType)
    }

    private getAspectRatio(): AspectRatio {
        return this.getAspectRatioCallback()
    }

    private getVideoRatio(): number {
        switch (this.getAspectRatio()) {
            case AspectRatio.W_16_9:
                return 1.78
            case AspectRatio.W_4_3:
                return 1.33
            case AspectRatio.W_21_9:
                return 2.33
            case AspectRatio.FILL:
                return this.viewWidth / this.viewHeight
            case AspectRatio.STRETCH:
            case AspectRatio.AUTO:
            default:
                if (this.videoHeight > 0) {
                    return this.videoWidth / this.videoHeight
                }
                return this.surfaceWidth / this.surfaceHeight
        }
    }

    private onMeasureSurface(videoRatio: number): void {
        const parentViewRatio = this.viewWidth / this.viewHeight
        let measureWidth: number = 0
        let measureHeight: number = 0
        if (videoRatio < parentViewRatio) {
            if (this.getAspectRatio() === AspectRatio.STRETCH) {
                measureWidth = this.viewWidth
                measureHeight = Math.ceil(this.viewWidth * videoRatio)
            } else {
                measureHeight = this.viewHeight
                measureWidth = Math.ceil(this.viewWidth * videoRatio / parentViewRatio)
            }
        } else {
            if (this.getAspectRatio() === AspectRatio.STRETCH) {
                measureHeight = this.viewHeight
                measureWidth = Math.ceil(this.viewHeight * videoRatio)
            } else {
                measureWidth = this.viewWidth
                measureHeight = Math.ceil(this.viewHeight / videoRatio * parentViewRatio)
            }
        }
        if (this.surfaceWidth !== measureWidth || this.surfaceHeight !== measureHeight) {
            MediaLogger.d(this.tag, "measure surface size changed, resize surface")
            if (!this.isFrameReady) {
                MediaLogger.i(this.tag, "hide to resize surface, the frame is not ready!")
                this.isDoingLayout = true
            }
            this.setSurfaceSize(measureWidth, measureHeight)
        }
        MediaLogger.d(this.tag, "measure surface result = " + this.surfaceWidth + " x " + this.surfaceHeight)
    }

    private setSurfaceSize(width: number, height: number): void {
        this.surfaceWidth = width
        this.surfaceHeight = height
        this.onSurfaceSizeChanged(width, height)
    }

    private setSurfaceVisible(visible: boolean): void {
        this.isShowSurface = visible
        this.onSurfaceVisibleChanged(visible)
    }
}
