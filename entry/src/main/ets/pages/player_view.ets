import { LitePlayerView } from '@seagazer/ccplayer';
import { MediaSourceFactory } from '@seagazer/ccplayer';
import { Logger } from '@seagazer/ccplayer';
import { MediaPlayer } from '@seagazer/ccplayer';
import { PlayerType } from '@seagazer/ccplayer';
import { PlayerState } from '@seagazer/ccplayer';
import { AspectRatio } from '@seagazer/ccplayer';

const TAG = "PlayerViewPage"

@Entry
@Component
struct PlayerViewPage {
    @State videoRatio: number = AspectRatio.AUTO
    @State videoTitle: string = ""
    @State showTitleBar: boolean = false
    private autoHildeTaskId = -1
    private player: MediaPlayer = null
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
            this.player = MediaPlayer.create(PlayerType.VIDEO)
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

    build() {
        Column() {
            // render surface view
            Stack() {
                LitePlayerView({
                    player: this.player,
                    width: 800,
                    height: 480,
                    aspectRatio: $videoRatio,
                    isSupportGesture: true,
                    onTouchCallback: (event) => {
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
                // title bar
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
            .width(800)
            .height(480)
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
                Button("setDataSource")
                    .fontSize(30)
                    .width(300)
                    .height(60)
                    .fontColor(Color.White)
                    .onClick(() => {
                        // if bind surface, set data source to play
                        MediaSourceFactory.createAssets(getContext(this), "test.mp4", "../../resources/rawfile/test.mp4").then((data) => {
                            this.player.setDataSource(data)
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