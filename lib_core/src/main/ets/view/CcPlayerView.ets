import { CcPlayer } from '../CcPlayer';
import { PiPWindow } from '@kit.ArkUI';
import { GestureLiveData } from '../overlay/livedata/GestureLiveData';
import { GestureEvent } from '../overlay/CcGestureOverlay';
import { AspectRatio, GestureAreaConfig, GestureType, MediaLogger, IJK } from '@seagazer/ccplayer-base';
import { PlayerType } from '../common/PlayerType';
import { AvPlayerImpl } from '../core/impl/AvPlayerImpl';
import { GestureHandler } from './GestureHandler';

const TAG = "[CcPlayerView]"

/**
 * A component to play video, you can control media player with gesture and change the aspect ratio of the picture.
 *
 * Author: Seagazer
 * Date: 2022/9/12
 *
 * The controller area define:
 * |----  Widget Width  ----|
 * |----|----|----|----|----|
 * |    |              |    |
 * |Brt |   Progress   | Vol|
 * |    |              |    |
 * |____|____|____|____|____|
 */
@Component
export struct CcPlayerView {
    /*-------------------------------------outer settings--------------------------------------------*/
    /**
     * The instance of a ccplayer to bind.
     */
    player?: CcPlayer = undefined
    /**
     * The config of gesture action, default is [left:brightness, right:volume].
     */
    gestureAreaConfig: GestureAreaConfig = new GestureAreaConfig()
    /**
     * The damping of progress gesture move, the value must be positive, default is 2.
     */
    horizontalGestureDamping: number = 2
    /**
     * The damping of brightness and volume gesture move, the value must be positive, default is 1.5.
     */
    verticalGestureDamping: number = 1.5
    /**
     * The type of XComponent to render video, default is Surface.
     */
    renderType: XComponentType = XComponentType.SURFACE
    /**
     * Set the video ratio, the value is from # AspectRatio.
     */
    @Link @Watch("onAspectRatioChanged") asRatio: AspectRatio
    /**
     * Set the delay to auto hide gesture controller ui, default is 1500ms.
     */
    autoHideControllerDelay: number = 1500
    /**
     * The duration of animation for aspect ratio changed.
     */
    aspectRatioChangeAnimationDuration: number = 150
    /**
     * Set support gesture action to control or not, default is true.
     */
    isSupportGesture: boolean = true
    /**
     * Set a callback to observe the touch event of this view.
     */
    onTouchCallback?: ((event: TouchEvent) => void) = undefined
    /**
     * Set a callback to observe the surface state when onLoad.
     */
    onSurfaceCreated?: ((surfaceId: string) => void) = undefined
    /**
     * Set a callback to observe the surface state when onDestroy.
     */
    onSurfaceDestroy?: ((surfaceId: string) => void) = undefined
    /**
     * Set a listener to handle the gesture ui visible.
     */
    onGestureUIListener?: ((visible: boolean) => void) = (visible: boolean) => {
        GestureLiveData.getInstance().setVisibleState(visible)
    }
    /**
     * The listener to handle the gesture actions.
     */
    onGestureAction: (type: GestureType, percent: number, isTouchUp: boolean) => void =
        (type: GestureType, percent: number, isTouchUp: boolean) => {
            if (this.gestureEvent == null) {
                this.gestureEvent = new GestureEvent(this.getUIContext(), type, percent, isTouchUp)
            } else {
                this.gestureEvent.uiContext = this.getUIContext()
                this.gestureEvent.type = type
                this.gestureEvent.percent = percent
                this.gestureEvent.isTouchUp = isTouchUp
            }
            GestureLiveData.getInstance().setGestureState(this.gestureEvent)
        }
    private gestureEvent: GestureEvent | null = null
    /**
     * Set the default brightness, the value is [0,1], default is 0.5.
     */
    defaultBrightness: number = 0.5
    /**
     * Set the default volume, the value is [0,1], default is 1.
     */
    defaultVolume: number = 1
    /*-----------------------------------------------------------------------------------------------*/
    private playerType: PlayerType = PlayerType.AVPLAYER
    private viewWidth: number = 0
    private viewHeight: number = 0
    private controller = new XComponentController()
    private surfaceId: string = ""
    private videoWidth: number = 0
    private videoHeight: number = 0
    private totalDuration: number = 0
    @State surfaceWidth: number = 0
    @State surfaceHeight: number = 0
    private isDoingLayout: boolean = true
    @State isShowSurface: boolean = false
    private isFrameReady: boolean = false
    private gestureHandler: GestureHandler | null = null
    private preparedListener = () => {
        this.totalDuration = this.player!.getDuration()
        this.gestureHandler?.setTotalDuration(this.totalDuration)
    }
    private videoSizeChangedListener = (width: number, height: number) => {
        this.videoWidth = width
        this.videoHeight = height
        MediaLogger.d(TAG, "video size is " + width + " * " + height)
        // if the ratio mode is AUTO or STRETCH, refresh videoRatio when get the video size info.
        if (this.asRatio == AspectRatio.AUTO || this.asRatio == AspectRatio.STRETCH) {
            this.onAspectRatioChanged()
        }
    }
    private renderFirstFrameListener = () => {
        this.isFrameReady = true
        this.isShowSurface = !this.isDoingLayout
        MediaLogger.i(TAG, "render first frame, isShowSurface= " + this.isShowSurface)
    }
    private mediaChangedListener = () => {
        MediaLogger.d(TAG, "mediaChanged, the first frame is not ready.")
        this.isFrameReady = false
        this.isShowSurface = false
    }
    @State pipState: string = ''
    private pipStateChangedListener = (state: PiPWindow.PiPState) => {
        this.pipState = state.toString()
    }

    private onAspectRatioChanged() {
        const videoRatio = this.getVideoRatio()
        MediaLogger.i(TAG, "aspectRatioChanged = " + videoRatio + ", type = " + this.asRatio)
        this.onMeasureSurface(videoRatio)
    }

    private getVideoRatio(): number {
        switch (this.asRatio) {
            case AspectRatio.W_16_9:
                return 1.78 // 16:9
            case AspectRatio.W_4_3:
                return 1.33 // 4:3
            case AspectRatio.W_21_9:
                return 2.33 // 21:9
            case AspectRatio.FILL:
                return this.viewWidth / this.viewHeight
            case AspectRatio.STRETCH: // Auto & stretch mode is dependent to video size.
            case AspectRatio.AUTO:
            default:
                if (this.videoHeight > 0) {
                    return this.videoWidth / this.videoHeight
                } else {
                    return this.surfaceWidth / this.surfaceHeight
                }
        }
    }

    private onMeasureSurface(videoRatio: number) {
        let parentViewRatio = this.viewWidth / this.viewHeight
        let measureWidth: number = 0
        let measureHeight: number = 0
        if (videoRatio < parentViewRatio) {
            if (this.asRatio == AspectRatio.STRETCH) {
                measureWidth = this.viewWidth
                measureHeight = Math.ceil(this.viewWidth * videoRatio)
            } else {
                measureHeight = this.viewHeight
                measureWidth = Math.ceil(this.viewWidth * videoRatio / parentViewRatio)
            }
        } else {
            if (this.asRatio == AspectRatio.STRETCH) {
                measureHeight = this.viewHeight
                measureWidth = Math.ceil(this.viewHeight * videoRatio)
            } else {
                measureWidth = this.viewWidth
                measureHeight = Math.ceil(this.viewHeight / videoRatio * parentViewRatio)
            }
        }
        if (this.surfaceWidth != measureWidth || this.surfaceHeight != measureHeight) {
            MediaLogger.d(TAG, "measure surface size changed, resize surface")
            if (!this.isFrameReady) {
                MediaLogger.i(TAG, "hide to resize surface, the frame is not ready!")
                this.isDoingLayout = true
            }
            this.surfaceWidth = measureWidth
            this.surfaceHeight = measureHeight
        }
        MediaLogger.d(TAG, "measure surface result = " + this.surfaceWidth + " x " + this.surfaceHeight)
    }

    aboutToAppear() {
        this.setPlayerType()
        MediaLogger.d(TAG, "init, add the listeners")
        this.player!.addOnPreparedListener(this.preparedListener)
            .addOnVideoSizeChangedListener(this.videoSizeChangedListener)
            .addOnRenderFirstFrameListener(this.renderFirstFrameListener)
        this.player!.addOnMediaChangedListener(this.mediaChangedListener)
        if (this.player?.canUsePip()) {
            this.player!.addOnPipStateChangedListener(this.pipStateChangedListener)
        }
        if (this.isSupportGesture) {
            this.gestureHandler = new GestureHandler(
                this.player!, this.gestureAreaConfig, this.horizontalGestureDamping, this.verticalGestureDamping,
                this.defaultBrightness, this.defaultVolume, this.autoHideControllerDelay,
                (visible: boolean) => {
                    this.onGestureUIListener && this.onGestureUIListener(visible)
                },
                (type: GestureType, percent: number, isTouchUp: boolean) => {
                    this.onGestureAction && this.onGestureAction(type, percent, isTouchUp)
                })
        }
    }

    private setPlayerType() {
        const tag = this.player!.getTag();
        switch (tag) {
            case IJK.TAG:
                this.playerType = PlayerType.IJKPLAYER;
                break;
            case AvPlayerImpl.TAG:
                this.playerType = PlayerType.AVPLAYER;
                break;
            default:
                this.playerType == PlayerType.CUSTOM;
                break;
        }
        MediaLogger.d(TAG, "init, player tag= " + tag + ", type= " + this.playerType);
    }

    aboutToDisappear() {
        MediaLogger.d(TAG, "release, remove the listeners")
        this.gestureHandler?.release()
        this.player!.removeOnPreparedListener(this.preparedListener)
            .removeOnVideoSizeChangedListener(this.videoSizeChangedListener)
            .removeOnRenderFirstFrameListener(this.renderFirstFrameListener)
        this.player!.removeOnMediaChangedListener(this.mediaChangedListener)
        if (this.player?.canUsePip()) {
            this.player!.removeOnPipStateChangedListener(this.pipStateChangedListener)
        }
    }

    build() {
        Stack() {
            // surface view
            if (this.playerType == PlayerType.IJKPLAYER) {
                XComponent({
                    controller: this.controller,
                    type: this.renderType,
                    id: IJK.ID,
                    libraryname: IJK.NAPI,
                })
                    .width(this.surfaceWidth)
                    .height(this.surfaceHeight)
                    .onLoad((context) => {
                        this.surfaceId = this.controller.getXComponentSurfaceId()
                        MediaLogger.d(TAG, "bind surface= " + context)
                        this.player!.bindXComponent(this.controller, context!)
                        this.onSurfaceCreated && this.onSurfaceCreated(this.surfaceId)
                    })
                    .onDestroy(() => {
                        this.onSurfaceDestroy && this.onSurfaceDestroy(this.surfaceId)
                    })
                    .animation({
                        duration: this.aspectRatioChangeAnimationDuration, onFinish: () => {
                            this.isDoingLayout = false
                            this.isShowSurface = this.isFrameReady
                            MediaLogger.i(TAG, "resize completed, show surface= " + this.isShowSurface)
                        }
                    })
                    .visibility(this.isShowSurface ? Visibility.Visible : Visibility.Hidden)
            } else if (this.playerType == PlayerType.AVPLAYER) {
                XComponent({
                    id: "ccplayer",
                    controller: this.controller,
                    type: this.renderType
                })
                    .width(this.surfaceWidth)
                    .height(this.surfaceHeight)
                    .onLoad(() => {
                        this.surfaceId = this.controller.getXComponentSurfaceId()
                        MediaLogger.d(TAG, "set surface= " + this.surfaceId)
                        this.player!.setSurface(this.surfaceId)
                        this.player!.setXComponentController(this.controller)
                        this.onSurfaceCreated && this.onSurfaceCreated(this.surfaceId)
                    })
                    .onDestroy(() => {
                        this.onSurfaceDestroy && this.onSurfaceDestroy(this.surfaceId)
                    })
                    .animation({
                        duration: this.aspectRatioChangeAnimationDuration, onFinish: () => {
                            this.isDoingLayout = false
                            this.isShowSurface = this.isFrameReady
                            MediaLogger.i(TAG, "resize completed, show surface= " + this.isShowSurface)
                        }
                    })
                    .visibility(this.isShowSurface ? Visibility.Visible : Visibility.Hidden)
            }
            // 添加这个是保证在前一个页面关闭画中画时，播放页能够正常销毁
            Text(this.pipState).visibility(Visibility.None)
        }
        .gesture(TapGesture({ count: 2 }).onAction(() => {
            if (this.isSupportGesture) {
                // the player is prepared
                if (this.totalDuration > 0) {
                    MediaLogger.d(TAG, "current state = " + this.player!.getPlayerState())
                    if (this.player!.isPlaying()) {
                        this.player!.pause()
                    } else {
                        this.player!.start()
                    }
                }
            }
        }))
        .onTouch((event) => {
            if (this.isSupportGesture) {
                this.gestureHandler?.handleTouchEvent(event)
                // handle outer touch event
                this.onTouchCallback && this.onTouchCallback(event)
            }
        })
        .width('100%')
        .height('100%')
        .onSizeChange((_, newSize) => {
            this.viewWidth = newSize.width as number
            this.viewHeight = newSize.height as number
            if (this.viewWidth == 0 || this.viewHeight == 0) {
                MediaLogger.attentionW(TAG, "The view size is " + JSON.stringify(newSize))
                MediaLogger.attentionE(TAG, "You must set the width and height when create a instance of CcPlayerView!")
                return
            }
            this.surfaceWidth = this.viewWidth
            this.surfaceHeight = this.viewHeight
            MediaLogger.d(TAG, "The player view default size is: " + this.viewWidth + " x " + this.viewHeight)
            if (this.asRatio != AspectRatio.FILL) {
                this.onAspectRatioChanged()
            }
            this.gestureHandler?.setViewSize(this.viewWidth, this.viewHeight)
        })
        .alignContent(Alignment.Center)
        .backgroundColor("#FF000000")
        .clip(true)
    }
}