## *Setup*

[Enable OS login for ssh access to VM](https://binx.io/blog/2022/01/28/how-to-use-os-login-for-ssh-access-to-vms-on-gcp/)

Connect to vm using
```
ssh -i ~/.ssh/[$KEYFILE] [$USERNAME]@$(terraform output --raw public_ip)
```


## *Install pyenv*


### Pyenv build dependencies
```bash
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl
```

### Install pyenv from pyenv-installer project
```
sudo curl https://pyenv.run | bash
```

### Add pyenv to your path and to initialize pyenv/pyenv-virtualenv auto completion

```
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
```
```
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
```
```
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
```


Install desired python (e.g. 3.9.8) version with

```bash
pyenv install -v 3.9.8
```

Set as global python

```shell  
pyenv global 3.9.8
```

