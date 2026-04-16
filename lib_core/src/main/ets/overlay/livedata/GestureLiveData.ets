import { LiveData } from '@seagazer/ccplayer-base';
import { GestureEvent } from '../CcGestureOverlay';

/**
 * The liveData to sync value between CcPlayerView and CcGestureOverlay.
 *
 * Author: Seagazer
 * Date: 2025/5/21
 */
export class GestureLiveData {
    private static sInstance = new GestureLiveData()
    private gestureState = new LiveData<GestureEvent>()
    private visibleState = new LiveData<boolean>()
    private doubleClickListener?: () => void = undefined

    private constructor() {
    }

    static getInstance(): GestureLiveData {
        return GestureLiveData.sInstance
    }

    setGestureState(value: GestureEvent) {
        this.gestureState.setValue(value)
    }

    onDoubleClick() {
        this.doubleClickListener?.()
    }

    addOnDoubleClickListener(listener: () => void) {
        this.doubleClickListener = listener
    }

    removeOnDoubleClickListener() {
        this.doubleClickListener = undefined
    }
    addOnGestureStateChangedListener(listener: (value: GestureEvent) => void) {
        this.gestureState.addOnValueChangedListener(listener)
    }

    removeOnGestureStateChangedListener(listener: (value: GestureEvent) => void) {
        this.gestureState.removeOnValueChangedListener(listener)
    }

    setVisibleState(value: boolean) {
        this.visibleState.setValue(value)
    }

    addOnVisibleStateChangedListener(listener: (value: boolean) => void) {
        this.visibleState.addOnValueChangedListener(listener)
    }

    removeOnVisibleStateChangedListener(listener: (value: boolean) => void) {
        this.visibleState.removeOnValueChangedListener(listener)
    }
}