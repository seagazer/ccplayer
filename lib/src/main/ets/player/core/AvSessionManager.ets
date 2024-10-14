import avSession from '@ohos.multimedia.avsession';
import common from '@ohos.app.ability.common';
import { IPlayer } from '../interface/IPlayer';
import { wantAgent } from '@kit.AbilityKit';
import { PlayerState } from '../config/PlayerState';
import { MediaSource } from '../data/MediaSource';
import { MediaLogger } from '../common/MediaLogger';
import json from '@ohos.util.json';

const TAG = "[AvSessionManager]"

export class AvSessionManager {
    private avSession?: avSession.AVSession = undefined
    private player: IPlayer
    private mediaSource?: MediaSource = undefined

    constructor(player: IPlayer) {
        this.player = player
        this.player.addOnStateChangedListener(this.stateChangedListener)
    }

    async create(context: common.BaseContext, sessionName: string, type: avSession.AVSessionType) {
        MediaLogger.i(TAG, "create session name= " + sessionName + ", type= " + type)
        this.avSession = await avSession.createAVSession(context, sessionName, type)
        MediaLogger.i(TAG, "create sessionId= " + this.avSession.sessionId)
    }

    async setLaunchInfo(agentInfo: wantAgent.WantAgentInfo) {
        if (this.avSession) {
            MediaLogger.i(TAG, "setup launch app= " + json.stringify(agentInfo))
            let agent = await wantAgent.getWantAgent(agentInfo)
            await this.avSession.setLaunchAbility(agent)
        }

    }


    setMediaSource(mediaSource: MediaSource) {
        MediaLogger.i(TAG, "set media source= " + json.stringify(mediaSource))
        this.mediaSource = mediaSource
    }

    private setupMediaInfo() {
        if (this.avSession && this.mediaSource) {
            const data: avSession.AVMetadata = {
                assetId: this.mediaSource.title.toString(),
                title: this.mediaSource.title,
                duration: this.player.getDuration(),
            }
            MediaLogger.d(TAG, "set meta data= " + json.stringify(data))
            this.avSession.setAVMetadata(data)
        }
    }

    async bind() {
        MediaLogger.i(TAG, "bind session1")
        if (this.avSession) {
            MediaLogger.i(TAG, "bind session")
            this.setupActionListener()
            await this.avSession.activate()
        }
    }

    release() {
        this.player.removeOnStateChangedListener(this.stateChangedListener)
        if(this.avSession){
            this.avSession.off("play")
            this.avSession.off("pause")
            this.avSession.off("seek")
            this.avSession.off("fastForward")
            this.avSession.off("rewind")
        }
    }

    private stateChangedListener = (state: PlayerState) => {
        if (this.avSession) {
            switch (state) {
                case PlayerState.STATE_PREPARED:
                    this.setupMediaInfo()
                    break
                case PlayerState.STATE_STARTED:
                    MediaLogger.d(TAG, "update state: play")
                    this.avSession.setAVPlaybackState({
                        state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
                        position: {
                            elapsedTime: this.player.getCurrentPosition(),
                            updateTime: new Date().getTime()
                        },
                        duration: this.player.getDuration()
                    })
                    break
                case PlayerState.STATE_PAUSED:
                    MediaLogger.d(TAG, "update state: pause")
                    this.avSession.setAVPlaybackState({
                        state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
                        position: {
                            elapsedTime: this.player.getCurrentPosition(),
                            updateTime: new Date().getTime()
                        },
                        duration: this.player.getDuration()
                    })
                    break
            }
        }
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
        }
    }
}