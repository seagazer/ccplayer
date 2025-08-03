import { common, wantAgent } from '@kit.AbilityKit';
import { CcPlayer } from '../CcPlayer';
import { AvSessionCallback, IAvSession, MediaLogger, MediaSource, PlayerState } from '@seagazer/ccplayer-base';
import { avSession } from '@kit.AVSessionKit';

const TAG = "[AvSessionManager]"

/**
 * The manager to handle av session.
 *
 * Author: Seagazer
 * Date: 2024/10/14
 */
export class AvSessionManager implements IAvSession {
    private avSession?: avSession.AVSession = undefined
    private player: CcPlayer
    private mediaSource?: MediaSource = undefined
    private callbacks: Set<AvSessionCallback> = new Set()

    constructor(player: CcPlayer) {
        this.player = player
        this.player.addOnStateChangedListener(this.stateChangedListener)
        this.player.addOnSeekChangedListener(this.seekChangedListener)
    }

    private stateChangedListener = (state: PlayerState) => {
        if (this.avSession) {
            const avPlaybackState = this.createAvPlaybackState(state)
            MediaLogger.d(TAG, "state changed refresh av state " + JSON.stringify(avPlaybackState))
            this.avSession.setAVPlaybackState(avPlaybackState)
        }
    }
    private seekChangedListener = (position: number) => {
        if (this.avSession) {
            MediaLogger.d(TAG, "seek changed refresh av state")
            this.avSession.setAVPlaybackState({
                state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
                position: {
                    elapsedTime: position,
                    updateTime: new Date().getTime()
                },
                duration: this.player.getDuration()
            })
        }
    }

    private async create(context: common.BaseContext, sessionName: string, type: avSession.AVSessionType) {
        MediaLogger.i(TAG, "create session name= " + sessionName + ", type= " + type)
        this.avSession = await avSession.createAVSession(context, sessionName, type)
        MediaLogger.i(TAG, "create sessionId= " + this.avSession.sessionId)
    }

    private async setLaunchInfo(agentInfo: wantAgent.WantAgentInfo) {
        if (this.avSession) {
            MediaLogger.i(TAG, "setup launch app= " + JSON.stringify(agentInfo))
            let agent = await wantAgent.getWantAgent(agentInfo)
            await this.avSession.setLaunchAbility(agent)
        }
    }

    async bindAvSession(context: common.BaseContext, sessionName: string, type: avSession.AVSessionType,
        agentInfo: wantAgent.WantAgentInfo) {
        try {
            await this.create(context, sessionName, type)
            await this.setLaunchInfo(agentInfo)
            await this.bind()
            MediaLogger.d(TAG, "bindAvSession success")
        } catch (e) {
            MediaLogger.attentionE(TAG, "bindAvSession error: " + JSON.stringify(e))
        }
    }

    addAvSessionCallback(callback: AvSessionCallback) {
        this.callbacks.add(callback)
    }

    removeAvSessionCallback(callback: AvSessionCallback) {
        this.callbacks.delete(callback)
    }

    setMediaSource(mediaSource: MediaSource) {
        MediaLogger.i(TAG, "set media source= " + JSON.stringify(mediaSource))
        this.mediaSource = mediaSource
    }

    release() {
        this.callbacks.clear()
        if (this.avSession) {
            this.avSession.setAVMetadata({ assetId: "" })
            this.avSession.off("play")
            this.avSession.off("pause")
            this.avSession.off("seek")
            this.avSession.off("fastForward")
            this.avSession.off("rewind")
            this.avSession.deactivate()
            this.avSession.destroy()
            this.avSession = undefined
        }
        this.player.removeOnStateChangedListener(this.stateChangedListener)
        this.player.removeOnSeekChangedListener(this.seekChangedListener)
    }

    private setupMediaInfo() {
        if (this.avSession && this.mediaSource) {
            const data: avSession.AVMetadata = {
                assetId: this.mediaSource.title.toString(),
                title: this.mediaSource.title,
                mediaImage: this.mediaSource.cover,
                duration: this.player.getDuration()
            }
            MediaLogger.d(TAG, "set meta data= " + JSON.stringify(data))
            this.avSession.setAVMetadata(data)
        }
    }

    private async bind() {
        if (this.avSession) {
            MediaLogger.i(TAG, "bind session")
            this.setupActionListener()
            await this.avSession.activate()
        }
    }

    private createAvPlaybackState(state: PlayerState): avSession.AVPlaybackState {
        let avState = avSession.PlaybackState.PLAYBACK_STATE_INITIAL
        switch (state) {
            case PlayerState.STATE_PREPARED:
                this.setupMediaInfo()
                avState = avSession.PlaybackState.PLAYBACK_STATE_PREPARE
                break
            case PlayerState.STATE_STARTED:
            case PlayerState.STATE_BUFFER_END:
                avState = avSession.PlaybackState.PLAYBACK_STATE_PLAY
                break
            case PlayerState.STATE_PAUSED:
                avState = avSession.PlaybackState.PLAYBACK_STATE_PAUSE
                break
            case PlayerState.STATE_STOPPED:
                avState = avSession.PlaybackState.PLAYBACK_STATE_STOP
                break
            case PlayerState.STATE_COMPLETED:
                avState = avSession.PlaybackState.PLAYBACK_STATE_COMPLETED
                break
            case PlayerState.STATE_COMPLETED:
                avState = avSession.PlaybackState.PLAYBACK_STATE_COMPLETED
                break
            case PlayerState.STATE_ERROR:
                avState = avSession.PlaybackState.PLAYBACK_STATE_ERROR
                break
            case PlayerState.STATE_BUFFER_START:
                avState = avSession.PlaybackState.PLAYBACK_STATE_BUFFERING
                break
        }
        const result: avSession.AVPlaybackState = {
            state: avState,
            position: {
                elapsedTime: this.player.getCurrentPosition(),
                updateTime: new Date().getTime()
            },
            duration: this.player.getDuration()
        }
        return result
    }

    private setupActionListener() {
        if (this.avSession) {
            this.avSession.on('play', () => {
                this.player.start()
            })
            this.avSession.on('pause', () => {
                this.player.pause()
            })
            this.avSession.on('seek', (time) => {
                this.player.seekTo(time)
            })
            this.avSession.on('fastForward', (time) => {
                if (time) {
                    let currentPosition = this.player.getCurrentPosition()
                    this.player.seekTo(currentPosition + time * 1000)
                }
            })
            this.avSession.on('rewind', (time) => {
                if (time) {
                    let currentPosition = this.player.getCurrentPosition()
                    this.player.seekTo(currentPosition - time * 1000)
                }
            })
            this.avSession.on('playNext', () => {
                this.callbacks.forEach((callback) => {
                    callback.onNext()
                })
            })
            this.avSession.on('playPrevious', () => {
                this.callbacks.forEach((callback) => {
                    callback.onPrevious()
                })
            })
        }
    }
}