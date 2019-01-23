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
        node {
            acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                registryName: env.ACR_NAME, 
                resourceGroupName: env.ACR_RES_GROUP, 
                local: "./${inputString}",
                dockerfile: "Dockerfile",
                imageNames: [[image: "$env.ACR_REGISTRY/${inputString}:$env.BUILD_NUMBER"], [image: "$env.ACR_REGISTRY/${inputString}:latest"]]
        }
    }
}

node {


    stage('init') {
        checkout scm
    }
    

    stage('build') {
        //  sh 'mvn package'
    }

    stage('image') {
        // Actually run the steps in parallel - parallel takes a map as an argument,
        // hence the above.
        parallel stepsForParallel
        // for (int i=0; i<folders.size(); i++) {
        //     // if (checkFolderForDiffs(folders[i]+"/")){
        //         acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
        //             registryName: env.ACR_NAME, 
        //             resourceGroupName: env.ACR_RES_GROUP, 
        //             local: "./${folders[i]}",
        //             dockerfile: "Dockerfile",
        //             imageNames: [[image: "$env.ACR_REGISTRY/${folders[i]}:$env.BUILD_NUMBER"], [image: "$env.ACR_REGISTRY/${folders[i]}:latest"]]
        //     // }
        // }
        
    }

    stage('deploy') {
        for (int i=0; i<folders.size(); i++) {
            // if (checkFolderForDiffs(folders[i]+"/")){
                withEnv(['IMAGE_TAG=latest', 'TARGET_ROLE=blue']){
                    acsDeploy azureCredentialsId: env.AZURE_CRED_ID, 
                        configFilePaths: "scripts/deployment/${folders[i]}.yaml", 
                        containerRegistryCredentials: [[credentialsId: env.ACR_CREDENTIAL_ID, url: "http://$env.ACR_REGISTRY"]],
                        containerService: "$env.AKS_NAME | AKS",
                        enableConfigSubstitution: true, 
                        resourceGroupName: env.AKS_RES_GROUP,
                        secretName: env.ACR_SECRET

                    acsDeploy azureCredentialsId: env.AZURE_CRED_ID, 
                        configFilePaths: "scripts/service/${folders[i]}.yaml", 
                        containerRegistryCredentials: [[credentialsId: env.ACR_CREDENTIAL_ID, url: "http://$env.ACR_REGISTRY"]],
                        containerService: "$env.AKS_NAME | AKS",
                        enableConfigSubstitution: true, 
                        resourceGroupName: env.AKS_RES_GROUP,
                        secretName: env.ACR_SECRET
                }
            // }
        }
    }

    stage('test') {
        sh '''
        sleep 180
        data=$(curl 'http://23.96.0.201/uaa/oauth/token' -H 'Authorization: Basic YnJvd3Nlcjo=' --data 'scope=ui&username=jieshe&password=123456&grant_type=password')
        token=$(echo $data | awk -F'[",:}"]' '{print $(5)}')
        curl --header "Authorization: Bearer $token" http://23.96.0.201/accounts/current
        '''
    }
}