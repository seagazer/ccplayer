@Component
export struct CButton {
    private style = new CButtonStyle()
    text: string = ""
    onAction: () => void = () => {
    }

    build() {
        Text(this.text)
            .attributeModifier(this.style)
            .onClick(() => {
                this.onAction()
            })
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
    }
}

class CButtonStyle implements AttributeModifier<TextAttribute> {
    applyNormalAttribute(instance: TextAttribute): void {
        instance.fontSize(14)
            .fontColor(Color.White)
            .padding({
                left: 12,
                right: 12,
                top: 8,
                bottom: 8
            })
            .border({ width: 1, radius: 4, color: "#cccc" })
            .backgroundColor('#ff0A59F7')
    }

    applyPressedAttribute(instance: TextAttribute): void {
        instance.fontSize(14)
            .fontColor(Color.White)
            .padding({
                left: 12,
                right: 12,
                top: 8,
                bottom: 8
            })
            .border({ width: 1, radius: 4, color: "#cccc" })
            .backgroundColor('#ff094eda')
    }
}