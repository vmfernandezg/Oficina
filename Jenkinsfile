pipeline {
    agent any
 
    stages {

	      /* stage ('Checkout') {
		        checkout scm
	      } */

	      stage('Create Image') {
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
        }
        
        stage('Approval-Configuration') {
            steps {
              script {
              def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
            }
              /* sh '/usr/bin/ssh-keygen'
              sh '/usr/bin/ssh-copy-id santalucia-azurerm-resource.westeurope.cloudapp.azure.com'
              sh '/usr/bin/ansible-playbook -i inventory.yml  apache-ansible.yml --extra-vars "ansible_sudo_pass=Password123#"' */
              sh '/usr/bin/ansible-playbook -i inventory.yml  apache-ansible.yml ---key-file id_rsa'
            } 
        }
    }    
}
      