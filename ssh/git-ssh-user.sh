#!/bin/sh

### Script to conditionally provide SSH keys to GIT repositories based on repository REPOSITORY_URL
### 1. Place this script in ~/.ssh/
### 2. export GIT_SSH_COMMAND=~/.ssh/git-ssh-user.sh
### 3. Adjust paths to private keys
### 4. rReplace REPOSITORY_URL with your mathing pattern


#echo " " >> ~/.ssh/key.log
#echo "$@" >> ~/.ssh/key.log

if [[ "$@" == *"REPOSITORY_URL"* ]]; 
then
  #echo "matched" >> ~/.ssh/key.log
  /usr/bin/ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ~/.ssh/id_rsa_2 -F /dev/null $@
else
  /usr/bin/ssh -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i ~/.ssh/id_rsa -F /dev/null $@
fi

