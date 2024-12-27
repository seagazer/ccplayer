import {
    AspectRatio,
    CcGestureOverlay,
    CcLoadingOverlay,
    CcPlayer,
    CcPlayerView,
    GestureType,
    MediaSourceFactory,
    PlayerState
} from '@seagazer/ccplayer';
import { timeToString, toast } from '../Extentions';
import { Logger } from '../Logger';
import common from '@ohos.app.ability.common';
import wantAgent from '@ohos.app.ability.wantAgent';
import { CButton } from './CButton';

const TAG = '[CcPlayerViewSample]'

@Component
export struct CcPlayerViewSample {
    private player = new CcPlayer(getContext(this))
    @State ratio: AspectRatio = AspectRatio.AUTO
    @State ratioText: string = "AUTO"
    @State currentPosition: number = 0
    @State totalDuration: number = 0
    @State seekPosition: number = 0
    @State seekMax: number = 0
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
    private gestureOverlay: CcGestureOverlay = new CcGestureOverlay(this.player)

    aboutToAppear(): void {
        // set the gesture overlay ui config
        this.gestureOverlay.setTextSize(18)
        this.gestureOverlay.setTextColor('#ffead981')
        // bind av session
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
            // set background play
            this.player.setBackgroundPlayEnable(true)
        })
        // set the listeners of player
        this.player
            .addOnPreparedListener(this.preparedListener)
            .addOnStateChangedListener(this.stateChangedListener)
            .addOnErrorListener(this.errorListener)
            .addOnProgressChangedListener(this.progressChangedListener)
            .addOnSeekChangedListener(this.seekListener)
    }

    aboutToDisappear(): void {
        this.player
            .removeOnPreparedListener(this.preparedListener)
            .removeOnStateChangedListener(this.stateChangedListener)
            .removeOnErrorListener(this.errorListener)
            .removeOnProgressChangedListener(this.progressChangedListener)
            .removeOnSeekChangedListener(this.seekListener)
        this.player.release()
    }

    private handleGestureAction(type: GestureType, percent: number, isTouchUp: boolean) {
        switch (type) {
            case GestureType.PROGRESS:
                this.seekPosition = this.totalDuration * percent
                if (isTouchUp) {
                    this.player.seekTo(this.seekPosition)
                }
                break
            case GestureType.BRIGHTNESS:
                if (isTouchUp) {
                    // todo 设置屏幕亮度，目前三方应用未开放接口，仅OpenHarmony的系统应用可用
                }
                break
            case GestureType.VOLUME:
                if (isTouchUp) {
                    // todo 设置媒体音量，目前三方应用未开放接口，仅OpenHarmony的系统应用可用
                }
                break
        }
    }

    build() {
        NavDestination() {
            Column() {
                Stack() {
                    // video view
                    CcPlayerView({
                        player: this.player,
                        asRatio: this.ratio,
                        renderType: XComponentType.SURFACE,
                        onGestureAction: (type: GestureType, percent: number, isTouchUp: boolean) => {
                            this.gestureOverlay.setGestureType(type)
                            this.gestureOverlay.setGesturePercent(percent)
                            // handle the gesture actions
                            this.handleGestureAction(type, percent, isTouchUp)
                        },
                        onGestureUIListener: (visible) => {
                            this.gestureOverlay.setGestureOverlayVisible(visible)
                        },
                        onSurfaceCreated: () => {
                            this.playIndex = 0
                            let src = MediaSourceFactory.createAssets("TestVideo1", "video1.mp4",
                                "https://so1.360tres.com/dr/220__/t011e1ce4509d68021b.jpg")
                            this.player.setMediaSource(src, () => {
                                this.player.start()
                            })
                        }
                    })
                    // default gesture overlay
                    NodeContainer(this.gestureOverlay)
                    // default loading overlay
                    CcLoadingOverlay({
                        player: this.player,
                        loadingColor: '#ffd4a74f'
                    })
                }
                .width("100%")
                .height(500)

                Row() {
                    Text(timeToString(this.currentPosition))
                    Slider({
                        value: this.currentPosition,
                        max: this.totalDuration,
                        min: 0,
                        step: 1000,
                    }).layoutWeight(1)
                        .onChange((value, mode) => {
                            if (mode == SliderChangeMode.Begin) {
                                this.isSeeking = true
                            } else if (mode == SliderChangeMode.End) {
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
        .title("CcPlayerViewSample")
    }
}