import { MediaLogger } from '../common/MediaLogger';
import { CcPlayer } from '../CcPlayer';
import { AspectRatio } from './config/AspectRatio';
import { GestureType } from './config/GestureType';
import { GestureAreaConfig } from './config/GestureAreaConfig';

const TAG = "[CcPlayerViewV2]"


const TOUCH_SHOT = 10

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
@ComponentV2
export struct CcPlayerViewV2 {
    /*-------------------------------------outer settings--------------------------------------------*/
    /**
     * The instance of a ccplayer to bind.
     */
    @Param player?: CcPlayer = undefined
    /**
     * The config of gesture action, default is [left:brightness, right:volume].
     */
    @Param gestureAreaConfig: GestureAreaConfig = new GestureAreaConfig()
    /**
     * The damping of progress gesture move, the value must be positive, default is 2.
     */
    @Param horizontalGestureDamping: number = 2
    /**
     * The damping of brightness and volume gesture move, the value must be positive, default is 1.5.
     */
    @Param verticalGestureDamping: number = 1.5
    /**
     * The type of XComponent to render video, default is Surface.
     */
    @Param renderType: XComponentType = XComponentType.SURFACE
    /**
     * Set the video ratio, the value is from # AspectRatio.
     */
    @Param asRatio: AspectRatio = AspectRatio.AUTO
    /**
     * Set the delay to auto hide gesture controller ui, default is 1500ms.
     */
    @Param autoHideControllerDelay: number = 1500
    /**
     * The duration of animation for aspect ratio changed.
     */
    @Param aspectRatioChangeAnimationDuration: number = 150
    /**
     * Set support gesture action to control or not, default is true.
     */
    @Param isSupportGesture: boolean = true
    /**
     * Set a callback to observe the touch event of this view.
     */
    @Param onTouchCallback?: ((event: TouchEvent) => void) = undefined
    /**
     * Set a callback to observe the surface state when onLoad.
     */
    @Param onSurfaceCreated?: ((surfaceId: string) => void) = undefined
    /**
     * Set a callback to observe the surface state when onDestroy.
     */
    @Param onSurfaceDestroy?: ((surfaceId: string) => void) = undefined
    /**
     * Set a listener to handle the gesture ui visible.
     */
    @Param onGestureUIListener?: ((visible: boolean) => void) = undefined
    /**
     * The listener to handle the gesture actions.
     */
    @Param onGestureAction?: (type: GestureType, percent: number, isTouchUp: boolean) => void = undefined
    /**
     * Set the default brightness, the value is [0,1], default is 0.5.
     */
    @Param @Once defaultBrightness: number = 0.5
    /**
     * Set the default volume, the value is [0,1], default is 1.
     */
    @Param @Once defaultVolume: number = 1
    /*-----------------------------------------------------------------------------------------------*/
    private viewWidth: number = 0
    private viewHeight: number = 0
    private controller = new XComponentController()
    private surfaceId: string = ""
    private videoWidth: number = 0
    private videoHeight: number = 0
    private controlType: GestureType = GestureType.PROGRESS
    private downX: number = -1
    private downY: number = -1
    private totalDuration: number = 0
    private gesturePercentResult: number = 0
    private hideControllerTimer: number = -1
    private isUserMoved: boolean = false
    @Local surfaceWidth: number = 0
    @Local surfaceHeight: number = 0
    private isDoingLayout: boolean = true
    @Local isShowSurface: boolean = false
    private isFrameReady: boolean = false
    private currentBrightness: number = this.defaultBrightness
    private currentVolume = this.defaultVolume
    private preparedListener = () => {
        this.totalDuration = this.player!.getDuration()
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

    @Monitor("asRatio")
    onAspectRatioChanged() {
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

    onControllerVisibleChanged(visible: boolean) {
        this.onGestureUIListener && this.onGestureUIListener(visible)
    }

    aboutToAppear() {
        MediaLogger.d(TAG, "init, add the listeners")
        this.player!.addOnPreparedListener(this.preparedListener)
        this.player!.addOnVideoSizeChangedListener(this.videoSizeChangedListener)
        this.player!.addOnRenderFirstFrameListener(this.renderFirstFrameListener)
        this.player!.addOnMediaChangedListener(this.mediaChangedListener)
    }

    aboutToDisappear() {
        MediaLogger.d(TAG, "release, remove the listeners")
        clearTimeout(this.hideControllerTimer)
        this.player!.removeOnPreparedListener(this.preparedListener)
        this.player!.removeOnVideoSizeChangedListener(this.videoSizeChangedListener)
        this.player!.removeOnRenderFirstFrameListener(this.renderFirstFrameListener)
        this.player!.removeOnMediaChangedListener(this.mediaChangedListener)
    }

    build() {
        Stack() {
            // surface view
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
                this.onTouchEvent(event)
            }
        })
        .width('100%')
        .height('100%')
        .onAreaChange((_, newSize) => {
            this.viewWidth = newSize.width as number
            this.viewHeight = newSize.height as number
            if (this.viewWidth == 0 || this.viewHeight == 0) {
                throw new Error("You must set the width and height when create a instance of CcPlayerView!")
            }
            this.surfaceWidth = this.viewWidth
            this.surfaceHeight = this.viewHeight
            MediaLogger.d(TAG, "The player view default size is: " + this.viewWidth + " x " + this.viewHeight)
            if (this.asRatio != AspectRatio.FILL) {
                this.onAspectRatioChanged()
            }
        })
        .alignContent(Alignment.Center)
        .backgroundColor("#FF000000")
        .clip(true)
    }

    private onTouchEvent(event: TouchEvent) {
        let touchEvent = event.touches[0]
        switch (event.type) {
            case TouchType.Down:
                this.handleTouchDown(touchEvent)
                break
            case TouchType.Move:
                this.handleTouchMove(touchEvent)
                break
            case TouchType.Up:
            case TouchType.Cancel:
                this.handleTouchUp()
                break
            default:
                break
        }
        // handle outer touch event
        this.onTouchCallback && this.onTouchCallback(event)
    }

    private handleTouchDown(touchEvent: TouchObject) {
        clearTimeout(this.hideControllerTimer)
        this.onControllerVisibleChanged(false)
        this.downX = touchEvent.x
        this.downY = touchEvent.y
    }

    private handleTouchMove(touchEvent: TouchObject) {
        let dx = touchEvent.x - this.downX
        let dy = touchEvent.y - this.downY
        if (Math.abs(dx) > TOUCH_SHOT || Math.abs(dy) > TOUCH_SHOT) {
            // check the gesture type
            if (!this.isUserMoved) {
                this.isUserMoved = true
                if (Math.abs(dy) > Math.abs(dx)) { // vertical gesture
                    if (this.downX < this.viewWidth / 2) { // left
                        this.controlType = this.gestureAreaConfig.left
                    } else { // right
                        this.controlType = this.gestureAreaConfig.right
                    }
                } else { // horizontal gesture
                    this.controlType = GestureType.PROGRESS
                }
                this.onControllerVisibleChanged(true)
            }
            if (this.controlType == GestureType.PROGRESS) {
                let changePercent = dx / this.viewWidth / this.horizontalGestureDamping
                let begin = this.player!.getCurrentPosition()
                let current = begin + this.totalDuration * changePercent
                let result = this.limit(current, this.totalDuration, 0)
                this.gesturePercentResult = result / this.totalDuration
            } else if (this.controlType == GestureType.VOLUME) {
                let changePercent = -dy / this.viewHeight / this.verticalGestureDamping
                let begin = this.currentVolume
                let current = begin + 1 * changePercent
                let result = this.limit(current, 1, 0)
                this.gesturePercentResult = result / 1
            } else if (this.controlType == GestureType.BRIGHTNESS) {
                let changePercent = -dy / this.viewHeight / this.verticalGestureDamping
                let begin = this.currentBrightness
                let current = begin + 1 * changePercent
                let result = this.limit(current, 1, 0)
                this.gesturePercentResult = result / 1
            }
            this.onGestureAction && this.onGestureAction(this.controlType, this.gesturePercentResult, false)
        }
    }

    private limit(value: number, max: number, min: number): number {
        value = Math.max(value, min)
        value = Math.min(value, max)
        return value
    }

    private handleTouchUp() {
        if (!this.isUserMoved) {
            return
        }
        this.isUserMoved = false
        this.onGestureAction && this.onGestureAction(this.controlType, this.gesturePercentResult, true)
        if (this.controlType == GestureType.VOLUME) {
            this.currentVolume = this.gesturePercentResult
        } else if (this.controlType == GestureType.BRIGHTNESS) {
            this.currentBrightness = this.gesturePercentResult
        }
        this.downX = -1
        this.downY = -1
        this.hideControllerTimer = setTimeout(() => {
            this.onControllerVisibleChanged(false)
        }, this.autoHideControllerDelay)
    }
}