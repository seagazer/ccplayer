# ccplayer
A media player for OpenHarmony   一个为OpenHarmony设计，支持音视频媒体的轻量级播放器应用框架


### 框架设计
1. 框架代码结构
```typescript
player
  |----config // 框架属性定义，包括播放状态，媒体类型，视频模式
  |----core //  框架核心，包括音频，视频播放具体实现
  |----common // 日志，扩展函数等公共业务
  |----data // 媒体资源定义，提供与本地文件和url的转换接口
  |----inteface // 音频，视频业务能力定义
  |----widget // 视频播放组件
  |----CcPlayer.ts // 媒体播放器，对外提供播放能力的统一入口
```
2. 框架核心类图


### 使用方式
1. 在项目工程下的 **package.json** 配置文件中添加依赖，然后在当前目录执行**npm install**命令拉取依赖：
```typescript
{
  ...
  "dependencies": {
      ...
      "@seagazer/ccplayer": "git+https://github.com/seagazer/ccplayer.git"
   }
}
```
2. 直接在需要添加依赖的 **package.json** 配置文件所在目录下执行以下命令拉取依赖：
```typescript
  npm install https://github.com/seagazer/ccplayer
```


### 接口能力
* CcPlayer 媒体播放器
  |接口|参数|返回值|说明|
  |----|----|----|----|
  |create|PlayerType 媒体类型|CcPlayer|创建播放器实例|
  |start|void|void|开始/恢复播放|
  |startTo|position 起播时间戳 | void | 从指定时间戳开始播放|
  |pause |void|void|暂停播放|
  |stop|void|void|停止播放|
  |reset|void|void|重置播放器|
  |release|void|void|释放播放器|
  |seekTo|position 目标进度时间戳|void|跳转至指定进度|
  |setMediaSource|mediaSource 媒体资源|void|设置媒体资源|
  |getMediaSource|void|MediaSource|获取当前播放的媒体资源|
  |setLooper|isLoop 是否循环播放|void|设置循环播放|
  |setVolume|vol 音量大小|void|设置音量|
  |isPlaying|void|boolean|是否正在播放|
  |getDuration|void|number|获取媒体资源的总时长|
  |getCurrentPosition|void|number|获取当前播放时长|
  |getPlayerState|void|PlayerState|获取当前播放状态|
  |setSurface|surfaceId 渲染表层id|void|绑定surafce(仅媒体类型为视频时有效)|
  |addOnPreparedListener|listener|IPlayer|添加媒体资源prepare状态监听|
  |removeOnPreparedListener|listener|IPlayer|移除媒体资源preapare状态监听|
  |addOnCompletionListener|listener|IPlayer|添加媒体资源播放结束状态监听|
  |removeOnCompletionListener|listener|IPlayer|移除媒体资源播放结束状态监听|
  |addOnErrorListener|listener|IPlayer|添加媒体资源播放异常状态监听|
  |removeOnErrorListener|listener|IPlayer|移除媒体资源播放异常状态监听|
  |addOnProgressChangedListener|listener|IPlayer|添加播放进度状态监听|
  |removeOnProgressChangedListener|listener|IPlayer|移除播放进度状态监听|
  |addOnSeekChangedListener|listener|IPlayer|添加播放快进快退状态监听|
  |removeOnSeekChangedListener|listener|IPlayer|移除播放快进快退状态监听|
  |addOnVolumeChangedListener|listener|IPlayer|添加媒体音量变化状态监听|
  |removeOnVolumeChangedListener|listener|IPlayer|移除媒体音量变化状态监听|
  |addOnStateChangedListener|listener|IPlayer|添加播放状态变更监听|
  |removeOnStateChangedListener|listener|IPlayer|移除播放状态变更监听|
  |addOnVideoSizeChangedListener|listener|void|添加视频尺寸变化监听|
  |removeOnVideoSizeChangedListener|listener|void|移除视频尺寸变化监听|
  |addOnRenderFirstFrameListener|listener|void|添加首帧画面渲染监听|
  |removeOnRenderFirstFrameListener|listener|void|移除首帧画面渲染监听|

* CcPlayerView 视频播放组件

  | 属性             | 类型        | 说明             |是否必填|
  | ---------------- | ----------- | ---------------- |----|
  | player           | CcPlayer | 媒体播放器       |是|
  | width            | number      | 组件宽度         |是|
  | height           | number      | 组件高度         |是|
  | aspectRatio      | AspectRatio | 视频画面比例     |是|
  | autoHideControllerDelay|number|自动隐藏手势UI的延时|否|
  | isSupportGesture | boolean     | 是否支持手势操作 |否|  
  | onTouchCallback|(event: TouchEvent) => void|触摸事件回调|否|
  | isDefaultGestureUI|boolean|是否使用内置默认手势UI|否|
  | gestureUIListener|(isVisible: boolean) => void|自定义UI显隐回调|否|
  | gestureSeekAction|(seekPosition: number, max: number) => void|手势seek进度回调|否|
  | gestureBrightnessAction|(brightness: number, max: number) => void|手势Brightness进度回调|否|
  |gestureVolumeAction|(volume: number, max: number) => void|手势Volume进度回调|否|

* AspectRatio 视频画面比例

  | 属性    | 说明                     |
  | ------- | ------------------------ |
  | AUTO    | 自动匹配                 |
  | W_16_9  | 16:9宽屏                 |
  | W_4_3   | 4:3                      |
  | W_21_9  | 21:9宽屏                 |
  | STRETCH | 保持比例填充             |
  | FILL    | 拉伸填充                 |
  | ORIGIN  | 原始像素(渲染区域内显示) |

* PlayerState 播放器状态

  | 属性            | 说明                   |
  | --------------- | ---------------------- |
  | STATE_NOT_INIT  | 初始状态(未实例化)               |
  | STATE_IDLE      | 播放器实例化且闲置状态 |
  | STATE_PREPARED  | 播放器加载资源完成状态 |
  | STATE_STARTED   | 播放器正在播放状态     |
  | STATE_PAUSED    | 播放器暂停状态         |
  | STATE_STOPPED   | 播放器停止状态         |
  | STATE_COMPLETED | 播放器播放结束状态     |
  | STATE_ERROR     | 播放器播放异常状态     |

* PlayerType 媒体播放器类型

  | 属性  | 说明       |
  | ----- | ---------- |
  | AUDIO | 音频播放器 |
  | VIDEO | 视频播放器 |

* MediaSourceFactory 媒体资源构建器

  | 接口         | 参数                                            | 返回值          | 说明                     |
  | ------------ | ----------------------------------------------- | --------------- | ------------------------ |
  | createFile   | filePath 文件绝对路径                           | Promise<MediaSource> | 通过本地文件创建媒体资源 |
  | createAssets | abilityContext 上下文,  assetsPath 资源相对路径 | Promise<MediaSource> | 通过Raw文件创建媒体资源  |

  

### 示例工程
可以切换到**dev**分支下载代码，工程中内置了示例模块，包含音频播放，视频播放，CcPlayerView组件的使用和常见场景的业务处理方式。
