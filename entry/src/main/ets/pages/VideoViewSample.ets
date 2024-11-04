import { AspectRatio, CcPlayer, CcPlayerView, GestureType, MediaSourceFactory, PlayerState } from '@seagazer/ccplayer';
import { timeToString, toast } from '../Extentions';
import { Logger } from '../Logger';
import common from '@ohos.app.ability.common';
import wantAgent from '@ohos.app.ability.wantAgent';
import { CButton } from './CButton';

const TAG = '[VideoViewSample]'

@Component
export struct VideoViewSample {
    private player = new CcPlayer(getContext(this))
    @State ratio: AspectRatio = AspectRatio.AUTO
    @State ratioText: string = "AUTO"
    @State isLoading: boolean = false
    @State currentPosition: number = 0
    @State totalDuration: number = 0
    @State gestureOverlayVisible: boolean = false
    @State gestureType: GestureType = GestureType.PROGRESS
    @State seekPosition: number = 0
    @State seekMax: number = 0
    @State volumePercent: number = 0
    @State brightnessPercent: number = 0
    private playIndex: number = 0
    private isSeeking = false
    private preparedListener = () => {
        this.totalDuration = this.player.getDuration()
        Logger.d(TAG, "prepared= " + this.totalDuration)
    }
    private stateChangedListener = (state: PlayerState) => {
        Logger.d(TAG, "new state= " + state)
    }
    private errorListener = (code: number, message: string) => {
        Logger.e(TAG, "play error= " + code + ", " + message)
        toast("Play error= " + message)
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
        const context = getContext(this) as common.UIAbilityContext
        this.player.bindAvSession(getContext(this), 'VideoViewSample', 'video', {
            wants: [{
                bundleName: context.abilityInfo.bundleName,
                abilityName: context.abilityInfo.name
            }],
            requestCode: 0x112,
            actionType: wantAgent.OperationType.START_ABILITIES,
            wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
        }).then(() => {
            this.player.setBackgroundPlayEnable(true)
        })
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

    private handleGesture = (type: GestureType, percent: number, isTouchUp: boolean) => {
        this.gestureType = type
        switch (type) {
            case GestureType.PROGRESS:
                this.seekPosition = this.totalDuration * percent
                this.seekMax = this.totalDuration
                if (isTouchUp) {
                    this.player.seekTo(this.seekPosition)
                }
                break
            case GestureType.BRIGHTNESS:
                this.brightnessPercent = percent
                if (isTouchUp) {
                    // todo 设置屏幕亮度，目前三方应用未开放接口，仅OpenHarmony的系统应用可用
                }
                break
            case GestureType.VOLUME:
                this.volumePercent = percent
                if (isTouchUp) {
                    // todo 设置媒体音量，目前三方应用未开放接口，仅OpenHarmony的系统应用可用
                }
                break
        }
    }

    @Builder
    GestureOverlay() {
        if (this.gestureOverlayVisible && !this.isLoading) {
            if (this.gestureType == GestureType.PROGRESS) {
                Row() {
                    Text(timeToString(this.seekPosition) + " / " + timeToString(this.seekMax))
                        .fontSize(14)
                        .fontColor("#ffffffff")
                        .backgroundColor("#b3000000")
                        .borderRadius(4)
                        .padding(8)
                }.width(100)
                .height(50)
                .justifyContent(FlexAlign.Center)
                .animation({ duration: 150 })
            } else if (this.gestureType == GestureType.VOLUME) {
                Row() {
                    Text("音量：" + Math.round(this.volumePercent * 100) + "%")
                        .fontSize(14)
                        .fontSize(14)
                        .fontColor("#ffffffff")
                        .backgroundColor("#b3000000")
                        .borderRadius(4)
                        .padding(8)
                }.width(100)
                .height(50)
                .justifyContent(FlexAlign.Center)
                .animation({ duration: 150 })
            } else {
                Row() {
                    Text("亮度：" + Math.round(this.brightnessPercent * 100) + "%")
                        .fontSize(14)
                        .fontSize(14)
                        .fontColor("#ffffffff")
                        .backgroundColor("#b3000000")
                        .borderRadius(4)
                        .padding(8)
                }.width(100)
                .height(50)
                .justifyContent(FlexAlign.Center)
                .animation({ duration: 150 })
            }
        }
    }

    @Builder
    LoadingOverlay() {
        if (this.isLoading) {
            LoadingProgress()
                .color(Color.White)
                .width(60).height(60)
        }
    }

    build() {
        NavDestination() {
            Column() {
                // video view
                Stack() {
                    CcPlayerView({
                        player: this.player,
                        asRatio: this.ratio,
                        renderType: XComponentType.SURFACE,
                        onGestureAction: this.handleGesture,
                        onGestureUIListener: (visible) => {
                            this.gestureOverlayVisible = visible
                        },
                        onSurfaceCreated: () => {
                            this.isLoading = true
                            this.playIndex = 0
                            let src = MediaSourceFactory.createAssets("TestVideo1", "video1.mp4",
                                "https://so1.360tres.com/dr/220__/t011e1ce4509d68021b.jpg")
                            this.player.setMediaSource(src, () => {
                                this.player.start()
                            })
                        }
                    })
                    this.GestureOverlay()
                    this.LoadingOverlay()
                }
                .width(300)
                .height(500)

                Row() {
                    Text(timeToString(this.currentPosition))
                    Slider({
                        value: this.currentPosition,
                        max: this.totalDuration,
                        min: 0,
                        step: 1000,
                    }).layoutWeight(1)
                        .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
                        .onChange((value, mode) => {
                            if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                                this.isSeeking = true
                                let position = Math.ceil(value)
                                this.player.seekTo(position)
                                this.currentPosition = position
                            }
                        })
                    Text(timeToString(this.totalDuration))
                }.width("100%")

                Row() {
                    CButton({
                        text: "start",
                        onAction: () => {
                            this.player.start()
                        }
                    })
                    CButton({
                        text: "pause",
                        onAction: () => {
                            this.player.pause()
                        }
                    })
                    CButton({
                        text: "StartPip",
                        onAction: async () => {
                            await this.player.enablePip()
                            this.player.startPip()
                        }
                    })
                    CButton({
                        text: "StopPip",
                        onAction: () => {
                            this.player.stopPip()
                        }
                    })
                    CButton({
                        text: "next",
                        onAction: () => {
                            this.isLoading = true
                            if (this.playIndex == 0) {
                                this.playIndex = 1
                                let src = MediaSourceFactory.createAssets("TestVideo2", "video2.mp4",
                                    "https://img1.baidu.com/it/u=4039557469,3031542597&fm=253&fmt=auto&app=138&f=JPEG?w=200&h=200")
                                this.player.setMediaSource(src, () => {
                                    this.player.start()
                                })
                            } else {
                                this.playIndex = 0
                                let src = MediaSourceFactory.createAssets("TestVideo1", "video1.mp4",
                                    "https://so1.360tres.com/dr/220__/t011e1ce4509d68021b.jpg")
                                this.player.setMediaSource(src, () => {
                                    this.player.start()
                                })
                            }
                        }
                    })
                }
                .width("100%")
                .margin({ top: 16 })
                .justifyContent(FlexAlign.SpaceEvenly)

                Text("Video AspectRatio: " + this.ratioText)
                    .width("100%")
                    .textAlign(TextAlign.Start)
                    .margin({ top: 16, bottom: 8 })
                Row() {
                    CButton({
                        text: "AUTO",
                        onAction: () => {
                            this.ratio = AspectRatio.AUTO
                            this.ratioText = "AUTO"
                        }
                    })
                    CButton({
                        text: "21:9",
                        onAction: () => {
                            this.ratio = AspectRatio.W_21_9
                            this.ratioText = "21:9"
                        }
                    })
                    CButton({
                        text: "16:9",
                        onAction: () => {
                            this.ratio = AspectRatio.W_16_9
                            this.ratioText = "16:9"
                        }
                    })
                    CButton({
                        text: "4:3",
                        onAction: () => {
                            this.ratio = AspectRatio.W_4_3
                            this.ratioText = "4:3"
                        }
                    })
                    CButton({
                        text: "FILL",
                        onAction: () => {
                            this.ratio = AspectRatio.FILL
                            this.ratioText = "FILL"
                        }
                    })
                    CButton({
                        text: "STRETCH",
                        onAction: () => {
                            this.ratio = AspectRatio.STRETCH
                            this.ratioText = "STRETCH"
                        }
                    })
                }
                .width("100%")
                .justifyContent(FlexAlign.SpaceEvenly)
            }
            .width("100%")
            .height("100%")
            .padding(16)
            .justifyContent(FlexAlign.Center)
        }
        .width("100%")
        .height("100%")
        .title("VideoViewSample")
    }
}