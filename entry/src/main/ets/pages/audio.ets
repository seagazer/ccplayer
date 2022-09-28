import { timeToString } from '../Extentions';
import { MediaSourceFactory } from '@seagazer/ccplayer';
import { Logger } from '@seagazer/ccplayer';
import { CcPlayer } from '@seagazer/ccplayer';
import { PlayerType } from '@seagazer/ccplayer';
import { PlayerState } from '@seagazer/ccplayer';

const TAG = "AudioPage"

@Entry
@Component
struct AudioPage {
    @State position: number= 0
    @State duration: number= 0
    private player: CcPlayer = null
    private isSeeking = false
    private filePath: string  = ""
    private prepareListener = () => {
        Logger.d(TAG, "prepared")
        this.duration = this.player.getDuration()
    }
    private completedListener = () => {
        Logger.d(TAG, "play completed")
    }
    private errorListener = (code, message) => {
        Logger.d(TAG, "err =  " + code + ", " + message)
    }
    private progressChangedListener = (duration) => {
        Logger.d(TAG, "position = " + duration)
        if (!this.isSeeking) {
            this.position = duration
        }
    }
    private seekChangedListener = (duration) => {
        this.isSeeking = false
        Logger.d(TAG, "seek completed: " + duration)
    }
    private stateChangedListener = (newState) => {
        Logger.d(TAG, "new state: " + newState)
    }

    aboutToAppear() {
        if (this.player == null || this.player.getPlayerState() == PlayerState.STATE_NOT_INIT) {
            this.player = CcPlayer.create(PlayerType.AUDIO)
        }
        this.player
            .addOnPreparedListener(this.prepareListener)
            .addOnProgressChangedListener(this.progressChangedListener)
            .addOnCompletionListener(this.completedListener)
            .addOnErrorListener(this.errorListener)
            .addOnSeekChangedListener(this.seekChangedListener)
            .addOnStateChangedListener(this.stateChangedListener)
    }

    aboutToDisappear() {
        this.player
            .removeOnPreparedListener(this.prepareListener)
            .removeOnProgressChangedListener(this.progressChangedListener)
            .removeOnCompletionListener(this.completedListener)
            .removeOnErrorListener(this.errorListener)
            .removeOnSeekChangedListener(this.seekChangedListener)
            .removeOnStateChangedListener(this.stateChangedListener)
            .release()
    }

    build() {
        Column() {
            TextInput({ placeholder: "../../resources/rawfile/test.mp3" })
                .fontSize(30)
                .width("70%")
                .height(60)
                .fontColor(Color.Black)
                .onChange((value) => {
                    this.filePath = value
                    Logger.d(TAG, "input = " + this.filePath)
                })

            Row() {
                Button("setDataSource")
                    .fontSize(30)
                    .width(300)
                    .height(60)
                    .fontColor(Color.White)
                    .onClick(() => {
                        Logger.d(TAG, "filePath = " + this.filePath)
                        if (this.filePath.length > 0) {
                            MediaSourceFactory.createFile("", this.filePath).then((data) => {
                                this.player.setDataSource(data)
                            })
                        } else {
                            MediaSourceFactory.createAssets(getContext(this), "test.mp3", "../../resources/rawfile/test.mp3")
                                .then((data) => {
                                    this.player.setDataSource(data)
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
                Text(timeToString(this.position))
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
                Text(timeToString(this.duration))
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