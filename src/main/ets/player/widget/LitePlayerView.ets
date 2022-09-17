import { timeToString } from '../common/Extentions';
import brightness from '@ohos.brightness';
import audio from '@ohos.multimedia.audio';
import { Logger } from '../common/Logger';
import { MediaPlayer } from '../MediaPlayer';
import { AspectRatio } from '../config/AspectRatio'

const TAG = "LitePlayerView"

enum ControlType {
    BRIGHTNESS, PROGRESS, VOLUME
}

const TOUCH_SHOT = 10

// todo 设置画面沉浸
// todo 控制栏
// todo 标题栏

/**
 * A component to play video, you can use gesture to control the mediaplayer.
 *
 * The controller area define:
 * |----  Widget Width  ----|
 * |------------------------|
 * |    |              |    |
 * |Brt |   Progress   | Vol|
 * |    |              |    |
 * |____|____|____|____|____|
 */
@Component
export struct LitePlayerView {
    /*----------------------------outer settings-----------------------------------*/
    private player: MediaPlayer
    private width: number = 0
    private height: number  = 0
    private isSupportGesture: boolean = false
    @Link @Watch("onAspectRatioChanged") aspectRatio: AspectRatio
    /*-----------------------------------------------------------------------------*/
    private controller = new XComponentController()
    private surfaceId: string
    private videoWidth: number = 0
    private videoHeight: number = 0
    private controllerWidth = 250
    private controllerHeight = 80
    @State isShowController: boolean = false
    private controlType: ControlType = ControlType.PROGRESS
    private edge = 20
    private downX: number = -1
    private downY: number = -1
    @State targetBrightness: number = 20
    @State targetVolume: number = 20
    private maxVolume: number = 0
    private startDuration = 0 // the drag start position for display
    @State targetDuration: number = 0
    @State totalDuration: number = 0
    private hideTaskId = -1
    private seekSpeed = 3
    private preparedListener = () => {
        this.totalDuration = this.player.getDuration()
    }
    private videoSizeChangeListener = (width, height) => {
        this.videoWidth = width
        this.videoHeight = height
        // if the ratio mode is AUTO, refresh videoRatio when get the video size info.
        if (this.aspectRatio == AspectRatio.AUTO) {
            this.onAspectRatioChanged()
        }
    }
    private audioManager: audio.AudioManager
    @State videoRatio: number = -1

    private onAspectRatioChanged() {
        this.videoRatio = this.getVideoRatio()
        Logger.d(TAG, "aspectRatioChanged = " + this.videoRatio)
    }

    async aboutToAppear() {
        this.player.addOnPreparedListener(this.preparedListener)
        this.player.addOnVideoSizeChangedListener(this.videoSizeChangeListener)
        this.audioManager = audio.getAudioManager()
        this.audioManager.getVolume(audio.AudioVolumeType.MEDIA, (err, cur) => {
            this.targetVolume = cur
            Logger.d(TAG, "current volume = " + this.targetVolume)
        })
        this.audioManager.getMaxVolume(audio.AudioVolumeType.MEDIA, (err, max) => {
            this.maxVolume = max
            Logger.d(TAG, "max volume = " + this.maxVolume)
        })
        if (this.width == 0 || this.height == 0) {
            // TODO js程序不会崩溃
            throw new Error("You must set the width and height when create a instance of LitePlayerView!")
        }
        Logger.d(TAG, "The litePlayerView size is: " + this.width + " x " + this.height)
        this.edge = this.width / 5
    }

    aboutToDisappear() {
        this.player.removeOnPreparedListener(this.preparedListener)
        this.player.removeOnVideoSizeChangedListener(this.videoSizeChangeListener)
        this.player.release()
    }

    build() {
        Stack() {
            // surface view
            XComponent({
                id: "liteplayerview",
                controller: this.controller,
                type: "surface"
            })
                .onLoad(() => {
                    this.surfaceId = this.controller.getXComponentSurfaceId()
                    this.player.setSurface(this.surfaceId)
                })
                .aspectRatio(this.videoRatio)

            // progress gesture
            if (this.isShowController) {
                if (this.controlType == ControlType.PROGRESS) { // action: seek progress
                    Text(timeToString(this.targetDuration) + " / " + timeToString(this.totalDuration))
                        .fontColor("#d9ffffff")
                        .fontSize(20)
                        .width(this.controllerWidth)
                        .height(this.controllerHeight)
                        .padding(16)
                        .textAlign(TextAlign.Center)
                        .backgroundColor("#cc5b5b5b")
                        .border({ radius: 12 })
                } else if (this.controlType == ControlType.BRIGHTNESS) { // action: brightness
                    Row() {
                        Text("亮度").fontColor("#d9ffffff").margin({ right: 10 })
                        Progress({ style: ProgressStyle.Capsule, value: this.targetBrightness, total: 255 })
                            .height("10%")
                            .layoutWeight(1)
                            .backgroundColor("#ccffffff")
                    }
                    .padding(16)
                    .width(this.controllerWidth)
                    .height(this.controllerHeight)
                    .backgroundColor("#cc5b5b5b")
                    .border({ radius: 12 })
                } else if (this.controlType == ControlType.VOLUME) { // action: volume
                    Row() {
                        Text("音量").fontColor("#d9ffffff").margin({ right: 10 })
                        Progress({ style: ProgressStyle.Capsule, value: this.targetVolume, total: this.maxVolume })
                            .height("10%")
                            .layoutWeight(1)
                            .backgroundColor("#ccffffff")
                    }
                    .padding(16)
                    .width(this.controllerWidth)
                    .height(this.controllerHeight)
                    .backgroundColor("#cc5b5b5b")
                    .border({ radius: 12 })
                }
            }
        }
        .onTouch((event) => {
            if (this.isSupportGesture) {
                this.onTouchEvent(event)
            }
        })
        .width(this.width)
        .height(this.height)
        .alignContent(Alignment.Center)
        .backgroundColor("#000000")
    }

    private getVideoRatio(): number {
        switch (this.aspectRatio) {
            case AspectRatio.W_16_9:
                return 1.78 // 16/9
            case AspectRatio.W_4_3:
                return 1.33 // 4/3
            case AspectRatio.W_21_9:
                return 2.33 // 21/9
            case AspectRatio.FILL:
                return this.width / this.height
            case AspectRatio.STRETCH:
        // TODO 保持比例填充
            case AspectRatio.ORIGIN:
        // TODO 原始像素
            case AspectRatio.AUTO:
                return this.videoWidth / this.videoHeight
        }
        return -1
    }

    private onTouchEvent(event) {
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
        }
    }

    private handleTouchDown(touchEvent) {
        clearTimeout(this.hideTaskId)
        this.isShowController = false
        this.downX = touchEvent.x
        this.downY = touchEvent.y
        if (this.downX < this.edge) {
            this.controlType = ControlType.BRIGHTNESS
            // todo get current brightness
        }
        else if (this.downX > this.edge && this.downX < (this.width - this.edge)) {
            this.controlType = ControlType.PROGRESS
            this.targetDuration = this.player.getCurrentPosition()
            this.startDuration = this.targetDuration
            Logger.d(TAG, "down: start duration = " + this.startDuration)
        } else if (this.downX > (this.width - this.edge)) {
            this.controlType = ControlType.VOLUME
            this.audioManager.getVolume(audio.AudioVolumeType.MEDIA, (err, cur) => {
                Logger.d(TAG, "down: start volume = " + this.targetVolume)
                this.targetVolume = cur
            })
        }
        Logger.d(TAG, "control type = " + this.controlType)
    }

    private handleTouchMove(touchEvent) {
        let dx = touchEvent.x - this.downX
        let dy = touchEvent.y - this.downY
        if (Math.abs(dx) > TOUCH_SHOT || Math.abs(dy) > TOUCH_SHOT) {
            this.isShowController = true
            switch (this.controlType) {
            // handle seek progress
                case ControlType.PROGRESS:
                    let moveDistance = Math.floor(dx)
                    let percent = moveDistance / (this.width - 2 * this.edge)
                    let seekValue = Math.floor(this.totalDuration / this.seekSpeed * percent)
                    let temp = this.startDuration + seekValue
                    if (temp >= this.totalDuration) {
                        this.targetDuration = this.totalDuration
                    } else if (temp <= 0) {
                        this.targetDuration = 0
                    } else {
                        this.targetDuration = temp
                    }
                    break
            // handle set brightness
                case ControlType.BRIGHTNESS:
                    let moveDistance2 = -Math.floor(dy)
                    let percent2 = moveDistance2 / this.height
                    let temp2 = 255 * percent2
                    if (temp2 >= 255) {
                        this.targetBrightness = 255
                    } else if (temp2 <= 0) {
                        this.targetBrightness = 0
                    } else {
                        this.targetBrightness = temp2
                    }
                    brightness.setValue(this.targetBrightness)
                    Logger.d(TAG, `targetBrightness = ${this.targetBrightness}, percent = ${percent2}`)
                    break
            // handle set volume
                case ControlType.VOLUME:
                    let moveDistance3 = -Math.floor(dy)
                    let percent3 = moveDistance3 / this.height
                    let setValue = this.maxVolume * percent3
                    let temp3 = this.targetVolume + setValue
                    if (temp3 >= this.maxVolume) {
                        this.targetVolume = this.maxVolume
                    } else if (temp3 <= 0) {
                        this.targetVolume = 0
                    } else {
                        this.targetVolume = temp3
                    }
                    this.audioManager.setVolume(audio.AudioVolumeType.MEDIA, this.targetVolume)
                    Logger.d(TAG, `targetVolume = ${this.targetVolume}, percent = ${percent3}`)
                    break
            }
        }
    }

    private handleTouchUp() {
        switch (this.controlType) {
            case ControlType.PROGRESS:
                this.player.seekTo(this.targetDuration)
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
        this.hideTaskId = setTimeout(() => {
            this.isShowController = false
        }, 1000)
    }
}