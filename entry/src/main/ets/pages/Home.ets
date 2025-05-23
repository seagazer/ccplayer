import { MusicSample } from './MusicSample'
import { CcPlayerViewSample } from './CcPlayerViewSample'
import router from '@ohos.router'
import { VideoSample } from './VideoSample'
import { PagePlayerSample } from './PagePlayerSample'
import { CustomOverlaySample } from './CustomOverlaySample'
import { CcPlayerViewSampleV2 } from './CcPlayerViewSampleV2'
import { LOGO_COLOR } from '../Extentions'

@Entry
@Component
struct Home {
    private style = new HomeButtonStyle()
    private navRouter = new NavPathStack()
    private pageData: string[] =
        ['MusicSample', 'VideoSample', 'CcPlayerViewSample', 'CcPlayerViewSampleV2', 'CustomOverlaySample', 'PagePlayerSample']

    private navigationId: string = 'navId'

    aboutToAppear(): void {
        router.clear()
    }

    build() {
        Navigation(this.navRouter) {
            Column() {
                ForEach(this.pageData, (pageName: string) => {
                    Text(pageName)
                        .attributeModifier(this.style)
                        .onClick(() => {
                            this.navRouter.pushPathByName(pageName, null)
                        })
                        .backgroundColor(LOGO_COLOR[Math.floor(Math.random() * LOGO_COLOR.length)])
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
        .id(this.navigationId)
    }

    @Builder
    RouterMap(name: string) {
        if (name === "MusicSample") {
            MusicSample()
        } else if (name === "VideoSample") {
            VideoSample()
        } else if (name === "CcPlayerViewSample") {
            CcPlayerViewSample({ navigationId: this.navigationId })
        } else if (name === "CcPlayerViewSampleV2") {
            CcPlayerViewSampleV2({ navigationId: this.navigationId })
        } else if (name === "CustomOverlaySample") {
            CustomOverlaySample()
        } else if (name === "PagePlayerSample") {
            PagePlayerSample()
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