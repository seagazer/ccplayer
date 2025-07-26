import { common, wantAgent } from "@kit.AbilityKit"
import { avSession } from "@kit.AVSessionKit"
import { AvSessionCallback } from "../common/AvSessionCallback"

/**
 * Define the action of av session.
 *
 * Author: Seagazer
 * Date: 2025/3/6
 */
export interface IAvSession {
    /**
     * Bind av session.
     * @param context The context of app.
     * @param sessionName The name of av session.
     * @param type The type of av session.{@link avSession.AVSessionType}
     * @param agentInfo The agent info of av session.{@link wantAgent.WantAgentInfo}
     */
    bindAvSession(context: common.BaseContext, sessionName: string, type: avSession.AVSessionType, agentInfo: wantAgent.WantAgentInfo): Promise<void>

    /**
     * Add a callback {@link AvSessionCallback} to observe the play action like play next and play previous.
     * @param callback The callback to observe the play action.
     */
    addAvSessionCallback(callback: AvSessionCallback): void

    /**
     * Remove a callback {@link AvSessionCallback} to observe the play action like play next and play previous.
     * @param callback The callback to observe the play action.
     */
    removeAvSessionCallback(callback: AvSessionCallback): void
}