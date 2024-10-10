import { PlayerSample } from './PlayerSample'
import { PlayerViewSample } from './PlayerViewSample'

@Entry
@Component
struct Home {
    private style = new HomeButtonStyle()
    private navRouter = new NavPathStack()

    build() {
        Navigation(this.navRouter) {
            Column() {
                Text('CcPlayerSample')
                    .attributeModifier(this.style)
                    .onClick(() => {
                        this.navRouter.pushPathByName("PlayerSample", null)
                    })

                Text('CcPlayerViewSample')
                    .attributeModifier(this.style)
                    .margin({ top: 16 })
                    .onClick(() => {
                        this.navRouter.pushPathByName("PlayerViewSample", null)
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
        if (name === "PlayerSample") {
            PlayerSample()
        } else if (name === "PlayerViewSample") {
            PlayerViewSample()
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
    }
}