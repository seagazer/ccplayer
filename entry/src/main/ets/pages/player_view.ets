import { LitePlayerView } from '@seagazer/ccplayer';
import { MediaSource } from '@seagazer/ccplayer';
import { Logger } from '@seagazer/ccplayer';
import { MediaPlayer } from '@seagazer/ccplayer';
import { PlayerType } from '@seagazer/ccplayer';

const TAG = "PlayerViewPage"

@Entry
@Component
struct PlayerViewPage {
    private player: MediaPlayer = MediaPlayer.create(PlayerType.VIDEO)

    aboutToAppear() {
        this.player.addOnPreparedListener(() => {
            Logger.d(TAG, "prepared")
        })
            .addOnCompletionListener(() => {
                Logger.d(TAG, "play completed")
            })
            .addOnErrorListener((code, message) => {
                Logger.d(TAG, "err =  " + code + ", " + message)
            })
            .addOnStateChangedListener((newState) => {
                Logger.d(TAG, "new state: " + newState)
            })
    }

    aboutToDisappear() {
        this.player.release()
    }

    build() {
        Stack() {
            // render surface
            LitePlayerView({ player: this.player })

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
            .margin({ bottom: 50 })
        }
        .alignContent(Alignment.Bottom)
        .width("100%")
        .height("100%")
    }
}