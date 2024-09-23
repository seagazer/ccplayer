import router from '@ohos.router';
import { AspectRatio, CcPlayer, CcPlayerView, MediaSourceFactory, PlayerState } from '@seagazer/ccplayer';
import { timeToString } from '../Extentions';
import { Logger } from '../Logger';

const TAG = '[ccplayer]'

@Entry
@Component
struct Home {
    private player = new CcPlayer()
    @State ratio: AspectRatio = AspectRatio.AUTO
    @State isLoading: boolean = false
    @State currentPosition: number = 0
    @State totalDuration: number = 0
    private isSeeking = false
    private preparedListener = () => {
        Logger.d(TAG, "prepared")
        this.totalDuration = this.player.getDuration()
    }
    private stateChangedListener = (state: PlayerState) => {
        Logger.d(TAG, "new state= " + state)
    }
    private errorListener = (code: number, message: string) => {
        Logger.e(TAG, "play error= " + code + ", " + message)
    }
    private firstFrameListener = () => {
        Logger.d(TAG, "render first frame")
        this.isLoading = false
    }
    private progressChangedListener = (position: number) => {
        if (this.isSeeking) {
            return
        }
        this.currentPosition = position
    }
    private seekListener = (position: number) => {
        this.currentPosition = position
        this.isSeeking = false
    }

    aboutToAppear(): void {
        router.clear()
        this.player
            .addOnPreparedListener(this.preparedListener)
            .addOnStateChangedListener(this.stateChangedListener)
            .addOnRenderFirstFrameListener(this.firstFrameListener)
            .addOnErrorListener(this.errorListener)
            .addOnProgressChangedListener(this.progressChangedListener)
            .addOnSeekChangedListener(this.seekListener)
    }

    aboutToDisappear(): void {
        this.player
            .removeOnPreparedListener(this.preparedListener)
            .removeOnStateChangedListener(this.stateChangedListener)
            .removeOnRenderFirstFrameListener(this.firstFrameListener)
            .removeOnErrorListener(this.errorListener)
            .removeOnProgressChangedListener(this.progressChangedListener)
            .removeOnSeekChangedListener(this.seekListener)
        this.player.release()
    }

    @State gestureOverlayVisible: boolean = false
    @State currentType: "seek" | "volume" | "brightness" = "seek"
    @State seekPosition: number = 0
    @State seekMax: number = 0
    @State volumePercent: number = 0
    @State brightnessPercent: number = 0

    build() {
        Scroll() {
            Column() {
                // video view
                Stack() {
                    CcPlayerView({
                        player: this.player,
                        asRatio: this.ratio,
                        gestureSeekAction: (position, max, isTouchUp) => {
                            this.currentType = "seek"
                            this.seekPosition = position
                            this.seekMax = max
                            if (isTouchUp) {
                                this.player.seekTo(position)
                            }
                        },
                        gestureVolumeAction: (percent, isTouchUp) => {
                            this.currentType = "volume"
                            this.volumePercent = percent
                            if (isTouchUp) {
                                // todo 设置媒体音量，目前三方应用未开放接口，仅OpenHarmony的系统应用可用
                            }
                        },
                        gestureBrightnessAction: (percent, isTouchUp) => {
                            this.currentType = "brightness"
                            this.brightnessPercent = percent
                            if (isTouchUp) {
                                // todo 设置屏幕亮度，目前三方应用未开放接口，仅OpenHarmony的系统应用可用
                            }
                        },
                        gestureUIListener: (visible) => {
                            this.gestureOverlayVisible = visible
                        }
                    })
                    if (this.gestureOverlayVisible && !this.isLoading) {
                        if (this.currentType == "seek") {
                            Row() {
                                Text(timeToString(this.seekPosition) + " / " + timeToString(this.seekMax))
                                    .fontSize(14)
                                    .fontColor("#ffffff")
                                    .backgroundColor("#b3000000")
                                    .borderRadius(4)
                                    .padding(8)
                            }.width(100)
                            .height(50)
                            .justifyContent(FlexAlign.Center)
                        } else if (this.currentType == "volume") {
                            Row() {
                                Text("音量：" + Math.round(this.volumePercent * 100) + "%")
                                    .fontSize(14)
                                    .fontSize(14)
                                    .fontColor("#ffffff")
                                    .backgroundColor("#b3000000")
                                    .borderRadius(4)
                                    .padding(8)
                            }.width(100)
                            .height(50)
                            .justifyContent(FlexAlign.Center)
                        } else {
                            Row() {
                                Text("亮度：" + Math.round(this.brightnessPercent * 100) + "%")
                                    .fontSize(14)
                                    .fontSize(14)
                                    .fontColor("#ffffff")
                                    .backgroundColor("#b3000000")
                                    .borderRadius(4)
                                    .padding(8)
                            }.width(100)
                            .height(50)
                            .justifyContent(FlexAlign.Center)
                        }
                    }
                    if (this.isLoading) {
                        LoadingProgress()
                            .color(Color.White)
                            .width(60).height(60)
                    }
                }.width(300)
                .height(200)

                Row() {
                    Text(timeToString(this.currentPosition))
                    Slider({
                        value: this.currentPosition,
                        max: this.totalDuration,
                        min: 0,
                        step: 1000,
                    }).layoutWeight(1)
                        .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK)// .padding({ left: 8, right: 8 })
                        .onChange((value, mode) => {
                            if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                                Logger.w(TAG, "--------" + mode + ", " + value)
                                this.isSeeking = true
                                let position = Math.ceil(value)
                                this.player.seekTo(position)
                                this.currentPosition = position
                            }
                        })
                    Text(timeToString(this.totalDuration))
                }.width("100%")

                Row() {
                    Button('setSrc')
                        .onClick(() => {
                            this.isLoading = true
                            this.player.reset()
                            MediaSourceFactory.createAssets(getContext(this), "test.mp4")
                                .then((src) => {
                                    src && this.player.setMediaSource(src, () => {
                                        this.player.start()
                                    })
                                })
                        })
                    Button('start')
                        .onClick(() => {
                            this.player.start()
                        })
                    Button('pause')
                        .onClick(() => {
                            this.player.pause()
                        })
                }
                .width("100%")
                .margin({ top: 16 })
                .justifyContent(FlexAlign.SpaceEvenly)
            }
            .width("100%")
        }
        .width("100%")
        .height("100%")
        .padding(16)
    }
}