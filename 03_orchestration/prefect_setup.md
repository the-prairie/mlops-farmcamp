

Add to .ssh config

```bash
Host mlops-prefect
  AddKeysToAgent yes
  HostName [$ec2_prefect_public_dns]
  User ubuntu
  IdentityFile ~/.ssh/mlops.pem
  StrictHostKeyChecking no
```

Where $ec2_prefect_public_dns is the public dns address from the VM created by terraform (see 02_experiment_tracking/infrastructure folder)

`ssh mlops-prefect`

sudo apt-get update
sudo apt install python3-pip
sqlite3 --version
sudo apt install sqlite3


pip install virtualenv
nano ~/.bashrc
add line `export PATH="/home/ubuntu/.local/bin:$PATH"`
Restart terminal.

create new virtual environment: `virtualenv mlops`
source mlops/bin/activate

pip install -U "prefect>=2.0b"

prefect config set PREFECT_ORION_UI_API_URL="http://35.232.182.113:4200/api"
prefect config set PREFECT_API_URL="http://35.232.182.113:4200/api"