# ccplayer
A media player for OpenHarmony   一个为OpenHarmony设计，支持音视频媒体的轻量级播放器应用框架


### 框架设计
1. 框架代码结构
```typescript
player
  |----config // 框架属性定义，包括播放状态，媒体类型，视频比例
  |----core //  框架核心，包括音频，视频播放具体实现
  |----helper // 辅助工具
  |----inteface // 音频，视频业务能力定义
  |----widget // 视频播放组件
  |----MediaPlayer.ts // 媒体播放器，对外提供播放能力的统一入口
```
2. 框架核心类图


### 使用方式
1. 在项目工程下的 **package.json** 配置文件中添加依赖：
```typescript
{
  ...
  "dependencies": {
      ...
      "@seagazer/ccplayer": "git+https://github.com/seagazer/ccplayer.git"
   }
}
```
2. 在添加依赖的 **package.json** 配置文件所在目录下执行以下命令拉取依赖：
```typescript
  npm install https://github.com/seagazer/ccplayer
```


### 接口能力
* MediaPlayer
  |接口|参数|返回值|说明|
  |----|----|----|----|
  |create|PlayerType 媒体类型|MediaPlayer|创建播放器实例|
  |start|void|void|开始/恢复播放|
  |startTo|position 起播时间戳 | void | 从指定时间戳开始播放|
  |pause |void|void|暂停播放|
  |stop|void|void|停止播放|
  |reset|void|void|重置播放器|
  |release|void|void|释放播放器|
  |seekTo|position 目标进度时间戳|void|跳转至指定进度|
  |setDataSourceUrl|url 网络媒体链接地址|void|设置网络媒体资源|
  |setDataSourceFile|sourcePath 本地媒体资源路径|void|释放播放器|
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

* LitePlayerView
* AspectRatio
* PlayerState
* PlayerType
* MediaSource

### 示例工程
可以切换到**dev**分支下载代码，工程中内置了示例模块，包含音频播放，视频播放，LitePlayerView组件的使用。
