import { Logger } from '../helper/Logger';
import { TimeConverter } from '../helper/TimeConverter';
import { MediaPlayer } from '../MediaPlayer';
import display from '@ohos.display';
import brightness from '@ohos.brightness';
import audio from '@ohos.multimedia.audio';

const TAG = "LitePlayerView"

enum ControlType {
    BRIGHTNESS, PROGRESS, VOLUME
}

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


// todo 设置画面比例
// todo 设置画面亮度
// todo 设置画面沉浸
// todo 控制栏
// todo 标题栏

@Component
export struct LitePlayerView {
    private controller = new XComponentController()
    private player: MediaPlayer
    private surfaceId: string
    private width: number = 720
    private height: number  = 480
    private controllerWidth = 200
    private controllerHeight = 80
    @State isShowController: boolean = false
    private controlType: ControlType = ControlType.BRIGHTNESS
    private startDuration = 0
    private touchShot = 10
    private edge = 20
    private downX: number = -1
    private downY: number = -1
    @State targetBrightness: number = 20
    @State targetVolume: number = 20
    private maxVolume: number = 0
    @State targetDuration: number = 0
    @State totalDuration: number = 0
    private hideTaskId = -1
    private seekSpeed = 3
    private preparedListener = () => {
        this.totalDuration = this.player.getDuration()
    }
    private audioManager

    async aboutToAppear() {
        this.player.addOnPreparedListener(this.preparedListener)
        this.audioManager = audio.getAudioManager()
        this.audioManager.getVolume(audio.AudioVolumeType.MEDIA, (err, cur) => {
            this.targetVolume = cur
            Logger.d(TAG, "current volume = " + this.targetVolume)
        })
        this.audioManager.getMaxVolume(audio.AudioVolumeType.MEDIA, (err, max) => {
            this.maxVolume = max
            Logger.d(TAG, "max volume = " + this.maxVolume)
        })

        let data = await display.getDefaultDisplay()
        Logger.d(TAG, "display width= " + data.width + ", height= " + data.height)
        let displayWidth = data.width
        this.width = data.width
        this.edge = displayWidth / 5
    }

    aboutToDisappear() {
        this.player.removeOnPreparedListener(this.preparedListener)
    }

    build() {
        Stack() {
            XComponent({
                id: "ccplayer",
                controller: this.controller,
                type: "surface"
            })
                .onLoad(() => {
                    this.surfaceId = this.controller.getXComponentSurfaceId()
                    this.player.setSurface(this.surfaceId)
                })
                .onDestroy(() => {
                })
                .width(this.width)
                .height(this.height)


            // progress gesture
            if (this.isShowController) {
                if (this.controlType == ControlType.PROGRESS) {
                    Text(TimeConverter.timeToString(this.targetDuration) + " / " + TimeConverter.timeToString(this.totalDuration))
                        .fontColor("#cccbcbcb")
                        .fontSize(20)
                        .width(this.controllerWidth)
                        .height(this.controllerHeight)
                        .padding(16)
                        .textAlign(TextAlign.Center)
                        .backgroundColor("#cc5b5b5b")
                        .border({ radius: 12 })
                } else if (this.controlType == ControlType.BRIGHTNESS) {
                    Row() {
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
                } else if (this.controlType == ControlType.VOLUME) {
                    Row() {
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
        }.onTouch((event) => {
            this.onTouchEvent(event)
        })
        .width("100%")
        .height("100%")
        .backgroundColor("#000000")
    }

    onTouchEvent(event) {
        let touchEvent = event.touches[0]
        switch (event.type) {
            case TouchType.Down:
                this.handleTouchStart(touchEvent)
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

    handleTouchStart(touchEvent) {
        clearTimeout(this.hideTaskId)
        this.downX = touchEvent.screenX
        this.downY = touchEvent.screenY
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

    handleTouchMove(touchEvent) {
        let curX = touchEvent.screenX
        let curY = touchEvent.screenY
        let dx = curX - this.downX
        let dy = curY - this.downY
        if (Math.abs(dx) > this.touchShot || Math.abs(dy) > this.touchShot) {
            this.isShowController = true
            switch (this.controlType) {
            // handle seek progress
                case ControlType.PROGRESS:
                    let moveDistance = Math.floor(dx)
                    let percent = moveDistance / (this.width - 2 * this.edge)
                    let seekValue = Math.floor(this.totalDuration / this.seekSpeed * percent)
                    Logger.d(TAG, `startDuration = ${this.startDuration}, seekValue = ${seekValue}`)
                    if (this.startDuration + seekValue > this.totalDuration) {
                        this.targetDuration = this.totalDuration
                    } else {
                        this.targetDuration = this.startDuration + seekValue
                    }
                    Logger.d(TAG, `targetDuration = ${this.targetDuration}`)
                    break
            // handle set brightness
                case ControlType.BRIGHTNESS:
                    let moveDistance2 = Math.floor(dy)
                    let percent2 = moveDistance2 / (this.height / 2)
                    this.targetBrightness = 255 * percent2
                    break
            // handle set volume
                case ControlType.VOLUME:
                    let moveDistance3 = -Math.floor(dy)
                    let percent3 = moveDistance3 / (this.height / 2)
                    let setValue = this.maxVolume * percent3
                    this.targetVolume += setValue
                    if (this.targetVolume < 0) {
                        this.targetVolume = 0
                    } else if (this.targetVolume > this.maxVolume) {
                        this.targetVolume = this.maxVolume
                    }
                    Logger.d(TAG, `targetVolume = ${this.targetVolume}, percent3 = ${percent3}`)
                    this.audioManager.setVolume(audio.AudioVolumeType.MEDIA, this.targetVolume)
                    break
            }
        }
    }

    handleTouchUp() {
        switch (this.controlType) {
            case ControlType.PROGRESS:
                this.player.seekTo(this.targetDuration)
                break
            case ControlType.BRIGHTNESS:
                brightness.setValue(Math.floor(255 * this.targetBrightness / 100))
                break
            case ControlType.VOLUME:
                break
        }
        this.downX = -1
        this.downY = -1
        this.hideTaskId = setTimeout(() => {
            this.isShowController = false
        }, 1500)
    }
}