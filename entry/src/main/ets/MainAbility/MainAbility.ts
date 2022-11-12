import { Logger } from '@seagazer/ccplayer';
import Ability from '@ohos.application.Ability'

const TAG = "MainAbility"

export default class MainAbility extends Ability {
    onCreate(want, launchParam) {
        globalThis.abilityWant = want;
    }

    onWindowStageCreate(windowStage) {
        windowStage.setUIContent(this.context, "pages/main", null)
        this.requestPermission()
    }

    private requestPermission() {
        let permissions: Array<string> = [
            "ohos.permission.READ_MEDIA",
            "ohos.permission.WRITE_MEDIA",
            "ohos.permission.READ_USER_STORAGE",
            "ohos.permission.WRITE_USER_STORAGE"
        ]
        this.context.requestPermissionsFromUser(permissions, (err, result) => {
            if (err) {
                Logger.d(TAG, 'requestPermissionsFromUserError: ' + JSON.stringify(err));

            } else {
                let permissionRequestResult = result;
                Logger.d(TAG, 'permissionRequestResult: ' + JSON.stringify(permissionRequestResult));
            }
        })
    }
};
