import Croppr from "croppr"
import {waitForElement} from "../utils"

export const ImageCropper = {
    async mounted() {
        const image = await waitForElement(".crop-target")

        new Croppr(image, {
            aspectRatio: 1,
            startSize: [100, 100, '%'],
            onInitialize: (instance) => {
                this.pushEvent("update-mask", { value: instance.getValue() })
            },
            onCropEnd: (value) => {
                this.pushEvent("update-mask", { value })
            }
        })
    }
};