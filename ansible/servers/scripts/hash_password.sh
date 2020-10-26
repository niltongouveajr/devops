#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

sudo pip install passlib
python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.encrypt(getpass.getpass())"

echo ""
