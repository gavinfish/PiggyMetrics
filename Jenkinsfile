def folders = ["config", "account-service", "auth-service", "gateway", "monitoring", "notification-service", "registry", "statistics-service", "turbine-stream-service"]

def checkFolderForDiffs(path) {
    try {
        // git diff will return 1 for changes (failure) which is caught in catch, or
        // 0 meaning no changes 
        sh "git diff --quiet --exit-code HEAD~1..HEAD ${path}"
        return false
    } catch (err) {
        return true
    }
}

// The map we'll store the parallel steps in before executing them.
def stepsForParallel = folders.collectEntries {
    ["echoing ${it}" : transformIntoStep(it)]
}


// Take the string and echo it.
def transformIntoStep(inputString) {
    // We need to wrap what we return in a Groovy closure, or else it's invoked
    // when this method is called, not when we pass it to parallel.
    // To do this, you need to wrap the code below in { }, and either return
    // that explicitly, or use { -> } syntax.
    return {
        node('linux-test') {
            checkout scm

            sh "cd ${inputString}; mvn clean package -DskipTests; cd .."

            acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                registryName: env.ACR_NAME, 
                resourceGroupName: env.ACR_RES_GROUP, 
                local: "./${inputString}",
                dockerfile: "Dockerfile",
                imageNames: [[image: "$env.ACR_REGISTRY/${inputString}:$env.BUILD_NUMBER"], [image: "$env.ACR_REGISTRY/${inputString}:latest"]]
        }
    }
}

def CURRENT_VERSION = "blue"
def TARGET_VERSION = "green"

def userInput

node('master') {


    stage('init') {
        checkout scm
    }
    

    stage('build') {
        //  sh 'mvn package'
        archiveArtifacts "**/pom.xml"
    }
}