import { timeToString } from '../Extentions';
import { MediaSourceFactory } from '@seagazer/ccplayer';
import { Logger } from '@seagazer/ccplayer';
import { MediaPlayer } from '@seagazer/ccplayer';
import { PlayerType } from '@seagazer/ccplayer';
import { PlayerState } from '@seagazer/ccplayer';

const TAG = "VideoPage"

@Entry
@Component
struct VideoPage {
    @State position: number= 0
    @State duration: number= 0
    private isSeeking = false
    private controller = new XComponentController()
    private surfaceId: string = null
    private player: MediaPlayer = null
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
            this.player = MediaPlayer.create(PlayerType.VIDEO)
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
            // render surface
            XComponent({
                type: "surface",
                id: "video",
                controller: this.controller
            }).onLoad(() => {
                this.surfaceId = this.controller.getXComponentSurfaceId()
                Logger.d(TAG, "surface view created: " + this.surfaceId)
                // bind a surface to render picture
                this.player.setSurface(this.surfaceId)
            }).onDestroy(() => {
                Logger.d(TAG, "surface view destroy")

            })
                .width(720)
                .height(480)

            TextInput({ placeholder: "../../resources/rawfile/test.mp4" })
                .fontSize(30)
                .width("70%")
                .height(60)
                .fontColor(Color.Black)
                .onChange((value) => {
                    this.filePath = value
                    Logger.d(TAG, "input = " + this.filePath)
                })
                .margin({ top: 50 })

            Row() {
                Button("setDataSource")
                    .fontSize(30)
                    .width(300)
                    .height(60)
                    .fontColor(Color.White)
                    .onClick(() => {
                        // if bind surface, set data source to play
                        if (this.surfaceId != null) {
                            Logger.d(TAG, "filePath = " + this.filePath)
                            if (this.filePath.length > 0) {
                                MediaSourceFactory.createFile("", this.filePath).then((data) => {
                                    this.player.setDataSource(data)
                                })
                            } else {
                                MediaSourceFactory.createAssets(getContext(this), "test.mp4", "../../resources/rawfile/test.mp4")
                                    .then((data) => {
                                        this.player.setDataSource(data)
                                    })
                            }
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
            .margin({ top: 50 })

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
            }.justifyContent(FlexAlign.Center)
            .width("100%")
            .margin({ top: 20 })
        }
        .justifyContent(FlexAlign.Center)
        .width("100%")
        .height("100%")
    }
}