import {
    AspectRatio,
    CcPlayer,
    CcPlayerView,
    MediaSourceFactory,
    PlayerState,
    PlayerType
} from '@seagazer/ccplayer';

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

    aboutToAppear() {
        if (this.player == null || this.player.getPlayerState() == PlayerState.STATE_NOT_INIT) {
            this.player = CcPlayer.create(PlayerType.VIDEO)
        }
    }

    aboutToDisappear() {
        this.player!.release()
    }

    build() {
        Column() {
            Stack() {
                CcPlayerView({
                    player: this.player,
                    viewSize: { width: "100%", height: "100%" },
                    asRatio: $videoRatio
                })
            }
            .width(360)
            .height(240)

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

                    Row() {
                        Radio({ value: "stretch", group: "ratio" }).width(32).height(32).onChange(() => {
                            this.videoRatio = AspectRatio.STRETCH
                        }).checked(false)
                        Text("stretch").fontSize(18)
                    }.margin({ left: 10, right: 10 })
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