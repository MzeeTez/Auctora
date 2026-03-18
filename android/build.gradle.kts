import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // ✅ Required for Firebase (Google services plugin)
        classpath("com.google.gms:google-services:4.4.0") // Use latest version
    }
}

// ✅ Move build directories to a common folder outside of project to reduce clutter
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // 🔧 Point each module's build directory to subfolder of the above
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // ✅ Make sure app module is evaluated before others (if needed)
    evaluationDependsOn(":app")
}

// ✅ Clean task to delete custom build directory
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
