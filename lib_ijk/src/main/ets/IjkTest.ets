import { MediaLogger, MediaSourceFactory } from '@seagazer/ccplayer_base';
import { IjkPlayerImpl } from './IjkPlayerImpl';

const TAG = "[IjkTest]"

@ComponentV2
export struct IjkTest {
    private i = 0
    private ijkPlayer?: IjkPlayerImpl = undefined

    aboutToAppear(): void {
        this.ijkPlayer = new IjkPlayerImpl()
    }

    build() {
        Column() {
            XComponent({
                type: XComponentType.SURFACE,
                id: IjkPlayerImpl.getXComponentId(),
                libraryname: IjkPlayerImpl.getLibrary(),
            }).onLoad((context) => {
                MediaLogger.d(TAG, "onLoad= " + context)
                if (context) {
                    this.ijkPlayer!.setSurface(context)
                }
                const source = MediaSourceFactory.createUrl("",
                    "https://1251542705.vod2.myqcloud.com/4a8d9c67vodtransgzp1251542705/203109c63270835013529449619/v.f1419907.mp4")
                this.ijkPlayer!.setMediaSource(source)
                this.ijkPlayer!.start()
            }).width(200)
                .height(100)

            Button("next")
                .onClick(() => {
                    if (this.i % 2 == 0) {
                        const source = MediaSourceFactory.createUrl("",
                            "https://getsamplefiles.com/download/mp4/sample-5.mp4")
                        this.ijkPlayer!.setMediaSource(source)
                        this.ijkPlayer!.start()
                    } else {
                        const source = MediaSourceFactory.createUrl("",
                            "https://1251542705.vod2.myqcloud.com/4a8d9c67vodtransgzp1251542705/203109c63270835013529449619/v.f1419907.mp4")
                        this.ijkPlayer!.setMediaSource(source)
                        this.ijkPlayer!.start()
                    }

                    this.i++
                })
        }
    }
}