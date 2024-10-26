# ccplayer

## 简介

CcPlayer 是一个为 OpenHarmony和HarmonyOS Next 设计，支持音视频媒体的轻量级播放器应用框架。

- 支持音频/视频播放
- 支持绑定播控中心
- 支持后台播放
- 视频播放组件，支持视频宽高比切换，支持手势操作

## 示例效果
| 视频组件                                                                                     | 音乐播放                                                                                     | 播控中心                                                                                     |
| -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| <img src="https://www.freeimg.cn/i/2024/10/26/671cf02bb57b1.webp" width="180" height="360"/> | <img src="https://www.freeimg.cn/i/2024/10/26/671cf02bcdc90.webp" width="180" height="360"/> | <img src="https://www.freeimg.cn/i/2024/10/23/67190716e4230.webp" width="180" height="360"/> |

## 依赖方式

```ts
ohpm install @seagazer/ccplayer
```

## 注意事项

- 从1.0.6版本开始基于API 12进行重构，仅支持OpenHarmony-5.0Release和HarmonyOS Next。
- 如果需要在5.0-Release之前的系统版本中使用，请采用1.0.5及以下版本。各个版本详情可以参照之前版本的ChangeLog说明。




## 接口能力

- CcPlayer 媒体播放器
  | 接口                             | 参数                                                                                | 返回值      | 说明                                                          |
  | -------------------------------- | ----------------------------------------------------------------------------------- | ----------- | ------------------------------------------------------------- |
  | construct                        | context: BaseContxt                                                                 | CcPlayer    | 创建CcPlayer实例                                              |
  | setPlayer                        | player: IPlayer                                                                     | void        | 设置播放器实例，用户可通过实现IPlayer接口来自定义播放业务实现 |
  | start                            | void                                                                                | void        | 开始/恢复播放                                                 |
  | startTo                          | position: number                                                                    | void        | 从指定时间戳开始播放                                          |
  | pause                            | void                                                                                | void        | 暂停播放                                                      |
  | stop                             | void                                                                                | void        | 停止播放                                                      |
  | reset                            | void                                                                                | void        | 重置播放器                                                    |
  | release                          | void                                                                                | void        | 释放播放器                                                    |
  | seekTo                           | position: number                                                                    | void        | 跳转至指定进度                                                |
  | setMediaSource                   | mediaSource: MediaSource , onReaady?: ()=>void                                      | void        | 设置媒体资源，在onReady回调中可以调用start开启播放            |
  | getMediaSource                   | void                                                                                | MediaSource | 获取当前播放的媒体资源                                        |
  | setLooper                        | isLoop: boolean                                                                     | void        | 设置循环播放                                                  |
  | setVolume                        | vol: number                                                                         | void        | 设置音量                                                      |
  | isPlaying                        | void                                                                                | boolean     | 是否正在播放                                                  |
  | getDuration                      | void                                                                                | number      | 获取媒体资源的总时长                                          |
  | getCurrentPosition               | void                                                                                | number      | 获取当前播放时长                                              |
  | getPlayerState                   | void                                                                                | PlayerState | 获取当前播放状态                                              |
  | getSystemPlayer                  | void                                                                                | AVPlayer    | 获取当前系统播放器实例                                        |
  | setSurface                       | surfaceId: string                                                                   | void        | 绑定 surafce(仅媒体类型为视频时有效)                          |
  | addOnPreparedListener            | listener: () => void                                                                | IPlayer     | 添加媒体资源 prepare 状态监听                                 |
  | removeOnPreparedListener         | listener: () => void                                                                | IPlayer     | 移除媒体资源 preapare 状态监听                                |
  | addOnCompletionListener          | listener: () => void                                                                | IPlayer     | 添加媒体资源播放结束状态监听                                  |
  | removeOnCompletionListener       | listener: () => void                                                                | IPlayer     | 移除媒体资源播放结束状态监听                                  |
  | addOnErrorListener               | listener: (code: number, message: string) => void                                   | IPlayer     | 添加媒体资源播放异常状态监听                                  |
  | removeOnErrorListener            | listener: (code: number, message: string) => void                                   | IPlayer     | 移除媒体资源播放异常状态监听                                  |
  | addOnProgressChangedListener     | listener: (duration: number) => void                                                | IPlayer     | 添加播放进度状态监听                                          |
  | removeOnProgressChangedListener  | listener: (duration: number) => void                                                | IPlayer     | 移除播放进度状态监听                                          |
  | addOnSeekChangedListener         | listener: (duration: number) => void                                                | IPlayer     | 添加播放快进快退状态监听                                      |
  | removeOnSeekChangedListener      | listener: (duration: number) => void                                                | IPlayer     | 移除播放快进快退状态监听                                      |
  | addOnVolumeChangedListener       | listener: () => void                                                                | IPlayer     | 添加媒体音量变化状态监听                                      |
  | removeOnVolumeChangedListener    | listener: () => void                                                                | IPlayer     | 移除媒体音量变化状态监听                                      |
  | addOnStateChangedListener        | listener: (state: PlayerState) => void                                              | IPlayer     | 添加播放状态变更监听                                          |
  | removeOnStateChangedListener     | listener: (state: PlayerState) => void                                              | IPlayer     | 移除播放状态变更监听                                          |
  | addOnVideoSizeChangedListener    | listener: (width: number, height: number) => void                                   | void        | 添加视频尺寸变化监听                                          |
  | removeOnVideoSizeChangedListener | listener: (width: number, height: number) => void                                   | void        | 移除视频尺寸变化监听                                          |
  | addOnRenderFirstFrameListener    | listener: () => void                                                                | void        | 添加首帧画面渲染监听                                          |
  | removeOnRenderFirstFrameListener | listener: () => void                                                                | void        | 移除首帧画面渲染监听                                          |
  | addOnMediaChangedListener        | (source: MediaSource) => void                                                       | void        | 添加切换媒体资源监听                                          |
  | removeOnMediaChangedListener     | (source: MediaSource) => void                                                       | void        | 移除切换媒体资源监听                                          |
  | bindAvSession                    | context:BaseContext, sessioName:string, type:AVSessionType, agentInfo:WantAgentInfo | void        | 绑定播控中心                                                  |
  | addAvSessionCallback             | callback: AvSessionCallback                                                         | void        | 添加播控中心操作事件监听                                      |
  | removeAvSessionCallback          | callback: AvSessionCallback                                                         | void        | 移除播控中心操作事件监听                                      |
  | setBackgroundPlayEnable          | backgroundPlay: boolean                                                             | void        | 设置是否开启后台长时播放                                      |


- AvSessionCallback 播控中心事件回调
  | 属性       | 类型       | 说明       |
  | ---------- | ---------- | ---------- |
  | onNext     | () => void | 播放下一首 |
  | onPrevious | () => void | 播放上一首 |

- CcPlayerView 视频播放组件
  | 属性                               | 类型                                                             | 说明                              | 是否必填 |
  | ---------------------------------- | ---------------------------------------------------------------- | --------------------------------- | -------- |
  | player                             | CcPlayer                                                         | 媒体播放器                        | 是       |
  | renderType                         | XComponentType                                                   | 视频渲染模式，默认SURFACE         | 否       |
  | asRatio                            | AspectRatio                                                      | 视频画面比例                      | 是       |
  | autoHideControllerDelay            | number                                                           | 自动隐藏手势 UI 的延时，默认1.5s  | 否       |
  | isSupportGesture                   | boolean                                                          | 是否支持手势操作，默认true        | 否       |
  | onTouchCallback                    | (event: TouchEvent) => void                                      | 触摸事件回调                      | 否       |
  | onSurfaceCreated                   | (surfaceId: string) => void                                      | Surface 创建事件回调              | 否       |
  | onSurfaceDestroy                   | (surfaceId: string) => void                                      | Surface 销毁事件回调              | 否       |
  | onGestureUIListener                | (visible: boolean) => void                                       | 手势 UI 显示/隐藏回调             | 否       |
  | onGestureAction                    | (type: GestureType, percent: number, isTouchUp: boolean) => void | 手势操作回调                      | 否       |
  | aspectRatioChangeAnimationDuration | number                                                           | 视频切换宽高比动效时长，默认150ms | 否       |

- GestureType 视频播放组件手势类型
  | 属性       | 说明     |
  | ---------- | -------- |
  | BRIGHTNESS | 亮度调节 |
  | PROGRESS   | 进度调节 |
  | VOLUME     | 音量调节 |

- AspectRatio 视频画面比例
  | 属性    | 说明             |
  | ------- | ---------------- |
  | AUTO    | 自动匹配         |
  | W_16_9  | 16:9 宽屏        |
  | W_4_3   | 4:3              |
  | W_21_9  | 21:9 宽屏        |
  | STRETCH | 保持比例裁切填充 |
  | FILL    | 拉伸填充         |

- PlayerState 播放器状态
  | 属性            | 说明                   |
  | --------------- | ---------------------- |
  | STATE_NOT_INIT  | 初始状态(未实例化)     |
  | STATE_IDLE      | 播放器实例化且闲置状态 |
  | STATE_PREPARED  | 播放器加载资源完成状态 |
  | STATE_STARTED   | 播放器正在播放状态     |
  | STATE_PAUSED    | 播放器暂停状态         |
  | STATE_STOPPED   | 播放器停止状态         |
  | STATE_COMPLETED | 播放器播放结束状态     |
  | STATE_ERROR     | 播放器播放异常状态     |

- MediaSourceFactory 媒体资源构建器
  | 接口         | 参数                                                                                                                     | 返回值                | 说明                          |
  | ------------ | ------------------------------------------------------------------------------------------------------------------------ | --------------------- | ----------------------------- |
  | createFile   | title: string, filePath: string, cover?: string\|Pixelmap                                                                | Promise\<MediaSource> | 通过本地文件创建媒体资源      |
  | createAssets | title: string, rawAssetsPath: string, cover?: string\|Pixelmap                                                           | MediaSource           | 通过 Raw 文件创建媒体资源     |
  | createUrl    | title: string, url: string, cover?: string\|Pixelmap, header?: Record<string, string>, strategy?: media.PlaybackStrategy | MediaSource           | 通过网络 url 地址创建媒体资源 |

## 场景示例

- 使用 CcPlayerView 播放视频的方式：

```ts
@Entry
@Component
struct PlayerViewPage {
    // 视频画面比例模式
    @State videoRatio: number = AspectRatio.AUTO
     // 1.实例化CcPlayer
    private player = new CcPlayer(getContext(this))

    build() {
        Column() {
            Stack() {
                // 2.引用CcPlayerView视频播放组件，设置参数，绑定CcPlayer
                CcPlayerView({
                    player: this.player,
                    asRatio: this.videoRatio
                })
            }
            .width(400)
            .height(300)
            .clip(true)

            // play actions
            Button("play")
                .onClick(() => {
                    this.play()
                })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
    }

    private async play() {
        // 3.创建mediaSource
        let src = await MediaSourceFactory.createFile(getContext(this).filesDir + "/test.mp4", "test.mp4")
        // 4.设置mediaSource
        this.player!.setMediaSource(src, () => {
            // 5.设置成功回调，开始播放
            this.player.start()
        })
    }

    aboutToDisappear() {
        // 6.释放资源
        this.player.release()
    }
}
```

- 使用 CcPlayer 播放视频的方式：

```ts
@Entry
@Component
struct PlayerViewPage {
    private controller = new XComponentController()
    // 1.实例化CcPlayer
    private player = new CcPlayer(getContext(this))

    build() {
        Column() {
            // render surface
            XComponent({
                type: "surface",
                id: "video",
                controller: this.controller
            }).onLoad(() => {
                let surfaceId = this.controller.getXComponentSurfaceId()
                // 2.设置surface，播放前必须设置
                this.player.setSurface(surfaceId)
            })
            .width(400)
            .height(300)

            // play actions
            Button("play")
                .onClick(() => {
                    this.play()
                })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
    }

    private async play() {
        // 3.创建mediaSource
        let src = await MediaSourceFactory.createFile(getContext(this).filesDir + "/test.mp4", "test.mp4")
        // 4.设置mediaSource
        this.player.setMediaSource(src, () => {
            // 5.设置成功回调，开始播放
            this.player.start()
        })
    }

    aboutToDisappear() {
        // 6.释放资源
        this.player.release()
    }
}
```

- 使用 CcPlayer 播放音乐的方式：

```ts
@Entry
@Component
struct PlayerViewPage {
     // 1.实例化CcPlayer
    private player = new CcPlayer(getContext(this))

    build() {
        Column() {
            // play actions
            Button("play")
                .onClick(() => {
                    this.play()
                })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
    }

    private async play() {
        // 2.创建mediaSource
        let src = await MediaSourceFactory.createFile(getContext(this).filesDir + "/test.mp3", "test.mp3")
        // 3.设置mediaSource
        this.player.setMediaSource(src, () => {
            // 4.设置成功回调，开始播放
            this.player!.start()
        })
    }

    aboutToDisappear() {
        // 5.释放资源
        this.player.release()
    }
}
```

更多使用场景和示例，例如自定义手势操作 UI，播放器状态事件监听，绑定播控中心等，可以参考本库代码仓的 entry 示例工程：
https://github.com/seagazer/ccplayer
