#!/bin/bash
clear

# Author: Nilton R Gouvea Junior

# Run

sudo sync && sudo echo 3 | sudo tee /proc/sys/vm/drop_caches
