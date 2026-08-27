import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.hatri.dev"
            resValue(type = "string", name = "app_name", value = "Hatri Dev")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.hatri.app"
            resValue(type = "string", name = "app_name", value = "Hatri")
        }
    }

    buildFeatures.resValues = true
}