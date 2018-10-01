#!/bin/bash
openssl enc -aes-256-cbc -a -salt -in ./Scripts/setup_ssh.sh -out setup_ssh.sh.enc -k $1
