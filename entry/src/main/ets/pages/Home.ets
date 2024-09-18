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

    build() {
        Scroll() {
            Column() {
                // video view
                Stack() {
                    CcPlayerView({
                        player: this.player,
                        asRatio: this.ratio
                    })
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
                        max: this.totalDuration
                    }).layoutWeight(1)
                        .onChange((value, mode) => {
                            if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                                this.isSeeking = true
                                this.player.seekTo(value)
                            }
                        })
                    Text(timeToString(this.totalDuration))
                }.width("100%")

                Row() {
                    Button('setSource')
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