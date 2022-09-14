import Ability from '@ohos.application.Ability'

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        globalThis.abilityWant = want;
        globalThis.context = this.context
    }

    onWindowStageCreate(windowStage) {
        windowStage.setUIContent(this.context, "pages/main", null)
    }
};
