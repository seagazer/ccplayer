import { MusicSample } from './MusicSample'
import { VideoViewSample } from './VideoViewSample'
import router from '@ohos.router'
import { VideoSample } from './VideoSample'

@Entry
@Component
struct Home {
    private style = new HomeButtonStyle()
    private navRouter = new NavPathStack()

    aboutToAppear(): void {
        router.clear()
    }

    build() {
        Navigation(this.navRouter) {
            Column() {
                Text('MusicSample')
                    .attributeModifier(this.style)
                    .onClick(() => {
                        this.navRouter.pushPathByName("MusicSample", null)
                    })

                Text('VideoSample')
                    .attributeModifier(this.style)
                    .onClick(() => {
                        this.navRouter.pushPathByName("VideoSample", null)
                    })

                Text('VideoViewSample')
                    .attributeModifier(this.style)
                    .onClick(() => {
                        this.navRouter.pushPathByName("VideoViewSample", null)
                    })
            }
            .width("100%")
            .height("100%")
            .padding(16)
            .justifyContent(FlexAlign.Center)
        }
        .width("100%")
        .height("100%")
        .mode(NavigationMode.Stack)
        .navDestination(this.RouterMap)
    }

    @Builder
    RouterMap(name: string) {
        if (name === "MusicSample") {
            MusicSample()
        } else if (name === "VideoSample") {
            VideoSample()
        } else if (name === "VideoViewSample") {
            VideoViewSample()
        }
    }
}

class HomeButtonStyle implements AttributeModifier<TextAttribute> {
    applyNormalAttribute(instance: TextAttribute): void {
        instance
            .textAlign(TextAlign.Center)
            .fontSize(24)
            .width("100%")
            .height(64)
            .fontColor(Color.White)
            .backgroundColor(Color.Blue)
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .borderRadius(4)
            .margin({ top: 16 })
    }
}