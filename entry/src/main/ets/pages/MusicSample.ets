import { AvSessionCallback, CcPlayer, MediaSource, MediaSourceFactory, PlayerState } from '@seagazer/ccplayer';
import { timeToString } from '../Extentions';
import { Logger } from '../Logger';
import common from '@ohos.app.ability.common';
import wantAgent from '@ohos.app.ability.wantAgent';
import { CButton } from './CButton';

const TAG = '[MusicSample]'

@Component
export struct MusicSample {
    private player = new CcPlayer(getContext(this))
    @State currentPosition: number = 0
    @State totalDuration: number = 0
    @State seekPosition: number = 0
    private readonly cover = "https://so1.360tres.com/dr/220__/t011e1ce4509d68021b.jpg"
    private readonly cover2 = "https://img1.baidu.com/it/u=4039557469,3031542597&fm=253&fmt=auto&app=138&f=JPEG?w=200&h=200"
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
    @State playIndex: number = 0
    private playlist: Array<MediaSource> = []

    aboutToAppear(): void {
        // mock data
        this.playlist.push(MediaSourceFactory.createAssets("Song1", "music1.mp3", this.cover))
        this.playlist.push(MediaSourceFactory.createAssets("Song2", "music2.mp3", this.cover2))
        const context = getContext(this) as common.UIAbilityContext
        this.player.bindAvSession(getContext(this), 'MusicSample', 'audio', {
            wants: [{
                bundleName: context.abilityInfo.bundleName,
                abilityName: context.abilityInfo.name
            }],
            requestCode: 0x110,
            actionType: wantAgent.OperationType.START_ABILITIES,
            wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
        }).then(() => {
            this.player.setBackgroundPlayEnable(true)
        })
        this.player.addAvSessionCallback({
            onNext: () => {
                this.playNext()
            },
            onPrevious: () => {
                this.playPrevious()
            }
        } as AvSessionCallback)
        this.player
            .addOnPreparedListener(this.preparedListener)
            .addOnStateChangedListener(this.stateChangedListener)
            .addOnRenderFirstFrameListener(this.firstFrameListener)
            .addOnErrorListener(this.errorListener)
            .addOnProgressChangedListener(this.progressChangedListener)
            .addOnSeekChangedListener(this.seekListener)
    }

    private playPrevious() {
        this.playIndex--
        if (this.playIndex < 0) {
            this.playIndex = this.playlist.length - 1
        }
        this.player.setMediaSource(this.playlist[this.playIndex], () => {
            this.player.start()
        })
    }

    private playNext() {
        this.playIndex++
        if (this.playIndex > this.playlist.length - 1) {
            this.playIndex = 0
        }
        this.player.setMediaSource(this.playlist[this.playIndex], () => {
            this.player.start()
        })
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
        NavDestination() {
            Column() {
                // video view
                Image(this.playIndex == 0 ? this.cover : this.cover2)
                    .width(200)
                    .height(200)
                    .borderRadius(16)

                Row() {
                    Text(timeToString(this.currentPosition))
                    Slider({
                        value: this.currentPosition,
                        max: this.totalDuration,
                        min: 0,
                        step: 1000,
                    }).layoutWeight(1)
                        .enabled(this.totalDuration > 0)
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
                .margin({ top: 16 })

                Row() {
                    CButton({
                        text: "setSrc",
                        onAction: () => {
                            this.player.setMediaSource(this.playlist[0], () => {
                                this.player.start()
                            })
                        }
                    })
                    CButton({
                        text: "next",
                        onAction: () => {
                            this.playNext()
                        }
                    })
                    CButton({
                        text: "previous",
                        onAction: () => {
                            this.playPrevious()
                        }
                    })
                }
                .width("100%")
                .margin({ top: 32 })
                .justifyContent(FlexAlign.SpaceEvenly)

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
                }
                .width("100%")
                .margin({ top: 16 })
                .justifyContent(FlexAlign.SpaceEvenly)
            }
            .width("100%")
            .height("100%")
            .padding(16)
            .justifyContent(FlexAlign.Center)
        }
        .width("100%")
        .height("100%")
        .title("MusicSample")
    }
}