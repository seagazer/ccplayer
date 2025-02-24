import {
    AspectRatio,
    CcControllerOverlay,
    CcGestureOverlay,
    CcLoadingOverlay,
    CcPlayer,
    CcPlayerViewV2,
    CcTitleBarOverlay,
    GestureType,
    MediaSourceFactory,
    PlayerState
} from '@seagazer/ccplayer';
import { toast } from '../Extentions';
import { Logger } from '../Logger';
import common from '@ohos.app.ability.common';
import wantAgent from '@ohos.app.ability.wantAgent';
import { CButton } from './CButton';
import { window } from '@kit.ArkUI';

const TAG = '[CcPlayerViewSampleV2]'

@ComponentV2
export struct CcPlayerViewSampleV2 {
    private player = new CcPlayer(getContext(this))
    @Local ratio: AspectRatio = AspectRatio.AUTO
    @Local ratioText: string = "AUTO"
    @Local totalDuration: number = 0
    private playIndex: number = 0
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
    private loadingOverlay: CcLoadingOverlay = new CcLoadingOverlay(this.player)
    private gestureOverlay: CcGestureOverlay = new CcGestureOverlay(this.player)
    private controllerOverlay: CcControllerOverlay = new CcControllerOverlay(this.player)
    private titleOverlay: CcTitleBarOverlay = new CcTitleBarOverlay(this.player)
    private playerWindow?: window.Window = undefined
    private controllerHideTimer = -1

    aboutToAppear(): void {
        this.playerWindow = window.findWindow(this.getUIContext().getWindowName())
        // set the gesture overlay ui config
        this.gestureOverlay.setTextSize(18)
        this.gestureOverlay.setTextColor('#ffead981')
        this.loadingOverlay.setLoadingText("loading...")
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
    }

    aboutToDisappear(): void {
        clearTimeout(this.controllerHideTimer)
        this.player
            .removeOnPreparedListener(this.preparedListener)
            .removeOnStateChangedListener(this.stateChangedListener)
            .removeOnErrorListener(this.errorListener)
        this.player.release()
    }

    // 用户自己手动处理手势事件
    private handleGestureAction(type: GestureType, percent: number, isTouchUp: boolean) {
        switch (type) {
            case GestureType.PROGRESS:
                let seekPosition = this.totalDuration * percent
                if (isTouchUp) {
                    this.player.seekTo(seekPosition)
                }
                break
            case GestureType.BRIGHTNESS:
                this.playerWindow?.setWindowBrightness(percent)
                break
            case GestureType.VOLUME:
                this.player.setVolume(percent)
                break
        }
    }

    build() {
        NavDestination() {
            Column() {
                RelativeContainer() {
                    // video view
                    CcPlayerViewV2({
                        player: this.player,
                        asRatio: this.ratio,
                        renderType: XComponentType.SURFACE,
                        onGestureAction: (type: GestureType, percent: number, isTouchUp: boolean) => {
                            // 用户自己手动处理手势事件
                            // this.gestureOverlay.setGestureType(type)
                            // this.gestureOverlay.setGesturePercent(percent)
                            // this.handleGestureAction(type, percent, isTouchUp)
                            // Overlay自动处理手势事件
                            this.gestureOverlay.handleGestureAction(this.getUIContext(), type, percent, isTouchUp)
                        },
                        onGestureUIListener: (visible) => {
                            this.gestureOverlay.setVisible(visible)
                        },
                        onSurfaceCreated: () => {
                            this.playIndex = 0
                            let src = MediaSourceFactory.createAssets("TestVideo1", "video1.mp4",
                                "https://so1.360tres.com/dr/220__/t011e1ce4509d68021b.jpg")
                            this.player.setMediaSource(src, () => {
                                // 模拟1.5s的loading状态，用于展示LoadingOverlay
                                setTimeout(() => {
                                    this.player.start()
                                }, 1500)
                            })
                        }
                    })
                    // default gesture overlay
                    NodeContainer(this.gestureOverlay)
                        .alignRules({
                            center: { anchor: '__container__', align: VerticalAlign.Center },
                            middle: { anchor: '__container__', align: HorizontalAlign.Center },
                        })
                    // default controller overlay
                    NodeContainer(this.controllerOverlay)
                        .alignRules({
                            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
                        })
                    // default title overlay
                    NodeContainer(this.titleOverlay)
                        .alignRules({
                            top: { anchor: '__container__', align: VerticalAlign.Top },
                        })
                    // default loading overlay
                    NodeContainer(this.loadingOverlay)
                        .alignRules({
                            center: { anchor: '__container__', align: VerticalAlign.Center },
                            middle: { anchor: '__container__', align: HorizontalAlign.Center },
                        })
                }
                .width("100%")
                .height(500)
                .onTouch((ev) => {
                    if (ev.type == TouchType.Down) {
                        clearTimeout(this.controllerHideTimer)
                        this.titleOverlay.setVisible(true)
                        this.controllerOverlay.setVisible(true)
                    }
                    if (ev.type == TouchType.Up) {
                        this.controllerHideTimer = setTimeout(() => {
                            this.titleOverlay.setVisible(false)
                            this.controllerOverlay.setVisible(false)
                        }, 2000)
                    }
                })


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
                                    // 模拟1.5s的loading状态，用于展示LoadingOverlay
                                    setTimeout(() => {
                                        this.player.start()
                                    }, 1500)
                                })
                            } else {
                                this.playIndex = 0
                                let src = MediaSourceFactory.createAssets("TestVideo1", "video1.mp4",
                                    "https://so1.360tres.com/dr/220__/t011e1ce4509d68021b.jpg")
                                this.player.setMediaSource(src, () => {
                                    // 模拟1.5s的loading状态，用于展示LoadingOverlay
                                    setTimeout(() => {
                                        this.player.start()
                                    }, 1500)
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
        .title("CcPlayerViewSampleV2")
    }
}