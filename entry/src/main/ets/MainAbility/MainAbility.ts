import UIAbility from '@ohos.app.ability.UIAbility';

export default class MainAbility extends UIAbility {
    onCreate(want, launchParam) {
    }

    onWindowStageCreate(windowStage) {
        windowStage.setUIContent(this.context, "pages/logo", null)
    }

}
