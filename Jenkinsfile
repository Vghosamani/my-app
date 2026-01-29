pipeline {
  agent any

  environment {
    IMAGE_NAME = "mydockerhubuser/myapp"
    IMAGE_TAG  = "latest"
  }

  stages {

    stage('Checkout Code') {
      steps {
        git 'https://github.com/Vghosamani/my-app.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
        docker build -t $IMAGE_NAME:$IMAGE_TAG .
        '''
      }
    }

    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'docker-creds',
          usernameVariable: 'vghosamani',
          passwordVariable: 'Vinayc@0295'
        )]) {
          sh '''
          echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
          docker push $IMAGE_NAME:$IMAGE_TAG
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
          sh '''
          export KUBECONFIG=$KUBECONFIG
          kubectl apply -f k8s/deployment.yaml
          kubectl apply -f k8s/service.yaml
          '''
        }
      }
    }

    stage('Verify Deployment') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
          sh '''
          kubectl get pods
          kubectl rollout status deployment/myapp
          '''
        }
      }
    }
  }
}

