# 1.0.6

- 适配OpenHarmony 5.0-Release和HarmonyOS Next
- 项目整体重构，适配Api12新特性
- CcPlayerView组件重构，删除fullSdk系统接口
- CcPlayer增加AvSession播控中心能力
- CcPlayer增加后台播放能力

# 1.0.5

- 适配4.1
- CcPlayerView组件增加onSurfaceCreated接口
- 修复部分场景因为创建播放器实例接口执行太慢导致播放时序错乱问题
- 开放PlayerView供next版本使用

# 1.0.4

- 废弃3.2及以下接口
- 优化适配4.1版本
- 增加PlayerView适配next版本

# 1.0.3

- 修复部分问题

# 1.0.2

- 性能优化
- 对OpenHarmony原生接口异常问题进行容错处理
-

# 1.0.1

- 升级适配4.0release
- 组件性能优化
- 注意：本库引用了系统接口，需使用系统签名和fullSdk
- 如果在4.0以下系统上使用出现api兼容性问题，建议使用1.0.0版本

# 1.0.0

- 支持音频/视频播放
- 视频播放组件，支持视频宽高比设置，手势控制音量、亮度、播放进度
- OpenHarmony 3.1 和 3.2+ 自适应使用 AvPlayer 或 AudioPlayer 或 VideoPlayer
- 注意：本库引用了系统接口，需使用系统签名
