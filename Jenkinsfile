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


node {

    def folders = ["config", "account-service", "auth-service", "gateway", "monitoring", "notification-service", "registry", "statistics-service", "turbine-stream-service"]

    stage('init') {
        checkout scm
    }
    
    stage("last-changes") {
        def publisher = LastChanges.getLastChangesPublisher "LAST_SUCCESSFUL_BUILD", "SIDE", "LINE", true, true, "", "", "", "", ""
        publisher.publishLastChanges()
        def changes = publisher.getLastChanges()
        println(changes.getEscapedDiff())
        for (commit in changes.getCommits()) {
            println(commit)
        }
    }

    stage('build') {
         sh 'mvn package'
    }

    stage('image') {
        for (int i=0; i<folders.size(); i++) {
            // if (checkFolderForDiffs(folders[i]+"/")){
                acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                    registryName: env.ACR_NAME, 
                    resourceGroupName: env.ACR_RES_GROUP, 
                    local: "./${folders[i]}",
                    dockerfile: "Dockerfile",
                    imageNames: [[image: "$env.ACR_REGISTRY/${folders[i]}:$env.BUILD_NUMBER"], [image: "$env.ACR_REGISTRY/${folders[i]}:latest"]]
            // }
        }
        
    }

    stage('deploy') {
        for (int i=0; i<folders.size(); i++) {
            // if (checkFolderForDiffs(folders[i]+"/")){
                withEnv(['IMAGE_TAG=latest'],['TARGET_ROLE=blue']){
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