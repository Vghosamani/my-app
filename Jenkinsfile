pipeline {
  agent any

  environment {
    IMAGE_NAME = "vghosamani/myapp"   // Docker Hub repo
    IMAGE_TAG  = "${BUILD_NUMBER}"     // Unique tag per build
  }

  stages {

    // --------------------------
    stage('Checkout Code') {
      steps {
        checkout scm
      }
    }

    // --------------------------
    stage('Build Docker Image') {
      steps {
        sh '''
        docker build -t $IMAGE_NAME:$IMAGE_TAG .
        '''
      }
    }

    // --------------------------
    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'docker-creds',   // Jenkins Docker credentials
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

    // --------------------------
    stage('Deploy to Kubernetes') {
      steps {
        withCredentials([file(
          credentialsId: 'kubeconfig',   // Jenkins kubeconfig credentials
          variable: 'KUBECONFIG'
        )]) {
          sh '''
          export KUBECONFIG=$KUBECONFIG

          # Update deployment.yaml with latest image tag
          sed -i "s|image: vghosamani/myapp:.*|image: vghosamani/myapp:$IMAGE_TAG|" k8s/deployment.yaml

          # Apply deployment and service
          kubectl apply -f k8s/deployment.yaml
          kubectl apply -f k8s/service.yaml

          # Wait until rollout completes
          kubectl rollout status deployment/myapp --timeout=180s
          '''
        }
      }
    }

    // --------------------------
    stage('Verify Deployment') {
      steps {
        withCredentials([file(
          credentialsId: 'kubeconfig',
          variable: 'KUBECONFIG'
        )]) {
          sh '''
          export KUBECONFIG=$KUBECONFIG
          echo "Pods Status:"
          kubectl get pods
          echo "Service Status:"
          kubectl get svc
          '''
        }
      }
    }

  } // stages
} // pipeline

