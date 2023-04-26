import { CcPlayerView } from '@seagazer/ccplayer';
import { MediaSourceFactory } from '@seagazer/ccplayer';
import { Logger } from '@seagazer/ccplayer';
import { CcPlayer } from '@seagazer/ccplayer';
import { PlayerType } from '@seagazer/ccplayer';
import { PlayerState } from '@seagazer/ccplayer';
import { AspectRatio } from '@seagazer/ccplayer';

const TAG = "CustomPlayerViewPage"

@Entry
@Component
struct CustomPlayerViewPage {
    @State videoRatio: number = AspectRatio.AUTO
    @State videoTitle: string = ""
    @State showTitleBar: boolean = false
    private autoHildeTaskId = -1
    private player: CcPlayer = null
    private prepareListener = () => {
        Logger.d(TAG, "prepared")
        this.videoTitle = this.player.getMediaSource().title
    }
    private completedListener = () => {
        Logger.d(TAG, "play completed")
    }
    private errorListener = (code, message) => {
        Logger.d(TAG, "err =  " + code + ", " + message)
    }
    private stateChangedListener = (newState) => {
        Logger.d(TAG, "new state: " + newState)
    }

    aboutToAppear() {
        if (this.player == null || this.player.getPlayerState() == PlayerState.STATE_NOT_INIT) {
            this.player = CcPlayer.create(PlayerType.VIDEO)
        }
        this.player
            .addOnPreparedListener(this.prepareListener)
            .addOnCompletionListener(this.completedListener)
            .addOnErrorListener(this.errorListener)
            .addOnStateChangedListener(this.stateChangedListener)
    }

    aboutToDisappear() {
        this.player
            .removeOnPreparedListener(this.prepareListener)
            .removeOnCompletionListener(this.completedListener)
            .removeOnErrorListener(this.errorListener)
            .removeOnStateChangedListener(this.stateChangedListener)
            .release()
    }

    @State gestureActionType: number = 0 // 0:seek, 1:volume, 2:brightness
    @State showController: boolean = false
    @State gestureValue: number = 0
    @State gestureMaxValue: number = 0
    private onGestureUIVisible = (isVisible: boolean) => {
        this.showController = isVisible
    }
    private seekUIAction = (seekDuration: number, max: number) => {
        this.gestureActionType = 0
        this.gestureValue = seekDuration
        this.gestureMaxValue = max
    }
    private volumeUIAction = (volume: number, max: number) => {
        this.gestureActionType = 1
        this.gestureValue = volume
        this.gestureMaxValue = max
    }
    private brightnessUIAction = (brightness: number, max: number) => {
        this.gestureActionType = 2
        this.gestureValue = brightness
        this.gestureMaxValue = max
    }

    build() {
        Column() {
            // render surface view
            Stack() {
                CcPlayerView({
                    player: this.player,
                    w: 800,
                    h: 480,
                    asRatio: $videoRatio,
                    isSupportGesture: true,
                    isDefaultGestureUI: false, //custom ui
                    gestureUIListener: this.onGestureUIVisible, //custom ui
                    gestureSeekAction: this.seekUIAction, //custom ui
                    gestureBrightnessAction: this.brightnessUIAction, //custom ui
                    gestureVolumeAction: this.volumeUIAction, //custom ui
                    onTouchCallback: (event) => { // custom ui control
                        switch (event.type) {
                            case TouchType.Down:
                                clearTimeout(this.autoHildeTaskId)
                                this.showTitleBar = !this.showTitleBar
                                break
                            case TouchType.Up:
                            case TouchType.Cancel:
                                if (this.showTitleBar) {
                                    // auto hide title bar 1500ms delay
                                    this.autoHildeTaskId = setTimeout(() => {
                                        this.showTitleBar = false
                                    }, 2000)
                                }
                                break
                        }
                    }
                })
                // custom title bar
                Text(this.videoTitle)
                    .fontColor("#d9ffffff")
                    .textAlign(TextAlign.Center)
                    .width("100%")
                    .height(50)
                    .height(50)
                    .backgroundColor("#cc1a1a1a")
                    .position({ x: 0, y: 0 })
                    .opacity(this.showTitleBar ? 1 : 0)
                    .translate({ y: this.showTitleBar ? 0 : -50 })
                    .animation({
                        duration: 600
                    })
                // custom controller ui
                if (this.showController) {
                    if (this.gestureActionType == 0) { //seek
                        Text("Seek:" + this.gestureValue + "/" + this.gestureMaxValue)
                            .padding(16)
                            .backgroundColor(Color.Green)
                    } else if (this.gestureActionType == 1) { //volume
                        Text("Volume:" + this.gestureValue + "/" + this.gestureMaxValue)
                            .padding(16)
                            .backgroundColor(Color.Red)
                    } else if (this.gestureActionType == 2) { //brightness
                        Text("Brightness:" + this.gestureValue + "/" + this.gestureMaxValue)
                            .padding(16)
                            .backgroundColor(Color.Blue)
                    }
                }
            }
            .width(800)
            .height(480)
            .alignContent(Alignment.Center)
            .clip(true)

            // video ratio settings
            Row() {
                Row() {
                    Radio({ value: "auto", group: "ratio" }).width(45).height(45).onChange(() => {
                        this.videoRatio = AspectRatio.AUTO
                    }).checked(true)
                    Text("auto").fontSize(30)
                }

                Row() {
                    Radio({ value: "21:9", group: "ratio" }).width(45).height(45).onChange(() => {
                        this.videoRatio = AspectRatio.W_21_9
                    }).checked(false)
                    Text("21:9").fontSize(30)
                }.margin({ left: 10 })

                Row() {
                    Radio({ value: "4:3", group: "ratio" }).width(45).height(45).onChange(() => {
                        this.videoRatio = AspectRatio.W_4_3
                    }).checked(false)
                    Text("4:3").fontSize(30)
                }.margin({ left: 10 })

                Row() {
                    Radio({ value: "16:9", group: "ratio" }).width(45).height(45).onChange(() => {
                        this.videoRatio = AspectRatio.W_16_9
                    }).checked(false)
                    Text("16:9").fontSize(30)
                }.margin({ left: 10 })

                Row() {
                    Radio({ value: "fill", group: "ratio" }).width(45).height(45).onChange(() => {
                        this.videoRatio = AspectRatio.FILL
                    }).checked(false)
                    Text("fill").fontSize(30)
                }.margin({ left: 10 })
            }.margin({ top: 50 })
            // play actions
            Row() {
                Button("setMediaSource")
                    .fontSize(30)
                    .width(300)
                    .height(60)
                    .fontColor(Color.White)
                    .onClick(() => {
                        // if bind surface, set data source to play
                        MediaSourceFactory.createAssets(getContext(this), "../../resources/rawfile/test.mp4", "test.mp4").then((data) => {
                            this.player.setMediaSource(data, () => {
                                this.player.start()
                            })
                        })
                    })
                Button("start")
                    .fontSize(30)
                    .width(200)
                    .height(60)
                    .margin({ left: 30 })
                    .fontColor(Color.White)
                    .onClick(() => {
                        this.player.start()
                    })
                Button("pause")
                    .fontSize(30)
                    .width(200)
                    .height(60)
                    .margin({ left: 30 })
                    .fontColor(Color.White)
                    .onClick(() => {
                        this.player.pause()
                    })
            }
            .width("100%")
            .justifyContent(FlexAlign.Center)
            .margin({ top: 50 })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
    }
}