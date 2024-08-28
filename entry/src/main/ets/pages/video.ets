import { timeToString } from '../Extentions';
import { CcPlayer, MediaSourceFactory, PlayerState } from '@seagazer/ccplayer';
import { Logger } from '../Logger';

@Extend(Button)
function btnStyle() {
    .fontSize(18)
    .width(100)
    .height(50)
    .fontColor(Color.White)
    .margin({ left: 30 })
}

const TAG = "[VideoPage]"

@Entry
@Component
struct VideoPage {
    @State pos: number = 0
    @State duration: number = 0
    private isSeeking = false
    private controller = new XComponentController()
    private surfaceId: string | null = null
    private player: CcPlayer | null = null
    private filePath: string = ""
    private prepareListener = () => {
        Logger.d(TAG, "prepared")
        this.duration = this.player!.getDuration()
    }
    private completedListener = () => {
        Logger.d(TAG, "play completed")
    }
    private errorListener = (code: number, message: string) => {
        Logger.d(TAG, "err =  " + code + ", " + message)
        this.currentState = 'error'
    }
    private progressChangedListener = (duration: number) => {
        if (!this.isSeeking) {
            this.pos = duration
        }
    }
    private seekChangedListener = (duration: number) => {
        this.isSeeking = false
        Logger.d(TAG, "seek completed: " + duration)
    }
    @State currentState: string = ""
    private stateChangedListener = (newState: PlayerState) => {
        Logger.d(TAG, "new state: " + newState)
        this.currentState = newState + ""
    }

    aboutToAppear() {
        this.player = CcPlayer.create()
        this.player!.addOnPreparedListener(this.prepareListener)
            .addOnProgressChangedListener(this.progressChangedListener)
            .addOnCompletionListener(this.completedListener)
            .addOnErrorListener(this.errorListener)
            .addOnSeekChangedListener(this.seekChangedListener)
            .addOnStateChangedListener(this.stateChangedListener)
    }

    aboutToDisappear() {
        this.player!.removeOnPreparedListener(this.prepareListener)
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
                type: XComponentType.SURFACE,
                id: "video",
                controller: this.controller
            }).onLoad(() => {
                this.surfaceId = this.controller.getXComponentSurfaceId()
                Logger.d(TAG, "surface view created: " + this.surfaceId)
                // bind a surface to render picture
                this.player!.setSurface(this.surfaceId)
            }).onDestroy(() => {
                Logger.d(TAG, "surface view destroy")

            })
                .width(480)
                .height(300)

            TextInput({ placeholder: "test.mp4" })
                .fontSize(30)
                .width("70%")
                .height(60)
                .fontColor(Color.Black)
                .onChange((value) => {
                    this.filePath = value
                    // this.filePath = 'http://tv-vod.nbs.cn/vod_storage/vol1/2024/06/06/66615d8489137/66615d848913767849.mp4'
                    Logger.d(TAG, "input = " + this.filePath)
                })
                .margin({ top: 50 })

            Row() {
                Button("setSrc")
                    .btnStyle()
                    .onClick(() => {
                        // if bind surface, set data source to play
                        if (this.surfaceId != null) {
                            Logger.d(TAG, "filePath = " + this.filePath)
                            if (this.filePath.length > 0) {
                                if (this.filePath.startsWith("http")) {
                                    this.player!.setMediaSource(MediaSourceFactory.createUrl(this.filePath), () => {
                                        this.player!.start()
                                    })
                                } else {
                                    MediaSourceFactory.createFile(this.filePath).then((data) => {
                                        this.player!.setMediaSource(data, () => {
                                            this.player!.start()
                                        })
                                    })
                                }
                            } else {
                                MediaSourceFactory.createFile(getContext(this).filesDir + "/test.mp4")
                                    .then((data) => {
                                        this.player!.setMediaSource(data, () => {
                                            this.player!.start()
                                        })
                                    })
                            }
                        }
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
            .justifyContent(FlexAlign.Center)
            .width("100%")
            .margin({ top: 50 })

            Row() {
                Text(timeToString(this.pos))
                    .fontSize(30)
                    .padding(10)
                    .fontColor(Color.Blue)
                Slider({
                    max: this.duration,
                    min: 0,
                    step: 1,
                    style: SliderStyle.InSet,
                    value: this.pos
                })
                    .selectedColor(Color.Blue)
                    .trackColor(Color.Orange)
                    .borderColor(Color.Pink)
                    .trackThickness(30)
                    .layoutWeight(1)
                    .margin({ left: 10, right: 10 })
                    .onChange((value: number, mode: SliderChangeMode) => {
                        Logger.w(TAG, "slide mode = " + mode)
                        if (mode == SliderChangeMode.End || mode == 3) {
                            this.isSeeking = true
                            this.player!.seekTo(Math.floor(value))
                            this.pos = Math.floor(value)
                        }
                    })
                Text(timeToString(this.duration))
                    .fontSize(30)
                    .padding(10)
                    .fontColor(Color.Blue)
            }.justifyContent(FlexAlign.Center)
            .width("100%")
            .margin({ top: 20 })

            Text(this.currentState).fontSize(30).margin({ top: 16 })
        }
        .justifyContent(FlexAlign.Center)
        .width("100%")
        .height("100%")
    }
}