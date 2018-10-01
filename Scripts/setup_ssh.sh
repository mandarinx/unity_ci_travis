#!/bin/bash
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
echo -e "INSERT_CONTENT_OF_PUB_KEY" > ~/.ssh/id_rsa.pub
echo -e "INSERT_CONTENT_OF_PRIV_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa*
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa
