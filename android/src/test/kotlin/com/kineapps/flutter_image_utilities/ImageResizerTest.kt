package com.kineapps.flutter_image_utilities

import org.hamcrest.CoreMatchers.equalTo
import org.junit.Assert.assertThat
import org.junit.Test

class ImageResizerTest {
    @Test
    fun getDownScaledSize_fitKeepAspectRatio() {
        val maxSize = Size(1920, 1024)
        assertThat(
                getDownScaledSize(Size(512, 256), maxSize, ScaleMode.FitKeepAspectRatio),
                equalTo(Size(512, 256)))
        assertThat(
                getDownScaledSize(Size(256, 512), maxSize, ScaleMode.FitKeepAspectRatio),
                equalTo(Size(256, 512)))

        // 1024x512
        assertThat(
                getDownScaledSize(Size(1024, 512), maxSize, ScaleMode.FitKeepAspectRatio),
                equalTo(Size(1024, 512)))
        assertThat(
                getDownScaledSize(Size(512, 1024), maxSize, ScaleMode.FitKeepAspectRatio),
                equalTo(Size(512, 1024)))

        // 1920x1024
        assertThat(
                getDownScaledSize(Size(1920, 1024), maxSize, ScaleMode.FitKeepAspectRatio),
                equalTo(Size(1920, 1024)))
        assertThat(
                getDownScaledSize(Size(1024, 1920), maxSize, ScaleMode.FitKeepAspectRatio),
                equalTo(Size(546, 1024)))

        // scale=0.5
        assertThat(
                getDownScaledSize(Size(3840, 2048), maxSize, ScaleMode.FitKeepAspectRatio),
                equalTo(Size(1920, 1024)))
        assertThat(
                getDownScaledSize(Size(2048, 3840), maxSize, ScaleMode.FitKeepAspectRatio),
                equalTo(Size(546, 1024)))

        // other
        assertThat(
                getDownScaledSize(Size(10000, 5000), maxSize, ScaleMode.FitKeepAspectRatio),
                equalTo(Size(1920, 960)))
        assertThat(
                getDownScaledSize(Size(5000, 10000), maxSize, ScaleMode.FitKeepAspectRatio),
                equalTo(Size(512, 1024)))
    }

    @Test
    fun getDownScaledSize_fillKeepAspectRatio() {
        val maxSize = Size(1920, 1024)
        assertThat(
                getDownScaledSize(Size(512, 256), maxSize, ScaleMode.FillKeepAspectRatio),
                equalTo(Size(512, 256)))
        assertThat(
                getDownScaledSize(Size(256, 512), maxSize, ScaleMode.FillKeepAspectRatio),
                equalTo(Size(256, 512)))

        // 1024x512
        assertThat(
                getDownScaledSize(Size(1024, 512), maxSize, ScaleMode.FillKeepAspectRatio),
                equalTo(Size(1024, 512)))
        assertThat(
                getDownScaledSize(Size(512, 1024), maxSize, ScaleMode.FillKeepAspectRatio),
                equalTo(Size(512, 1024)))

        // 1920x1024
        assertThat(
                getDownScaledSize(Size(1920, 1024), maxSize, ScaleMode.FillKeepAspectRatio),
                equalTo(Size(1920, 1024)))
        assertThat(
                getDownScaledSize(Size(1024, 1920), maxSize, ScaleMode.FillKeepAspectRatio),
                equalTo(Size(1920, 3600)))

        // scale=0.5
        assertThat(
                getDownScaledSize(Size(3840, 2048), maxSize, ScaleMode.FillKeepAspectRatio),
                equalTo(Size(1920, 1024)))
        assertThat(
                getDownScaledSize(Size(2048, 3840), maxSize, ScaleMode.FillKeepAspectRatio),
                equalTo(Size(1920, 3600)))

        // other
        assertThat(
                getDownScaledSize(Size(10000, 5000), maxSize, ScaleMode.FillKeepAspectRatio),
                equalTo(Size(2048, 1024)))
        assertThat(
                getDownScaledSize(Size(5000, 10000), maxSize, ScaleMode.FillKeepAspectRatio),
                equalTo(Size(1920, 3840)))
    }


    @Test
    fun getDownScaledSize_fitAnyDirectionKeepAspectRatio() {
        val maxSize = Size(1920, 1024)
        assertThat(
                getDownScaledSize(Size(512, 256), maxSize, ScaleMode.FitAnyDirectionKeepAspectRatio),
                equalTo(Size(512, 256)))
        assertThat(
                getDownScaledSize(Size(256, 512), maxSize, ScaleMode.FitAnyDirectionKeepAspectRatio),
                equalTo(Size(256, 512)))

        // 1024x512
        assertThat(
                getDownScaledSize(Size(1024, 512), maxSize, ScaleMode.FitAnyDirectionKeepAspectRatio),
                equalTo(Size(1024, 512)))
        assertThat(
                getDownScaledSize(Size(512, 1024), maxSize, ScaleMode.FitAnyDirectionKeepAspectRatio),
                equalTo(Size(512, 1024)))

        // 1920x1024
        assertThat(
                getDownScaledSize(Size(1920, 1024), maxSize, ScaleMode.FitAnyDirectionKeepAspectRatio),
                equalTo(Size(1920, 1024)))
        assertThat(
                getDownScaledSize(Size(1024, 1920), maxSize, ScaleMode.FitAnyDirectionKeepAspectRatio),
                equalTo(Size(1024, 1920)))

        // scale=0.5
        assertThat(
                getDownScaledSize(Size(3840, 2048), maxSize, ScaleMode.FitAnyDirectionKeepAspectRatio),
                equalTo(Size(1920, 1024)))
        assertThat(
                getDownScaledSize(Size(2048, 3840), maxSize, ScaleMode.FitAnyDirectionKeepAspectRatio),
                equalTo(Size(1024, 1920)))

        // other
        assertThat(
                getDownScaledSize(Size(10000, 5000), maxSize, ScaleMode.FitAnyDirectionKeepAspectRatio),
                equalTo(Size(1920, 960)))
        assertThat(
                getDownScaledSize(Size(5000, 10000), maxSize, ScaleMode.FitAnyDirectionKeepAspectRatio),
                equalTo(Size(960, 1920)))
    }

    @Test
    fun getDownScaledSize_fillAnyDirectionKeepAspectRatio() {
        val maxSize = Size(1920, 1024)
        assertThat(
                getDownScaledSize(Size(512, 256), maxSize, ScaleMode.FillAnyDirectionKeepAspectRatio),
                equalTo(Size(512, 256)))
        assertThat(
                getDownScaledSize(Size(256, 512), maxSize, ScaleMode.FillAnyDirectionKeepAspectRatio),
                equalTo(Size(256, 512)))

        // 1024x512
        assertThat(
                getDownScaledSize(Size(1024, 512), maxSize, ScaleMode.FillAnyDirectionKeepAspectRatio),
                equalTo(Size(1024, 512)))
        assertThat(
                getDownScaledSize(Size(512, 1024), maxSize, ScaleMode.FillAnyDirectionKeepAspectRatio),
                equalTo(Size(512, 1024)))

        // 1920x1024
        assertThat(
                getDownScaledSize(Size(1920, 1024), maxSize, ScaleMode.FillAnyDirectionKeepAspectRatio),
                equalTo(Size(1920, 1024)))
        assertThat(
                getDownScaledSize(Size(1024, 1920), maxSize, ScaleMode.FillAnyDirectionKeepAspectRatio),
                equalTo(Size(1024, 1920)))

        // scale=0.5
        assertThat(
                getDownScaledSize(Size(3840, 2048), maxSize, ScaleMode.FillAnyDirectionKeepAspectRatio),
                equalTo(Size(1920, 1024)))
        assertThat(
                getDownScaledSize(Size(2048, 3840), maxSize, ScaleMode.FillAnyDirectionKeepAspectRatio),
                equalTo(Size(1024, 1920)))

        // other
        assertThat(
                getDownScaledSize(Size(10000, 5000), maxSize, ScaleMode.FillAnyDirectionKeepAspectRatio),
                equalTo(Size(2048, 1024)))
        assertThat(
                getDownScaledSize(Size(5000, 10000), maxSize, ScaleMode.FillAnyDirectionKeepAspectRatio),
                equalTo(Size(1024, 2048)))
    }
}
