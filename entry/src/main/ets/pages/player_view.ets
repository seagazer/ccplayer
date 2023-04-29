import {
    AspectRatio,
    CcPlayer,
    CcPlayerView,
    Logger,
    MediaSourceFactory,
    PlayerState,
    PlayerType
} from '@seagazer/ccplayer';

@Extend(Button) function btnStyle() {
    .fontSize(30)
    .width(200)
    .height(60)
    .fontColor(Color.White)
    .margin({ left: 30 })
}

@Entry
@Component
struct PlayerViewPage {
    @State videoRatio: number = AspectRatio.AUTO
    @State showTitleBar: boolean = false
    private player: CcPlayer = null

    aboutToAppear() {
        if (this.player == null || this.player.getPlayerState() == PlayerState.STATE_NOT_INIT) {
            this.player = CcPlayer.create(PlayerType.VIDEO)
        }
    }

    aboutToDisappear() {
        this.player.release()
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
                Button("setSrc")
                    .btnStyle()
                    .onClick(() => {
                        // if bind surface, set data source to play
                        MediaSourceFactory.createAssets(getContext(this), "../../resources/rawfile/test.mp4", "test.mp4").then((data) => {
                            this.player.setMediaSource(data, () => {
                                this.player.start()
                            })
                        })
                    })
                Button("start")
                    .btnStyle()
                    .onClick(() => {
                        this.player.start()
                    })
                Button("pause")
                    .btnStyle()
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