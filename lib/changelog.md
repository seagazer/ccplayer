# 1.2.2

- 修复视频进入缓冲状态后无法执行seek操作问题
- 修复CcControllerOverlay视频时长为0仍然可以拖动进度条问题
- CcLoadingOverlay增加自动监听缓冲状态显隐，优化默认UI界面
- 优化内部状态机

# 1.2.0

- 当宽高为0时将抛出异常改为logE提示，解决部分用户需要从0开始动态刷新size的场景出现异常问题
- AvSessionManager优化，实现统一由CcPlayer代理

# 1.1.9

- 修复默认GestureOverlay会频繁获取媒体时长问题
- 优化媒体播放组件性能

# 1.1.8

- 状态机增加网络buffer请求状态通知

# 1.1.7

- 项目结构重构优化
- CcPlayer新增addOnPipStateChangedListener(/remove)监听pip状态接口
- UI组件性能优化

# 1.1.6

- 新增CcPlayerViewV2组件，提供给状态管理框架V2版本应用使用
- CcPlayerView和CcPlayerViewV2组件，新增修改默认手势亮度和音量值接口
- CcGestureOverlay组件新增handleGestureAction接口提供默认手势处理策略
- 优化部分Overlay组件接口的尺寸参数，由number类型扩展为Length类型
- CcPlayer新增setKeepScreenOn接口控制屏幕是否常亮
- 修复使用同个CcPlayer实例进行视频和音乐混播场景，pip接口报错问题
- 在MediaLogger关闭下，增加关键的告警和异常信息日志输出

# 1.1.5

- 新增获取本地文件视频缩略图接口
- 优化默认提供的Overlay组件

# 1.1.4

- 新增CcControllerOverlay，提供默认媒体控制操作UI组件
- 新增CcTitleBarOverlay，提供默认媒体标题显示UI组件
- CcLoadingOverlay更新为接口范式，新增loading文本设置接口
- 提供更多的overlay样式设置接口

# 1.1.3

- 适配5.0.1 Api 13
- 增加CcGestureOverlay，提供默认手势操作UI组件（接口范式，配合NodeContainer使用）
- 增加CcLoadingOverlay，提供默认视频加载UI组件（属性绑定范式）
- CcPlayer的addOnAudioFocusChangeListener修改为addOnAudioFocusChangedListener
- CcPlayer的addOnVolumeChangedListener回调接口中增加音量参数
- CcPlayerView优化手势判定，提供手势区域设置接口，增加手势滑动阻尼系数设置
- CcPlayerView初始默认亮度设置为0.5，回调中可通过window的开放接口设置亮度值
- CcPlayerView手势音量控制改为AvPlayer的开放接口，初始默认音量为1，回调中可通过CcPlayer的setVolume修改音量
- 修复部分接口文档描述错误

# 1.1.2

- 增加addOnAudioFocusChangeListener接口，提供音频焦点监听能力和默认的音频焦点处理策略
- 增加removeOnAudioFocusChangeListener接口，提供音频焦点监听能力和默认的音频焦点处理策略
- 清除框架内部冗余的非关键日志信息

# 1.1.1

- 增加CcPlayerPool接口，提供播放器实例缓存池管理能力
- 修复一些问题

# 1.1.0

- 增加setPlaySpeed播放倍速接口
- 性能优化
- 修复一些问题

# 1.0.9

- 增加开启PIP画中画接口
- 性能优化

# 1.0.8

- 修复竖屏视频场景宽高比测量异常问题

# 1.0.7

- 增加视频宽高比切换动效
- 增加切换媒体资源监听
- CcPlayerView组件的surface创建和销毁回调增加surfaceId参数
- 修复一些问题

# 1.0.6

- 适配OpenHarmony 5.0-Release和HarmonyOS Next
- 项目整体重构，适配Api12新特性
- CcPlayerView组件重构，删除fullSdk系统接口
- CcPlayer增加AvSession播控中心能力
- CcPlayer增加后台播放能力
- 不再兼容5.0以下版本

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
