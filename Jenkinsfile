pipeline {
  agent any

  environment {
    IMAGE_NAME = "vghosamani/myapp"
    IMAGE_TAG  = "${BUILD_NUMBER}"
  }

  stages {

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
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
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

          kubectl set image deployment/myapp \
            myapp=$IMAGE_NAME:$IMAGE_TAG

          kubectl rollout restart deployment/myapp
          '''
        }
      }
    }

    stage('Verify Deployment') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
          sh '''
          kubectl rollout status deployment/myapp --timeout=180s
          kubectl get pods
          '''
        }
      }
    }
  }
}





