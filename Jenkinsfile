node {


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
         sh 'mvn clean package'
    }

    stage('image') {
            parallel(
                registry: {
                    acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                        registryName: env.ACR_NAME, 
                        resourceGroupName: env.ACR_RES_GROUP, 
                        local: './registry',
                        dockerfile: "Dockerfile",
                        imageNames: [[image: "$env.ACR_REGISTRY/$env.REGISTRY_IMAGE_NAME:$env.BUILD_NUMBER"]]
                },
                config: {
                    acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                        registryName: env.ACR_NAME, 
                        resourceGroupName: env.ACR_RES_GROUP, 
                        local: './config',
                        dockerfile: "Dockerfile",
                        imageNames: [[image: "$env.ACR_REGISTRY/$env.CONFIG_IMAGE_NAME:$env.BUILD_NUMBER"]]
                },
                account: {
                    acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                        registryName: env.ACR_NAME, 
                        resourceGroupName: env.ACR_RES_GROUP, 
                        local: './account-service',
                        dockerfile: "Dockerfile",
                        imageNames: [[image: "$env.ACR_REGISTRY/$env.ACCOUNT_IMAGE_NAME:$env.BUILD_NUMBER"]]
                },
                auth: {
                    acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                        registryName: env.ACR_NAME, 
                        resourceGroupName: env.ACR_RES_GROUP, 
                        local: './auth-service',
                        dockerfile: "Dockerfile",
                        imageNames: [[image: "$env.ACR_REGISTRY/$env.AUTH_IMAGE_NAME:$env.BUILD_NUMBER"]]
                },
                notification: {
                    acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                        registryName: env.ACR_NAME, 
                        resourceGroupName: env.ACR_RES_GROUP, 
                        local: './notification-service',
                        dockerfile: "Dockerfile",
                        imageNames: [[image: "$env.ACR_REGISTRY/$env.NOTIFICATION_IMAGE_NAME:$env.BUILD_NUMBER"]]
                },
                turbine: {
                    acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                        registryName: env.ACR_NAME, 
                        resourceGroupName: env.ACR_RES_GROUP, 
                        local: './turbine-stream-service',
                        dockerfile: "Dockerfile",
                        imageNames: [[image: "$env.ACR_REGISTRY/$env.TURBINE_IMAGE_NAME:$env.BUILD_NUMBER"]]
                },
                gateway: {
                    acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                        registryName: env.ACR_NAME, 
                        resourceGroupName: env.ACR_RES_GROUP, 
                        local: './gateway',
                        dockerfile: "Dockerfile",
                        imageNames: [[image: "$env.ACR_REGISTRY/$env.GATEWAY_IMAGE_NAME:$env.BUILD_NUMBER"]]
                },
                monitoring: {
                    acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                        registryName: env.ACR_NAME, 
                        resourceGroupName: env.ACR_RES_GROUP, 
                        local: './monitoring',
                        dockerfile: "Dockerfile",
                        imageNames: [[image: "$env.ACR_REGISTRY/$env.MONITORING_IMAGE_NAME:$env.BUILD_NUMBER"]]
                },
                statistics: {
                    acrQuickTask azureCredentialsId: env.AZURE_CRED_ID, 
                        registryName: env.ACR_NAME, 
                        resourceGroupName: env.ACR_RES_GROUP, 
                        local: './statistics-service',
                        dockerfile: "Dockerfile",
                        imageNames: [[image: "$env.ACR_REGISTRY/$env.STATISTICS_IMAGE_NAME:$env.BUILD_NUMBER"]]
                }
            )
    }

    stage('deploy') {
            acsDeploy azureCredentialsId: env.AZURE_CRED_ID, 
              configFilePaths: 'scripts/registry.yaml,scripts/mq.yml,scripts/config.yaml,scripts/account-service.yaml,scripts/auth-service.yaml,scripts/gateway.yaml,scripts/monitoring.yaml,scripts/notification-service.yaml,scripts/statistics-service.yaml,scripts/turbine-stream-service.yaml', 
              containerRegistryCredentials: [[credentialsId: env.ACR_CREDENTIAL_ID, url: "http://$env.ACR_REGISTRY"]],
              containerService: "$env.AKS_NAME | AKS",
              enableConfigSubstitution: true, 
              resourceGroupName: env.AKS_RES_GROUP,
              secretName: env.ACR_SECRET
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