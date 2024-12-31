pipeline {
    agent any
    environment {
        credentials = credentials('jenkins-test-sp')
    }


    stages {


        stage('Build') {
            steps {
                script {
                    withCredentials([azureServicePrincipal('azure-service-principle')]) {
                    // Authenticate with Azure
                    sh '''
                    az login --service-principal \
                    --username $AZURE_CLIENT_ID \
                    --password $AZURE_CLIENT_SECRET \
                    --tenant $AZURE_TENANT_ID 
                    '''
                    }
                
                }
            }
        }
        stage('Checkout Code') {
            steps {
                git url: 'git@github.com:0x24dazzle/test-jenkins.git',
                    credentialsId: 'github-ssh',
                    branch: 'deploy-vm2'
            }
        }
        stage('Deploy') {
            steps {
                script {
                    //withAzureServicePrincipal('azure-service-principle') {
                    sh '''
                
                    
                    
                    
                    export ARM_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID 
                    export ARM_CLIENT_ID=$AZURE_CLIENT_ID 
                    export ARM_CLIENT_SECRET=$AZURE_CLIENT_SECRET 
                    export ARM_TENANT_ID=$AZURE_TENANT_ID 

                    terraform init -upgrade
                    terraform init
                    terraform apply -auto-approve
                '''
                    //}
                }        

            }
        }
    }
}
