# ccplayer-ijk

## 简介

ccplayer-ijk是基于官方@ohos/ijkplayer进行二次开发，为CcPlayer服务的一个扩展插件，需要结合CcPlayer使用。

- 支持网络媒体基础播放能力(当前1.0.0版本仅支持视频，不支持音频)
- TODO：支持网络音频播放（doing...）

## 依赖方式

```shell
1.先安装ccplayer
ohpm install @seagazer/ccplayer
2.安装ccplayer-ijk插件
ohpm install @seagazer/ccplayer-ijk
```

## 注意事项

- 插件基于 @ohos/ijkplayer 2.0.6 版本，无法独立使用，需结合@seagazer/ccplayer 1.2.6及以上版本使用，具体使用说明参考@seagazer/ccplayer。
- 播放前需要申请网络权限。


## 接口能力

- IjkPlayer IJK播放插件  
  | 接口            | 参数 | 返回值    | 说明                  |
  | --------------- | ---- | --------- | --------------------- |
  | construct       | void | IjkPlayer | 创建IjkPlayer插件实例 |
  | getLibrary      | void | string    | Native so名称         |
  | getXComponentId | void | string    | XComponent绑定的Id    |

## 场景示例

- 使用 CcPlayer 结合 IjkPlayer 插件进行视频播放：

```typescript
@Entry
@Component
struct IjkSample {
     // 1.实例化CcPlayer
    private player: CcPlayer = new CcPlayer(getContext(this))
    // 2.实例化controller
    private controller = new XComponentController()

    aboutToAppear(): void {
        // 3.设置插件
        const ijkPlayer = new IjkPlayer()
        this.player.setPlayer(ijkPlayer)
    }

    build() {
        Column() {
            Stack() {
                XComponent({
                    controller: this.controller,
                    type: XComponentType.SURFACE,
                    id: IjkPlayer.getXComponentId(), //需要绑定插件的id
                    libraryname: IjkPlayer.getLibrary(), //需要绑定插件的so名
                }).onLoad((context) => {
                    Logger.d(TAG, "onLoad= " + context)
                    if (context) {
                        // 4.绑定surface
                        this.player.bindXComponent(this.controller, context)
                    }
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
        // 5.创建mediaSource
        const source = MediaSourceFactory.createUrl("", "https:xxx.mp4")
        // 6.设置source
        this.player.setMediaSource(source)
        // 7.开始播放
        this.player.start()
    }

    aboutToDisappear() {
        // 8.释放资源
        this.player.release()
    }
}
```

更多使用场景和示例，可以参考本库代码仓的 entry 示例工程：
https://github.com/seagazer/ccplayer
使用过程中存在任何相关问题欢迎各位开发者提Issue和PR，或者加群反馈（Q群:1051643574），欢迎大家一起共建完善该库。