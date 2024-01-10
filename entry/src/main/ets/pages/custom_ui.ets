import { CcPlayerView } from '@seagazer/ccplayer';
import { MediaSourceFactory } from '@seagazer/ccplayer';
import { CcPlayer } from '@seagazer/ccplayer';
import { PlayerType } from '@seagazer/ccplayer';
import { PlayerState } from '@seagazer/ccplayer';
import { AspectRatio } from '@seagazer/ccplayer';
import { Logger } from '../Logger';

@Extend(Button)
function btnStyle() {
    .fontSize(18)
    .width(100)
    .height(50)
    .fontColor(Color.White)
    .margin({ left: 30 })
}

const TAG = "CustomPlayerViewPage"

@Entry
@Component
struct CustomPlayerViewPage {
    @State videoRatio: number = AspectRatio.AUTO
    @State videoTitle: string = ""
    @State showTitleBar: boolean = false
    private autoHildeTaskId = -1
    private player: CcPlayer | null = null
    private prepareListener = () => {
        Logger.d(TAG, "prepared")
        this.videoTitle = this.player!.getMediaSource().title
    }

    aboutToAppear() {
        if (this.player == null || this.player.getPlayerState() == PlayerState.STATE_NOT_INIT) {
            this.player = CcPlayer.create(PlayerType.VIDEO)
        }
        this.player.addOnPreparedListener(this.prepareListener)
    }

    aboutToDisappear() {
        this.player!.removeOnPreparedListener(this.prepareListener)
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

    @Builder
    CustomTitleUI() {
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
    }

    @Builder
    CustomGestureUI() {
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

    build() {
        Column() {
            // render surface view
            Stack() {
                CcPlayerView({
                    player: this.player,
                    w: 480,
                    h: 300,
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
                this.CustomTitleUI()
                // custom controller ui
                this.CustomGestureUI()
            }
            .width(480)
            .height(300)
            .alignContent(Alignment.Center)
            .clip(true)

            // play actions
            Row() {
                Button("setSrc")
                    .btnStyle()
                    .onClick(() => {
                        // if bind surface, set data source to play
                        MediaSourceFactory.createFile(getContext(this).filesDir + "/test.mp4", "test.mp4")
                            .then((data) => {
                                this.player!.setMediaSource(data, () => {
                                    this.player!.start()
                                })
                            })
                    })
                Button("start")
                    .btnStyle()
                    .onClick(() => {
                        this.player!.start()
                    })
                Button("pause")
                    .btnStyle()
                    .onClick(() => {
                        this.player!.pause()
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