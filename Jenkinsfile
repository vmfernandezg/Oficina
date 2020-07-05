pipeline {
    agent any
 
    stages {

	      /* stage ('Checkout') {
		        checkout scm
	      } */

	      /* stage('Create Image') {
            steps {
              sh '/usr/local/bin/packer validate packer.json'
              sh '/usr/local/bin/packer build -force packer.json'
            }
        }
	  
        stage('TF Plan') {
            steps {
              sh '/usr/local/bin/terraform init -input=false'
              sh '/usr/local/bin/terraform plan -out=myplan -input=false'
       	    }
     	  }

	      stage('Validate') {
      	    steps {
              sh '/usr/local/bin/terraform validate'
	          }
	      }
    	  
	      stage('Approval-Apply') {
            steps {
              script {
              def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
            }
              sh '/usr/local/bin/terraform apply -input=false myplan'
            }
        } */
        
        stage('Approval-Configuration') {
            steps {
              /* sshagent(credentials : ['arqsis']) { */
              /* script {
              def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
            } 
              sh '/usr/bin/whoami'
              sh '/usr/bin/ansible-playbook -i inventory.yml  apache-ansible.yml -u arqsis --key-file /home/tomcat/.ssh/id_rsa' */
                sh '''
                  /usr/bin/ansible-playbook -i inventory.yml  apache-ansible.yml --extra-vars ansible_ssh_common_args='"-o StrictHostKeyChecking=no -o ServerAliveInterval=30"'
                '''
              /* } */
              /* sh "/usr/bin/ansible-playbook -i inventory.yml  apache-ansible.yml -u arqsis --ssh-extra-args='-o StrictHostkeyChecking=no'" */
              /* ansiblePlaybook (
                credentialsId: 'arqsis',
                hostKeyChecking: false,
                inventory: 'inventory.yml',
                playbook: 'apache-ansible.yml'
              ) */
            } 
        }
    }    
}
      