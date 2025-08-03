import { CcPlayer, MediaSourceFactory, PlayerState } from '@seagazer/ccplayer'
import { IjkPlugin } from '@seagazer/ccplayer-ijk'
import { timeToString } from '../Extentions'
import { Logger } from '../Logger'
import { CButton } from './CButton'


const TAG = "[IjkSample]"

@ComponentV2
export struct IjkSample {
    private i = 0
    @Local currentPosition: number = 0
    @Local totalDuration: number = 0
    private controller = new XComponentController()
    private player = new CcPlayer(getContext(this))
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
        // Logger.d(TAG, "progress= " + position)
        if (this.isSeeking) {
            return
        }
        this.currentPosition = position
    }
    private seekListener = (position: number) => {
        Logger.d(TAG, "seek= " + position)
        this.currentPosition = position
        this.isSeeking = false
    }
    private videoSizeListener = (width: number, height: number) => {
        Logger.d(TAG, "video size= " + width + "x" + height)
    }
    private completedListener = () => {
        this.player.start()
    }
    private isSeeking = false

    aboutToAppear(): void {
        const ijkPlugin = new IjkPlugin()
        this.player.setPlayer(ijkPlugin)
        this.player
            .addOnPreparedListener(this.preparedListener)
            .addOnStateChangedListener(this.stateChangedListener)
            .addOnRenderFirstFrameListener(this.firstFrameListener)
            .addOnErrorListener(this.errorListener)
            .addOnProgressChangedListener(this.progressChangedListener)
            .addOnSeekChangedListener(this.seekListener)
            .addOnVideoSizeChangedListener(this.videoSizeListener)
            .addOnCompletionListener(this.completedListener)
    }

    aboutToDisappear(): void {
        this.player
            .removeOnPreparedListener(this.preparedListener)
            .removeOnStateChangedListener(this.stateChangedListener)
            .removeOnRenderFirstFrameListener(this.firstFrameListener)
            .removeOnErrorListener(this.errorListener)
            .removeOnProgressChangedListener(this.progressChangedListener)
            .removeOnSeekChangedListener(this.seekListener)
            .removeOnVideoSizeChangedListener(this.videoSizeListener)
            .removeOnCompletionListener(this.completedListener)
        this.player.release()
    }

    build() {
        NavDestination() {
            Column() {
                XComponent({
                    controller: this.controller,
                    type: XComponentType.SURFACE,
                    id: IjkPlugin.getXComponentId(),
                    libraryname: IjkPlugin.getLibrary(),
                }).onLoad((context) => {
                    Logger.d(TAG, "onLoad= " + context)
                    if (context) {
                        this.player.bindXComponent(this.controller, context)
                    }
                    const source = MediaSourceFactory.createUrl("",
                        "https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/mp4/xgplayer-demo-360p.mp4")
                    this.player.setMediaSource(source)
                    this.player.start()
                }).width(300)
                    .height(200)

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
                .padding(16)

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
                        text: "next",
                        onAction: () => {
                            this.playNext()
                        }
                    })
                }.width("100%")
                .justifyContent(FlexAlign.SpaceAround)

            }
        }.title("IjkSample")
    }

    private playNext() {
        if (this.i % 2 == 0) {
            // https://getsamplefiles.com/download/mp4/sample-5.mp4
            const source = MediaSourceFactory.createUrl("", "http://vjs.zencdn.net/v/oceans.mp4")
            this.player.setMediaSource(source)
            this.player.start()
        } else {
            const source = MediaSourceFactory.createUrl("",
                "https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/mp4/xgplayer-demo-360p.mp4")
            this.player.setMediaSource(source)
            this.player.start()
        }
        this.i++
    }
}