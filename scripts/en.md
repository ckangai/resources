# Diagnosing Issues with Cloud Assist

## Overview
Developers create CI/CD pipelines to automate the deployment of their apps whenever changes are pushed to the main branch of their Git repository. In this lab you build a CI/CD pipeline that deploys to Cloud Run.


## Objectives
This lab guides you through using Gemini Cloud Assist to diagnose and troubleshoot common issues, optimize resource costs, and manage resources effectively within a Google Cloud project.


## Scenario
You are an operations engineer for an existing ecommerce application deployed on Google Cloud. Your application is experiencing intermittent performance issues, and your team is looking to optimize cloud spending and ensure efficient resource management. You use Gemini Cloud Assist as your primary tool to address these challenges.


## Setup
<!-- Most labs require all three fragments, but your lab may not. For example, you might not need to use the `cloudshell` fragment if the lab instructions don't have CLI commands to run. -->

![[/fragments/startqwiklab]]

![[/fragments/gcpconsole]]

![[/fragments/cloudshell]]


## Task 1. Environment setup and resource provisioning
In this task, you prepare your local environment and provision the necessary Google Cloud resources using Terraform.

1. From the navigator menu of the Google Cloud console, go to **APIs & Services > Enabled APIs & services**.

2. Click **Library**. In the Search box, enter `Gemini` and press ENTER. Enable the services Gemini for Google Cloud and Gemini Cloud Assist.

3.	Similarly search for `Recommender` and enable the Recommender API.

4. 	In the Google Cloud console, if Cloud Shell is not already open, click **Activate Cloud Shell** (![Activate Cloud Shell icon](img/activate_shell.png)) in the top menu to open Cloud Shell.

5.	Run the following command to copy your project id into an environment variable.
    <ql-code-block>
	gcloud services enable iap.googleapis.com
    PROJECT_ID=$(gcloud config get-value project)
    echo "PROJECT_ID=${PROJECT_ID}"
    </ql-code-block>

6.	Run the following command to capture your logged in user name into an environment variable.
    <ql-code-block>
    USER=$(gcloud config get-value account 2> /dev/null)
    echo "USER=${USER}"
    </ql-code-block>

7.	Grant your logged in user permission to use Gemini Cloud Assist.
    <ql-code-block>
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/cloudaicompanion.user
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/serviceusage.serviceUsageConsumer
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/cloudasset.viewer
	gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/recommender.viewer
    </ql-code-block>

8. 	Clone the repository with the Terraform files for this lab. Run the following command.
	<ql-code-block>
	git clone https://github.com/ckangai/resources.git
	</ql-code-block>

9.	Change directory to the resources folder. Run the following command.
	<ql-code-block>
	cd resources
	</ql-code-block>

10.  At the top of Cloud Shell, click **Open Editor** and from the resources folder, open the terraform.tfvars file. 

11.	Replace <"your-project-id-here"> with your project id.

12.	To initialize Terraform and create the plan, return to the Cloud Shell terminal and enter the following commands:

	<ql-code-block>
	cd ~/resources
	terraform init
	terraform plan
	</ql-code-block>

13. To create the resources, run the following command:

	<ql-code-block>
	terraform apply -auto-approve
	</ql-code-block>

14. When the resource creating has completed, review the changes in the Cloud Console with the following tools:

	**Compute Engine > VM Instances**
	**View All Products > VPC Network**
	**View All Products > VPC Network > Network Peering**


## Task 3. Prepare Your Project Files

1.  At the top of Cloud Shell, click **Open Editor**.

2.	Open the substitute_with_sed.sh script located in the scripts subfolder of the resources folder.

3. Replace the placeholder <your-project-id> with the actual project id.

4. Replace the placeholder <your-zone> with the name of the zone in which your resources have been created. You can find this information on the VM Instances page which you access via Compute Engine > VM Instances.

5. Replace all the remaining placeholders, using the information on the VM Instances page of the Google Cloud Console. When you complete, your file should look similar to this:

6. Return to the Terminal window by clicking Open Terminal, and run the following commands:
	<ql-code-block>
	cd ~/resources/scripts
	chmod +x substitute_with_sed.sh
	./substitute_with_sed.sh
	</ql-code-block>

	<ql-infobox>
	Note: This should have modified several script files with specific information of the resources you have created. Feel free to open the script files and review the changes. The file names are 1.sh, 2.sh, 3.sh, 4.sh, 5.sh and 6.sh. You will shortly run these scripts to create some activity. 
	</ql-infobox>

7.	Run the following script to kickstart the simulation activity:

	<ql-code-block>
	chmod +x *.sh
	./6.sh
	</ql-code-block>

	When asked whether to create an .ssh directory enter Yes. When asked for a passphrase press ENTER twice.

	Leave the script running for a approximately 5 minutes.
	<ql-infobox>
	The script installs MySQL Server and MySQL Server client, creates a test database then runs queries to simulate a production environment. It then runs commnds on resources to create a load and some log entries. Some of the commands return errors.
	</ql-infobox>

