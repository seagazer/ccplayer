import {
    AspectRatio,
    CcPlayer,
    CcPlayerView,
    MediaSourceFactory,
    PlayerState,
    PlayerType
} from '@seagazer/ccplayer';
import display from '@ohos.display';
import { Logger } from '../Logger';

@Extend(Button)
function btnStyle() {
    .fontSize(18)
    .width(100)
    .height(50)
    .fontColor(Color.White)
    .margin({ left: 30 })
}

const TAG = "[PlayerViewPage]"

@Entry
@Component
struct PlayerViewPage {
    @State videoRatio: number = AspectRatio.AUTO
    @State showTitleBar: boolean = false
    private player: CcPlayer | null = null
    private w = 0
    private h = 0

    aboutToAppear() {
        this.w = display.getDefaultDisplaySync().width
        this.h = this.w / 16 * 9
        Logger.d(TAG, "size = " + this.w + "x" + this.h)
        if (this.player == null || this.player.getPlayerState() == PlayerState.STATE_NOT_INIT) {
            this.player = CcPlayer.create(PlayerType.VIDEO)
        }
    }

    aboutToDisappear() {
        this.player!.release()
    }

    build() {
        Column() {
            // render surface view
            Stack().width(this.w)
                .height(this.h).backgroundColor(Color.Red)

            Stack() {
                CcPlayerView({
                    player: this.player,
                    w: this.w,
                    h: this.h,
                    asRatio: $videoRatio,
                    isSupportGesture: true,
                })
            }
            .width(this.w)
            .height(this.h)
            .clip(true)

            // video ratio settings
            Scroll() {
                Row() {
                    Row() {
                        Radio({ value: "auto", group: "ratio" }).width(32).height(32).onChange(() => {
                            this.videoRatio = AspectRatio.AUTO
                        }).checked(true)
                        Text("auto").fontSize(18)
                    }

                    Row() {
                        Radio({ value: "21:9", group: "ratio" }).width(32).height(32).onChange(() => {
                            this.videoRatio = AspectRatio.W_21_9
                        }).checked(false)
                        Text("21:9").fontSize(18)
                    }.margin({ left: 10 })

                    Row() {
                        Radio({ value: "4:3", group: "ratio" }).width(32).height(32).onChange(() => {
                            this.videoRatio = AspectRatio.W_4_3
                        }).checked(false)
                        Text("4:3").fontSize(18)
                    }.margin({ left: 10 })

                    Row() {
                        Radio({ value: "16:9", group: "ratio" }).width(32).height(32).onChange(() => {
                            this.videoRatio = AspectRatio.W_16_9
                        }).checked(false)
                        Text("16:9").fontSize(18)
                    }.margin({ left: 10 })

                    Row() {
                        Radio({ value: "fill", group: "ratio" }).width(32).height(32).onChange(() => {
                            this.videoRatio = AspectRatio.FILL
                        }).checked(false)
                        Text("fill").fontSize(18)
                    }.margin({ left: 10 })
                }.margin({ top: 50 })
            }.scrollable(ScrollDirection.Horizontal)

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