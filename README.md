### Terraform-based JupyterHub setup

This repository contains files and helper scripts which will setup a JupyterHub instance on a GCP VM.

#### Instructions

- Clone this repository
- Create a service account key file using the GCP console or via command line. This service account file should have privileges to create networks and VMs. The easiest is probably to assign it "editor" privileges. Download the resulting JSON-format file to your cloned directory.
    - To do this via commandline, run: 
```
gcloud iam service-accounts create <NAME> --display-name="<SOME NAME>"
gcloud projects add-iam-policy-binding <GCP project name> \ 
    --member='serviceAccount:<NAME>@<GCP project name>.iam.gserviceaccount.com' \ 
    --role='roles/editor'
gcloud iam service-accounts keys create key.json --iam-account=<NAME>@<GCP project name>.iam.gserviceaccount.com
```
- Copy the terraform variable template file: `cp terraform.tfvars.tmpl terraform.tfvars` and fill-in the variables. The `credentials_file` variable is the name of the JSON-format service account key file you just created/downloaded.
- `terraform init`
- `terraform apply`

This will create the VM and report the IP address to your terminal. Once the installation scripts are complete, you should be able to access a JupyterHub instance at `http://<IP ADDRESS>/jupyter/`

Note that visting that address will prompt for a login. As set up, the JupyterHub instance uses the username/password of user accounts on the VM itself. If you wish to login to JupyterHub, it's probably best to create a "basic" user for yourself, as described below.

#### Creating users

The repository also comes with a helper script (`add_users.sh`). This allows us to add new system users (which effectively creates a login for JupyterHub) and to copy any common files that might need to be shared with all course participants. The script assumes the data is located in `/home/common_data`. If there is no common data to share, then the copy commands will just fail.

To run the script, create a basic text file where each line has 3 elements delimited by a comma:
- email address
- a username (needs to be Unix valid!)
- a plain text password

Be careful not to put spaces in there, as it's a pretty brittle script. e.g. the file should look like:

```
foo@email.com,foo-user,abc123
bar@email.com,someone-else,def456
```

The `add_users.sh` takes this file as its first and only argument. It then iterates through each line, creating users, home directories, and copying any files.

The usernames and passwords in that file can then be used to log into JupyterHub. Each user will have their own workspace with copies of the necessary files.