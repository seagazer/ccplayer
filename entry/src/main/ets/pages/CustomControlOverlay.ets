import { CcPlayer } from "@seagazer/ccplayer";
import { BaseOverlayConfig, BaseOverlayController } from "@seagazer/ccplayer/src/main/ets/overlay/BaseOverlay";
import { UIContext } from "@ohos.arkui.UIContext";
import { BuilderNode } from "@kit.ArkUI";
import { timeToString } from "../Extentions";

export class CustomControlOverlay extends BaseOverlayController<ControlOverlayConfig> {
  private overlayView: WrappedBuilder<[ControlOverlayConfig]> = wrapBuilder(controlOverlay);
  private preparedListener = () => {
    this.config!.totalDuration = this.config!.player.getDuration();
    this.config!.update()
  }
  private progressChangedListener = (position: number) => {
    if (this.config?.isSeeking) {
      return
    }
    this.config!.currentPosition = position;
    this.config!.currentProgress = this.getProgress(position);
    this.config?.update()
  }

  private bufferProgressChangedListener = (position: number) => {
    this.config!.bufferProgress = this.getProgress(position);
    this.config!.update()
  }

  private getProgress(position: number) {
    if (!this.config) return 0;
    if (this.config.totalDuration <= 0) return 0;
    const progress = position / this.config.totalDuration;
    return Math.min(Math.max(progress, 0), 1) * 100;
  }

  constructor(player: CcPlayer) {
    super();
    this.config = new ControlOverlayConfig(player);
    this.config!.updateBlock = () => {
      this.builderNode!.update(this.config!)
    }
  }

  aboutToAppear(): void {
    this.config!.player.addOnPreparedListener(this.preparedListener);
    this.config!.player.addOnProgressChangedListener(this.progressChangedListener);
    this.config!.player.addOnBufferProgressChangedListener(this.bufferProgressChangedListener);
  }

  aboutToDisappear(): void {
    this.config!.player.removeOnPreparedListener(this.preparedListener);
    this.config!.player.removeOnProgressChangedListener(this.progressChangedListener);
    this.config!.player.removeOnBufferProgressChangedListener(this.bufferProgressChangedListener);
  }

  makeNode(uiContext: UIContext): FrameNode | null {
    if (!this.builderNode) {
      this.builderNode = new BuilderNode(uiContext);
      this.builderNode?.build(this.overlayView, this.config!);
    }
    return this.builderNode.getFrameNode();
  }
}

@Builder
function controlOverlay(config: ControlOverlayConfig) {
  Row() {
    Text(timeToString(config.currentPosition))
      .fontSize(px2fp(35))
      .fontColor(Color.White)
      .fontWeight(FontWeight.Bold)
      .margin({ left: px2vp(28) })

    PlayingSlider({
      value: config.currentProgress,
      bufferValue: config.bufferProgress,
      onSliderChange: (value, mode) => {
        config.onSliderChange(value, mode);
      }
    })
      .layoutWeight(1)
      .margin({ left: px2vp(20), right: px2vp(20) })

    Text(timeToString(config.totalDuration))
      .fontSize(px2fp(35))
      .fontColor(Color.White)
      .fontWeight(FontWeight.Bold)
      .margin({ right: px2vp(30) })
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.SpaceBetween)
  .alignItems(VerticalAlign.Center)
  .padding({ left: px2vp(39), bottom: px2vp(46), right: px2vp(42) })
}

class ControlOverlayConfig extends BaseOverlayConfig {
  currentPosition: number = 0;
  totalDuration: number = 0;
  currentProgress: number = 0;
  bufferProgress: number = 0;
  isSeeking: boolean = false;
  updateBlock?: () => void;

  update() {
    this.updateBlock?.();
  }

  isMoved: boolean = false;
  onSliderChange(value: number, mode: SliderChangeMode) {
    if (mode === SliderChangeMode.Begin) {
      this.isSeeking = true;
      this.update()
    } else if (mode === SliderChangeMode.End) {
      this.currentPosition = this.totalDuration * value;
      if (this.isMoved) {
        this.isMoved = false;
        this.player.seekTo(this.currentPosition);
      }
      this.isSeeking = false;
      this.update()
    } else if (mode === SliderChangeMode.Moving) {
      this.isMoved = true;
    } else if (mode === SliderChangeMode.Click) {
      this.isSeeking = true;
      this.currentPosition = this.totalDuration * value;
      this.update()
      this.player.seekTo(this.currentPosition);
      setTimeout(() => {
        this.isSeeking = false;
        this.update()
      }, 100)
    }
  }
}


@ComponentV2
export struct PlayingSlider {
  @Param value: number = 0;
  @Param bufferValue: number = 0;
  @Param max: number = 100;
  @Param onSliderChange?: (value: number, mode: SliderChangeMode) => void = undefined;

  // 滑杆
  @Param trackColor: ResourceColor = '#4Dffffff';
  @Param bufferColor: ResourceColor = '#b2ffffff';
  @Param progressColor: ResourceColor = '#ff5a01';
  // 滑杆宽度
  @Local trackWidth: number = 300;
  // 滑杆高度
  @Param trackHeight: number = 3;

  // 滑块
  @Param thumbImage: Resource = $r('app.media.ic_slider_thumb');
  @Param thumbHighlightImage: Resource = $r('app.media.ic_slider_thumb');
  @Param thumbWidth: number = 16;
  @Param thumbHeight: number = 16;

  // 滑块位置
  @Local thumbPosition: number = 0;

  // 滑块的初始位置
  @Local startPosition: number = 0;

  @Local scrollValue: number = 0;
  @Local isScroll: boolean = false;

  private leftOffset: number = 5;
  private rightOffset: number = 5;

  @Monitor('value')
  onValueChange() {
    this.updateThumbPosition(this.value);
  }

  aboutToAppear(): void {
    this.updateThumbPosition(this.value);
  }

  // 更新滑块位置
  updateThumbPosition(value: number) {
    this.scrollValue = Math.min(Math.max(value, 0), this.max); // 限制范围
    this.thumbPosition = (this.scrollValue / this.max) * (this.trackWidth - this.thumbWidth + this.leftOffset + this.rightOffset) - this.leftOffset; // 计算滑块位置
  }

  build() {
    Stack() {
      // 滑杆
      Column()
        .width('100%')
        .height(this.trackHeight)
        .backgroundColor(this.trackColor)
        .borderRadius(this.trackHeight/2)

      // 缓冲条
      Column()
        .width(`${(this.bufferValue / this.max) * 100}%`)
        .height(this.trackHeight)
        .backgroundColor(this.bufferColor)
        .borderRadius(this.trackHeight/2)

      // 进度条
      Column()
        .width(`${((this.isScroll ? this.scrollValue : this.value) / this.max) * 100}%`)
        .height(this.trackHeight)
        .backgroundColor(this.progressColor)
        .borderRadius(this.trackHeight/2)

      Column()
        .width('100%')
        .height(this.trackHeight + this.thumbHeight)
        .backgroundColor(Color.Transparent)
        .hitTestBehavior(HitTestMode.Block)
        .onClick((event) => {
          const clickX = event.x;
          const clampedX = Math.min(Math.max(clickX, 0), this.trackWidth);
          const newValue = (clampedX / this.trackWidth) * this.max;
          this.updateThumbPosition(newValue);
          this.onSliderChange && this.onSliderChange(newValue / this.max, SliderChangeMode.Click);
        })

      // 滑块
      Column() {
        Image(this.isScroll ? this.thumbHighlightImage : this.thumbImage)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }
      .width(this.thumbWidth)
      .height(this.thumbHeight)
      .borderRadius(this.thumbHeight/2)
      .position({ x: this.thumbPosition, y: 0 })
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart(() => {
            this.isScroll = true;
            this.startPosition = this.thumbPosition;
            this.onSliderChange && this.onSliderChange(this.value/this.max, SliderChangeMode.Begin);
          })
          .onActionUpdate((event: GestureEvent) => {
            const offsetX = event.offsetX;
            const newPosition = this.startPosition + offsetX;
            const clampedPosition = Math.min(Math.max(newPosition, -this.leftOffset), this.trackWidth - this.thumbWidth + this.rightOffset);
            this.updateThumbPosition(((clampedPosition + this.leftOffset) / (this.trackWidth - this.thumbWidth + this.leftOffset + this.rightOffset)) * this.max);
            this.onSliderChange && this.onSliderChange(this.scrollValue/this.max, SliderChangeMode.Moving);
          })
          .onActionEnd(() => {
            this.isScroll = false;
            this.onSliderChange && this.onSliderChange(this.scrollValue/this.max, SliderChangeMode.End);
          })
          .onActionCancel(() => {
            this.isScroll = false;
            this.onSliderChange && this.onSliderChange(this.scrollValue/this.max, SliderChangeMode.End);
          })
      )
    }
    .width('100%')
    .height(this.thumbHeight)
    .alignContent(Alignment.Start)
    .onAreaChange((_, newValue) => {
      this.trackWidth = newValue.width as number;
    })
  }
}