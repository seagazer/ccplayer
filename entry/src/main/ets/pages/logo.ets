import router from '@system.router';

@Extend(Text)
function logoStyle() {
    .fontSize(56)
    .fontWeight(FontWeight.Bold)
}

@Entry
@Component
struct Logo {
    private logoName = ["c", "c", "p", "l", "a", "y", "e", "r",]
    @State translations: Array<number> = [0, 0, 0, 0, 0, 0, 0, 0,]
    @State alphas: Array<number> = [0, 0, 0, 0, 0, 0, 0, 0,]
    private duration = 300
    private delay = 150
    @State pageScale: number = 1
    @State pageAlpha: number = 1

    build() {
        Row() {
            ForEach(this.logoName, (name: string, index: number) => {
                Text(name).logoStyle().translate({ y: this.translations[index] }).opacity(this.alphas[index])
            })
        }
        .width("100%")
        .height("100%")
        .scale({ x: this.pageScale, y: this.pageScale })
        .opacity(this.pageAlpha)
        .justifyContent(FlexAlign.Center)
        .onAreaChange((_, newSize) => {
            let w = newSize.width as number
            let h = newSize.height as number
            let translateValue = 0
            if (w > h) {
                translateValue = -(newSize.height as number) / 4
            } else {
                translateValue = -(newSize.height as number) / 8
            }
            for (let i = 0; i < this.translations.length; i++) {
                this.translations[i] = translateValue
                animateTo(
                    {
                        duration: this.duration,
                        delay: this.delay * i,
                        curve: Curve.Friction
                    },
                    () => {
                        this.translations[i] = 0
                        this.alphas[i] = 1
                    })
            }
            setTimeout(() => {
                router.push({
                    uri: "pages/main"
                })
            }, 500 + this.duration + this.delay * this.translations.length)
        })
    }

    pageTransition() {
        PageTransitionExit({ duration: 500 }).onExit((type: RouteType, progress: number) => {
            this.pageScale = 1 - progress
            this.pageAlpha = 1 - progress
        })
    }
}