import UIAbility from '@ohos.app.ability.UIAbility';
import { Logger } from '@seagazer/ccplayer';

const TAG = "MainAbility"

export default class MainAbility extends UIAbility {
    onCreate(want, launchParam) {
        globalThis.abilityWant = want;
    }

    onWindowStageCreate(windowStage) {
        windowStage.setUIContent(this.context, "pages/main", null)
        this.requestPermission()
    }


};
