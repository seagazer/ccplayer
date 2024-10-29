import { MediaLogger } from '../common/MediaLogger';
import { CcPlayer } from '../CcPlayer';
import { AspectRatio } from '../config/AspectRatio';
import { GestureType } from '../config/GestureType';

const TAG = "[CcPlayerView]"


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
@Component
export struct CcPlayerView {
    /*-------------------------------------outer settings--------------------------------------------*/
    /**
     * The instance of a ccplayer to bind.
     */
    player?: CcPlayer = undefined
    /**
     * The percent of width of view to handle volume or brightness gesture, default is |0.2|0.6|0.2|.
     */
    controlEdgePercent: number = 0.2
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
    onGestureUIListener?: ((visible: boolean) => void) = undefined
    /**
     * The listener to handle the gesture actions.
     */
    onGestureAction?: (type: GestureType, percent: number, isTouchUp: boolean) => void
    /*-----------------------------------------------------------------------------------------------*/
    private viewWidth: number = 0
    private viewHeight: number = 0
    private controller = new XComponentController()
    private surfaceId: string = ""
    private videoWidth: number = 0
    private videoHeight: number = 0
    private controlType: GestureType = GestureType.PROGRESS
    private controlEdge = 0 // default is 1/5 of the width
    private downX: number = -1
    private downY: number = -1
    private startDuration = 0 // the drag start position for display
    private totalDuration: number = 0
    private targetDuration: number = 0
    private volumePercent: number = 0
    private brightnessPercent: number = 0
    private seekMoveSpeed: number = 3 // this speed is larger, then the move step is small
    private hideControllerTimer: number = -1
    private isUserMoved: boolean = false
    @State surfaceWidth: number = 0
    @State surfaceHeight: number = 0
    private isDoingLayout: boolean = true
    @State isShowSurface: boolean = true
    private isFrameReady: boolean = false
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
                this.surfaceHeight = this.viewHeight
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
            this.controlEdge = this.viewWidth * this.controlEdgePercent
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
        if (this.downX < this.controlEdge) {
            // brightness
            this.controlType = GestureType.BRIGHTNESS
        } else if (this.downX > this.controlEdge && this.downX < (this.viewWidth - this.controlEdge)) {
            // progress
            this.controlType = GestureType.PROGRESS
            this.targetDuration = this.player!.getCurrentPosition()
            this.startDuration = this.targetDuration
            MediaLogger.d(TAG, "down: start duration = " + this.startDuration)
        } else if (this.downX > (this.viewWidth - this.controlEdge)) {
            // volume
            this.controlType = GestureType.VOLUME
        }
    }

    private handleTouchMove(touchEvent: TouchObject) {
        let dx = touchEvent.x - this.downX
        let dy = touchEvent.y - this.downY
        if (Math.abs(dx) > TOUCH_SHOT || Math.abs(dy) > TOUCH_SHOT) {
            this.isUserMoved = true
            this.onControllerVisibleChanged(true)
            switch (this.controlType) {
            // handle seek progress
                case GestureType.PROGRESS:
                    let moveDistance = Math.floor(dx)
                    let seekPercent = moveDistance / (this.viewWidth - 2 * this.controlEdge)
                    let seekValue = Math.floor(this.totalDuration / this.seekMoveSpeed * seekPercent)
                    let seekTemp = this.startDuration + seekValue
                    if (seekTemp >= this.totalDuration) {
                        this.targetDuration = this.totalDuration
                    } else if (seekTemp <= 0) {
                        this.targetDuration = 0
                    } else {
                        this.targetDuration = seekTemp
                    }
                    // callback seek action for custom ui
                    let percent = this.targetDuration / this.totalDuration
                    this.onGestureAction && this.onGestureAction(GestureType.PROGRESS, percent, false)
                    break
            // handle set volume
                case GestureType.VOLUME:
                    let moveDistance3 = -Math.floor(dy)
                    this.volumePercent = moveDistance3 / (this.viewHeight - 2 * this.controlEdge)
                    this.volumePercent = Math.max(0, this.volumePercent)
                    this.volumePercent = Math.min(1, this.volumePercent)
                    MediaLogger.d(TAG, `volumePercent = ${this.volumePercent}`)
                    // callback volume action for custom ui
                    this.onGestureAction && this.onGestureAction(GestureType.VOLUME, this.volumePercent, false)
                    break
            // handle set brightness
                case GestureType.BRIGHTNESS:
                    let moveDistance2 = -Math.floor(dy)
                    this.brightnessPercent = moveDistance2 / (this.viewHeight - 2 * this.controlEdge)
                    this.brightnessPercent = Math.max(0, this.brightnessPercent)
                    this.brightnessPercent = Math.min(1, this.brightnessPercent)
                    MediaLogger.d(TAG, `brightnessPercent = ${this.brightnessPercent}`)
                    this.onGestureAction && this.onGestureAction(GestureType.BRIGHTNESS, this.brightnessPercent, false)
                    break
                default:
                    break
            }
        }
    }

    private handleTouchUp() {
        if (!this.isUserMoved) {
            return
        }
        this.isUserMoved = false
        switch (this.controlType) {
            case GestureType.PROGRESS:
                if (this.onGestureAction) {
                    let percent = this.targetDuration / this.totalDuration
                    this.onGestureAction(GestureType.PROGRESS, percent, true)
                }
                break
            case GestureType.BRIGHTNESS:
                this.onGestureAction && this.onGestureAction(GestureType.BRIGHTNESS, this.brightnessPercent, true)
                break
            case GestureType.VOLUME:
                this.onGestureAction && this.onGestureAction(GestureType.VOLUME, this.volumePercent, true)
                break
        }
        this.downX = -1
        this.downY = -1
        this.hideControllerTimer = setTimeout(() => {
            this.onControllerVisibleChanged(false)
        }, this.autoHideControllerDelay)
    }
}