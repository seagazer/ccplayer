import { CcPlayer, MediaSourceFactory, PlayerState } from '@seagazer/ccplayer';
import { timeToString } from '../Extentions';
import { Logger } from '../Logger';
import common from '@ohos.app.ability.common';
import wantAgent from '@ohos.app.ability.wantAgent';
import { CButton } from './CButton';
import { media } from '@kit.MediaKit';

const TAG = '[VideoSample]'

@Component
export struct VideoSample {
    private player = new CcPlayer(getContext(this))
    @State isLoading: boolean = false
    @State currentPosition: number = 0
    @State totalDuration: number = 0
    private controller: XComponentController = new XComponentController()
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
        this.player.bindAvSession(getContext(this), 'VideoSample', 'video', {
            wants: [{
                bundleName: context.abilityInfo.bundleName,
                abilityName: context.abilityInfo.name
            }],
            requestCode: 0x111,
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
                    XComponent({
                        id: "video",
                        type: XComponentType.SURFACE,
                        controller: this.controller
                    }).onLoad(() => {
                        this.player.setSurface(this.controller.getXComponentSurfaceId())
                        // set controller to support pip and enable pip.
                        this.player.setXComponentController(this.controller)
                        this.player.enablePip()
                    })
                    this.LoadingOverlay()
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
                        text: "setSrc",
                        onAction: () => {
                            this.isLoading = true
                            let src = MediaSourceFactory.createAssets("TestVideo", "video1.mp4",
                                "https://so1.360tres.com/dr/220__/t011e1ce4509d68021b.jpg")
                            this.player.setMediaSource(src, () => {
                                this.player.start()
                            })
                        }
                    })
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
                }
                .width("100%")
                .margin({ top: 32 })
                .justifyContent(FlexAlign.SpaceEvenly)

                Row() {
                    CButton({
                        text: "speed-2x",
                        onAction: () => {
                            this.player.setPlaySpeed(media.PlaybackSpeed.SPEED_FORWARD_2_00_X)
                        }
                    })
                    CButton({
                        text: "StartPip",
                        onAction: () => {
                            this.player.startPip()
                        }
                    })
                    CButton({
                        text: "StopPip",
                        onAction: () => {
                            this.player.stopPip()
                        }
                    })
                }
                .width("100%")
                .margin({ top: 32 })
                .justifyContent(FlexAlign.SpaceEvenly)
            }
            .width("100%")
            .height("100%")
            .padding(16)
            .justifyContent(FlexAlign.Center)
        }
        .width("100%")
        .height("100%")
        .title("VideoSample")
    }
}