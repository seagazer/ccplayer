import { timeToString } from '../common/Extentions';
import brightness from '@ohos.brightness';
import audio from '@ohos.multimedia.audio';
import { Logger } from '../common/Logger';
import { CcPlayer } from '../CcPlayer';
import { AspectRatio } from '../config/AspectRatio';

const TAG = "[CcPlayerView]"

enum ControlType {
    BRIGHTNESS, PROGRESS, VOLUME
}

const TOUCH_SHOT = 10
const GESTURE_BACKGROUND = "#cc1a1a1a"
const CONTENT_COLOR = "#ffffff"

/**
 * A component to play video, you can control media player with gesture.
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
    player: CcPlayer | null = null
    /**
     * The size of player view.
     */
    @Prop viewSize: SizeOptions
    /**
     * Set the video ratio, the value is from # AspectRatio.
     */
    @Link @Watch("onAspectRatioChanged") asRatio: AspectRatio
    /**
     * Set the delay to auto hide gesture controller ui.
     */
    autoHideControllerDelay = 1500
    /**
     * Set support gesture action to control or not, default is true.
     * Attention: the intercept order is: isSupportGesture > isDefaultGestureUI
     */
    isSupportGesture: boolean = true
    /**
     * Set a callback to observe the touch event of this view.
     */
    onTouchCallback: ((event: TouchEvent) => void) | null = null
    /**
     * Set a callback to observe the surface state when onLoad.
     */
    onSurfaceCreated: (() => void) | null = null
    /**
     * Set a callback to observe the surface state when onDestroy.
     */
    onSurfaceDestroy: (() => void) | null = null
    /**
     * Set use the default gesture ui or not. If set false, you should define your custom ui by
     * # gestureSeekAction, # gestureBrightnessAction and # gestureVolumeAction.
     */
    isDefaultGestureUI: boolean = true
    /**
     * Set a listener to handle the gesture ui visible.
     */
    gestureUIListener: ((isVisible: boolean) => void) | null = null
    /**
     * If the isDefaultGestureUI is false, you should set this callback to handle custom gesture ui for seek action.
     */
    gestureSeekAction: ((seekPosition: number, max: number) => void) | null = null
    /**
     * If the isDefaultGestureUI is false, you should set this callback to handle custom gesture ui for brightness action.
     */
    gestureBrightnessAction: ((brightness: number, max: number) => void) | null = null
    /**
     * If the isDefaultGestureUI is false, you should set this callback to handle custom gesture ui for volume action.
     */
    gestureVolumeAction: ((volume: number, max: number) => void) | null = null
    /*-----------------------------------------------------------------------------------------------*/
    private wSize: number = 0
    private hSize: number = 0
    private controller = new XComponentController()
    private surfaceId: string = ""
    private videoWidth: number = 0
    private videoHeight: number = 0
    private controllerWidth = 250
    private controllerHeight = 80
    @Watch("onControllerVisibleChanged") @State isShowController: boolean = false
    private controlType: ControlType = ControlType.PROGRESS
    private controlEdge = 0 // default is 1/5 of the width
    private downX: number = -1
    private downY: number = -1
    // brightness
    private startBrightness: number = 0 // the drag start brightness for display
    @State targetBrightness: number = 0
    // The maxBrightness is fix value: 255

    // volume
    private startVolume: number = 0 // the drag start volume for display
    @State targetVolume: number = 0
    private maxVolume: number = 0
    // seek duration
    private startDuration = 0 // the drag start position for display
    @State targetDuration: number = 0
    @State totalDuration: number = 0
    private seekMoveSpeed = 3 // this speed is larger, then the move step is small
    private hideControllerTaskId = -1
    private preparedListener = () => {
        this.totalDuration = this.player!.getDuration()
    }
    private videoSizeChangedListener = (width: number, height: number) => {
        this.videoWidth = width
        this.videoHeight = height
        Logger.d(TAG, "video size is " + width + " * " + height)
        // if the ratio mode is AUTO, refresh videoRatio when get the video size info.
        if (this.asRatio == AspectRatio.AUTO || this.asRatio == AspectRatio.STRETCH) {
            this.onAspectRatioChanged()
        }
    }
    private volumeManager: audio.AudioVolumeGroupManager | null = null
    @State videoRatio: number = -1
    private isUserMoved = false
    @State surfaceWidth: number = 0
    @State surfaceHeight: number = 0

    private onAspectRatioChanged() {
        this.videoRatio = this.getVideoRatio()
        Logger.i(TAG, "aspectRatioChanged = " + this.videoRatio + ", type = " + this.asRatio)
        this.onMeasureSurface()
    }

    private onMeasureSurface() {
        let parentViewRatio = this.wSize / this.hSize
        if (this.videoRatio < parentViewRatio) {
            if (this.asRatio == AspectRatio.STRETCH) {
                this.surfaceWidth = this.wSize
                this.surfaceHeight = Math.floor(this.wSize * this.videoRatio)
            } else {
                this.surfaceHeight = this.hSize
                this.surfaceWidth = Math.floor(this.wSize * this.videoRatio / parentViewRatio)
            }
        } else {
            if (this.asRatio == AspectRatio.STRETCH) {
                this.surfaceHeight = this.hSize
                this.surfaceWidth = Math.floor(this.hSize * this.videoRatio)
            } else {
                this.surfaceWidth = this.wSize
                this.surfaceHeight = Math.floor(this.hSize / this.videoRatio * parentViewRatio)
            }
        }
        Logger.d(TAG, "measure surface result = " + this.surfaceWidth + " x " + this.surfaceHeight)
    }

    onControllerVisibleChanged() {
        if (this.gestureUIListener != null) {
            this.gestureUIListener(this.isShowController)
        }
    }

    aboutToAppear() {
        this.player!.addOnPreparedListener(this.preparedListener)
        this.player!.addOnVideoSizeChangedListener(this.videoSizeChangedListener)
        this.initAudio()
    }

    private async initAudio() {
        let audioManager = audio.getAudioManager().getVolumeManager()
        this.volumeManager = await audioManager.getVolumeGroupManager(audio.DEFAULT_VOLUME_GROUP_ID)
        this.volumeManager.getVolume(audio.AudioVolumeType.MEDIA, (err, cur) => {
            if (err) {
                Logger.e(TAG, "getVolume error = " + JSON.stringify(err))
                this.targetVolume = 0
                return
            }
            this.targetVolume = cur
            Logger.d(TAG, "current volume = " + this.targetVolume)
        })
        this.volumeManager.getMaxVolume(audio.AudioVolumeType.MEDIA, (err, max) => {
            if (err) {
                Logger.e(TAG, "getMaxVolume error = " + JSON.stringify(err))
                this.maxVolume = 100
                return
            }
            this.maxVolume = max
            Logger.d(TAG, "max volume = " + this.maxVolume)
        })
    }

    aboutToDisappear() {
        Logger.d(TAG, "release, remove the listeners")
        clearTimeout(this.hideControllerTaskId)
        this.player!.removeOnPreparedListener(this.preparedListener)
        this.player!.removeOnVideoSizeChangedListener(this.videoSizeChangedListener)
    }

    @Builder
    RenderSurface() {
        XComponent({
            id: "ccplayer",
            controller: this.controller,
            type: "surface"
        })
            .width(this.surfaceWidth)
            .height(this.surfaceHeight)
            .onLoad(() => {
                this.surfaceId = this.controller.getXComponentSurfaceId()
                this.player!.setSurface(this.surfaceId)
                if (this.onSurfaceCreated != null) {
                    this.onSurfaceCreated()
                }
            })
            .onDestroy(() => {
                if (this.onSurfaceDestroy != null) {
                    this.onSurfaceDestroy()
                }
            })
    }

    @Builder
    GestureController() {
        if (this.isShowController) {
            if (this.controlType == ControlType.PROGRESS) { // action: seek progress
                Text(timeToString(this.targetDuration) + " / " + timeToString(this.totalDuration))
                    .fontColor(CONTENT_COLOR)
                    .fontSize(22)
                    .width(this.controllerWidth)
                    .height(this.controllerHeight)
                    .padding(16)
                    .textAlign(TextAlign.Center)
                    .backgroundColor(GESTURE_BACKGROUND)
                    .border({ radius: 8 })
            } else if (this.controlType == ControlType.BRIGHTNESS) { // action: brightness
                Row() {
                    Image($r('app.media.ic_public_brightness'))
                        .height(this.controllerHeight / 2).aspectRatio(1)
                        .margin({ right: 10 })
                    Progress({ style: ProgressStyle.Capsule, value: this.targetBrightness, total: 255 })
                        .height(this.controllerHeight / 6)
                        .layoutWeight(1)
                        .color($r('sys.color.ohos_id_color_emphasize'))
                        .backgroundColor(CONTENT_COLOR)
                }
                .padding(16)
                .width(this.controllerWidth)
                .height(this.controllerHeight)
                .backgroundColor(GESTURE_BACKGROUND)
                .border({ radius: 8 })
            } else if (this.controlType == ControlType.VOLUME) { // action: volume
                Row() {
                    Image($r('app.media.ic_public_sound'))
                        .height(this.controllerHeight / 2).aspectRatio(1)
                        .margin({ right: 10 })
                    Progress({ style: ProgressStyle.Capsule, value: this.targetVolume, total: this.maxVolume })
                        .height(this.controllerHeight / 6)
                        .layoutWeight(1)
                        .color($r('sys.color.ohos_id_color_emphasize'))
                        .backgroundColor(CONTENT_COLOR)
                }
                .padding(16)
                .width(this.controllerWidth)
                .height(this.controllerHeight)
                .backgroundColor(GESTURE_BACKGROUND)
                .border({ radius: 8 })
            }
        }
    }

    build() {
        Stack() {
            // surface view
            this.RenderSurface()
            if (this.isDefaultGestureUI && this.isSupportGesture) {
                // gesture control
                this.GestureController()
            }
        }
        .gesture(TapGesture({ count: 2 }).onAction(() => {
            // the player is prepared
            if (this.totalDuration > 0) {
                Logger.d(TAG, "current state = " + this.player!.getPlayerState())
                if (this.player!.isPlaying()) {
                    this.player!.pause()
                } else {
                    this.player!.start()
                }
            }
        }))
        .onTouch((event) => {
            if (this.isSupportGesture) {
                this.onTouchEvent(event)
            }
        })
        .size(this.viewSize)
        .onAreaChange((_, newSize) => {
            this.wSize = newSize.width as number
            this.hSize = newSize.height as number
            this.surfaceWidth = this.wSize
            this.surfaceHeight = this.hSize
            if (this.wSize == 0 || this.hSize == 0) {
                Logger.e(TAG, "The viewSize of this view is not set available!")
                throw new Error("You must set the width and height when create a instance of CcPlayerView!")
            }
            Logger.d(TAG, "The player view size is: " + this.wSize + " x " + this.hSize)
            this.controlEdge = this.wSize / 5
            this.onAspectRatioChanged()
        })
        .alignContent(Alignment.Center)
        .backgroundColor("#000000")
        .clip(true)
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
                return this.wSize / this.hSize
            case AspectRatio.STRETCH:
            case AspectRatio.AUTO:
            default:
                return this.videoWidth / this.videoHeight
        }
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
        if (this.onTouchCallback != null) {
            this.onTouchCallback(event)
        }
    }

    private handleTouchDown(touchEvent: TouchObject) {
        clearTimeout(this.hideControllerTaskId)
        this.isShowController = false
        this.downX = touchEvent.x
        this.downY = touchEvent.y
        if (this.downX < this.controlEdge) {
            // brightness
            this.controlType = ControlType.BRIGHTNESS
            // todo get current brightness, no api for current version
            this.startBrightness = this.targetBrightness
        }
        else if (this.downX > this.controlEdge && this.downX < (this.wSize - this.controlEdge)) {
            // progress
            this.controlType = ControlType.PROGRESS
            this.targetDuration = this.player!.getCurrentPosition()
            this.startDuration = this.targetDuration
            Logger.d(TAG, "down: start duration = " + this.startDuration)
        } else if (this.downX > (this.wSize - this.controlEdge)) {
            // volume
            this.controlType = ControlType.VOLUME
            this.volumeManager!.getVolume(audio.AudioVolumeType.MEDIA, (err, cur) => {
                if (err) {
                    Logger.e(TAG, "getVolume error = " + JSON.stringify(err))
                }
                Logger.d(TAG, "down: start volume = " + this.targetVolume)
                this.targetVolume = cur
                this.startVolume = this.targetVolume
            })
        }
    }

    private handleTouchMove(touchEvent: TouchObject) {
        let dx = touchEvent.x - this.downX
        let dy = touchEvent.y - this.downY
        if (Math.abs(dx) > TOUCH_SHOT || Math.abs(dy) > TOUCH_SHOT) {
            this.isUserMoved = true
            this.isShowController = true
            switch (this.controlType) {
            // handle seek progress
                case ControlType.PROGRESS:
                    let moveDistance = Math.floor(dx)
                    let seekPercent = moveDistance / (this.wSize - 2 * this.controlEdge)
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
                    if (this.gestureSeekAction != null) {
                        this.gestureSeekAction(this.targetDuration, this.totalDuration)
                    }
                    break
            // handle set volume
                case ControlType.VOLUME:
                    let moveDistance3 = -Math.floor(dy)
                    let volumePercent = moveDistance3 / (this.hSize - 2 * this.controlEdge)
                    let volumeValue = Math.floor(this.maxVolume * volumePercent)
                    let volumeTemp = this.startVolume + volumeValue
                    if (volumeTemp >= this.maxVolume) {
                        this.targetVolume = this.maxVolume
                    } else if (volumeTemp <= 0) {
                        this.targetVolume = 0
                    } else {
                        this.targetVolume = volumeTemp
                    }
                    try {
                        this.volumeManager!.setVolume(audio.AudioVolumeType.MEDIA, this.targetVolume)
                    } catch (err) {
                        Logger.e(TAG, "set volume error = " + JSON.stringify(err))
                    }
                    Logger.d(TAG, `targetVolume = ${this.targetVolume}`)
                // callback volume action for custom ui
                    if (this.gestureVolumeAction != null) {
                        this.gestureVolumeAction(this.targetVolume, this.maxVolume)
                    }
                    break
            // handle set brightness
                case ControlType.BRIGHTNESS:
                    let moveDistance2 = -Math.floor(dy)
                    let brightnessPercent = moveDistance2 / (this.hSize - 2 * this.controlEdge)
                    let brightnessValue = Math.floor(255 * brightnessPercent)
                    let brightnessTemp = this.startBrightness + brightnessValue
                    if (brightnessTemp >= 255) {
                        this.targetBrightness = 255
                    } else if (brightnessTemp <= 0) {
                        this.targetBrightness = 0
                    } else {
                        this.targetBrightness = brightnessTemp
                    }
                    Logger.d(TAG, `targetBrightness = ${this.targetBrightness}`)
                    try {
                        brightness.setValue(this.targetBrightness)
                    } catch (err) {
                        Logger.e(TAG, "set brightness error = " + JSON.stringify(err))
                    }
                // callback brightness action for custom ui
                    if (this.gestureBrightnessAction != null) {
                        this.gestureBrightnessAction(this.targetBrightness, 255)
                    }
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
            case ControlType.PROGRESS:
                this.player!.seekTo(this.targetDuration)
                Logger.d(TAG, `seek targetDuration = ${this.targetDuration}`)
                break
            case ControlType.BRIGHTNESS:
            // do nothing, the brightness is changed when touch move
                break
            case ControlType.VOLUME:
            // do nothing, the volume is changed when touch move
                break
        }
        this.downX = -1
        this.downY = -1
        this.hideControllerTaskId = setTimeout(() => {
            this.isShowController = false
        }, this.autoHideControllerDelay)
    }
}