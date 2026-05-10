/**
 *
 * Author: Seagazer
 * Date: 2025/10/8
 */
export interface IIjk {
    /**
     * Set the category of ijkplayer
     * @param category The category value.
     * @param key The key of the category.
     * @param value The value of the category.
     */
    setOption(category: string, key: string, value: string): void

    /**
     * Set the id of the XComponent component.
     * @param id The id of the XComponent component.
     */
    setXComponentId(id: string): void

    /**
     * Get the id of the XComponent component.
     * @returns The id of the XComponent component.
     */
    getXComponentId(): string
}