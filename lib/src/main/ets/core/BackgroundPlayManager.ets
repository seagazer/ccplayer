import wantAgent from '@ohos.app.ability.wantAgent';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import common from '@ohos.app.ability.common';

export class BackgroundPlayManager {
    static async startBackground(context: common.BaseContext, agentInfo: wantAgent.WantAgentInfo) {
        const agent = await wantAgent.getWantAgent(agentInfo)
        backgroundTaskManager.startBackgroundRunning(context, backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, agent)
    }

    static async stopBackground(context: common.BaseContext) {
        backgroundTaskManager.stopBackgroundRunning(context)
    }
}