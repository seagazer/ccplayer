/**
 * The action of picture render.
 */
export interface IRender {
    /**
     * Set a surface to render picture for video player.
     * @param surfaceId The surface of XComponent to be bind the media player.
     */
    setSurface(surfaceId: string)

    /**
     * Add a listener to observe the video size changed of player.
     * @param listener The listener to observe the video size changed of player.
     */
    addOnVideoSizeChangedListener(listener: (newWidth, newHeight) => void)

    /**
     * Remove a listener to observe the video size changed of player.
     * @param listener The listener to observe the video size changed of player.
     */
    removeOnVideoSizeChangedListener(listener: (newWidth, newHeight) => void)

    /**
     * Add a listener to observe the timer for first frame of video.
     * @param listener The listener to observe the timer for first frame of video.
     */
    addOnRenderFirstFrameListener(listener: () => void)

    /**
    * Remove a listener to observe the timer for first frame of video.
    * @param listener The listener to observe the timer for first frame of video.
    */
    removeOnRenderFirstFrameListener(listener: () => void)
}