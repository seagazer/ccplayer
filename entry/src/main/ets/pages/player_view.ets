import { LitePlayerView } from '@seagazer/ccplayer';
import { MediaSource } from '@seagazer/ccplayer';
import { Logger } from '@seagazer/ccplayer';
import { MediaPlayer } from '@seagazer/ccplayer';
import { PlayerType } from '@seagazer/ccplayer';
import { AspectRatio } from '@seagazer/ccplayer';

const TAG = "PlayerViewPage"

@Entry
@Component
struct PlayerViewPage {
    @State videoRatio: number = AspectRatio.AUTO
    private player: MediaPlayer = MediaPlayer.create(PlayerType.VIDEO)
    private prepareListener = () => {
        Logger.d(TAG, "prepared")
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
    }

    build() {
        Column() {
            // render surface view
            LitePlayerView({
                player: this.player,
                width: 800,
                height: 480,
                aspectRatio: $videoRatio,
                isSupportGesture: true
            })
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
                    })
                    Text("21:9").fontSize(30)
                }.margin({ left: 10 })

                Row() {
                    Radio({ value: "4:3", group: "ratio" }).width(45).height(45).onChange(() => {
                        this.videoRatio = AspectRatio.W_4_3
                    })
                    Text("4:3").fontSize(30)
                }.margin({ left: 10 })

                Row() {
                    Radio({ value: "16:9", group: "ratio" }).width(45).height(45).onChange(() => {
                        this.videoRatio = AspectRatio.W_16_9
                    })
                    Text("16:9").fontSize(30)
                }.margin({ left: 10 })

                Row() {
                    Radio({ value: "fill", group: "ratio" }).width(45).height(45).onChange(() => {
                        this.videoRatio = AspectRatio.FILL
                    })
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
                        MediaSource.createAssets(globalThis.context, "../../resources/rawfile/test.mp4").then((fd) => {
                            this.player.setDataSourceFile(fd)
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