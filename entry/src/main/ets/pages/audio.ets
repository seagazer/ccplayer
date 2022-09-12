import { MediaSource } from '@seagazer/ccplayer';
import { Logger } from '@seagazer/ccplayer';
import { MediaPlayer } from '@seagazer/ccplayer';
import { PlayerType } from '@seagazer/ccplayer';

const TAG = "AudioPage"

@Entry
@Component
struct AudioPage {
    @State position: number= 0
    @State duration: number= 0
    private player: MediaPlayer= MediaPlayer.create(PlayerType.AUDIO)
    private isSeeking = false
    private dataSource: string  = ""

    aboutToAppear() {
        this.player.addOnPreparedListener(() => {
            Logger.d(TAG, "prepared")
            this.duration = this.player.getDuration()
        })
            .addOnProgressChangedListener((duration) => {
                Logger.d(TAG, "position = " + duration)
                if (!this.isSeeking) {
                    this.position = duration
                }
            })
            .addOnCompletionListener(() => {
                Logger.d(TAG, "play completed")
            })
            .addOnErrorListener((code, message) => {
                Logger.d(TAG, "err =  " + code + ", " + message)
            })
            .addOnSeekChangedListener((duration) => {
                this.isSeeking = false
                Logger.d(TAG, "seek completed: " + duration)
            })
            .addOnStateChangedListener((newState) => {
                Logger.d(TAG, "new state: " + newState)
            })
    }

    aboutToDisappear() {
        this.player.release()
    }

    build() {
        Column() {
            TextInput()
                .fontSize(30)
                .width("70%")
                .height(60)
                .fontColor(Color.Black)
                .onChange((value) => {
                    this.dataSource = value
                    Logger.d(TAG, "input = " + this.dataSource)
                })

            Row() {
                Button("setDataSource")
                    .fontSize(30)
                    .width(300)
                    .height(60)
                    .fontColor(Color.White)
                    .onClick(() => {
                        Logger.d(TAG, "dataSource = " + this.dataSource)
                        if (this.dataSource.length > 0) {
                            MediaSource.createFile(this.dataSource).then((fd) => {
                                this.player.setDataSourceFile(fd)
                            })
                        } else {
                            MediaSource.createAssets(globalThis.context, "../../resources/rawfile/test.mp3").then((fd) => {
                                this.player.setDataSourceFile(fd)
                            })
                        }
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
            .justifyContent(FlexAlign.Center)
            .width("100%")
            .margin({ top: 20 })

            Row() {
                Text("" + this.position)
                    .fontSize(30)
                    .padding(10)
                    .margin({ left: 20 })
                    .fontColor(Color.Blue)
                Slider({
                    max: this.duration,
                    min: 0,
                    step: 1,
                    style: SliderStyle.InSet,
                    value: this.position
                })
                    .width("60%")
                    .selectedColor(Color.Blue)
                    .trackColor(Color.Orange)
                    .borderColor(Color.Pink)
                    .trackThickness(30)
                    .constraintSize({ maxWidth: 500 })
                    .margin({ left: 10, right: 10 })
                    .onChange((value: number, mode: SliderChangeMode) => {
                        if (mode == SliderChangeMode.End || mode == 3) {
                            this.isSeeking = true
                            this.player.seekTo(Math.floor(value))
                            this.position = Math.floor(value)
                        }
                    })
                Text("" + this.duration)
                    .fontSize(30)
                    .padding(10)
                    .margin({ left: 20 })
                    .fontColor(Color.Blue)
            }
            .justifyContent(FlexAlign.Center)
            .width("100%")
            .margin({ top: 20 })
        }
        .justifyContent(FlexAlign.Center)
        .width("100%")
        .height("100%")
    }
}