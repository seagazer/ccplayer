/**
 * The class to sync value between any object instances.
 *
 * Author: Seagazer
 * Date: 2025/5/21
 */
export class LiveData<T> {
    private onValueChangedListener: Set<(value: T) => void> = new Set()
    private value: T | null = null

    setValue(value: T) {
        this.value = value
        this.onValueChangedListener.forEach((callback) => {
            callback(value)
        })
    }

    getValue(): T | null {
        return this.value
    }

    addOnValueChangedListener(listener: (value: T) => void) {
        this.onValueChangedListener.add(listener)
    }

    removeOnValueChangedListener(listener: (value: T) => void) {
        this.onValueChangedListener.delete(listener)
    }
}