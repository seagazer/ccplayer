import { MediaLogger } from '@seagazer/ccplayer_base';
import { common, wantAgent } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';

const TAG = '[BackgroundPlayManager]'

/**
 * The manager to handle background play.
 *
 * Author: Seagazer
 * Date: 2024/10/22
 */
export class BackgroundPlayManager {
    static async startBackground(context: common.BaseContext, agentInfo: wantAgent.WantAgentInfo) {
        if (canIUse('SystemCapability.ResourceSchedule.BackgroundTaskManager.ContinuousTask')) {
            const agent = await wantAgent.getWantAgent(agentInfo)
            await backgroundTaskManager.startBackgroundRunning(context, backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, agent)
            return true
        } else {
            MediaLogger.w(TAG, 'current device not support backgroundTaskManager')
            return false
        }
    }

    static async stopBackground(context: common.BaseContext) {
        if (canIUse('SystemCapability.ResourceSchedule.BackgroundTaskManager.ContinuousTask')) {
            await backgroundTaskManager.stopBackgroundRunning(context)
            return true
        } else {
            MediaLogger.w(TAG, 'current device not support backgroundTaskManager')
            return false
        }
    }
}