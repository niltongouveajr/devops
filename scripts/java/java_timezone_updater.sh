#!/bin/bash

# Author: Nilton R Gouvea Junior

# References:

# https://stackoverflow.com/questions/52931705/error-updating-tzdata-2018f-released-2018-10-18-with-tzupdater-2-2-0
# https://www.iana.org/time-zones
# https://www.oracle.com/technetwork/java/javase/downloads/tzupdater-download-513681.html

# Run:

#java -jar tzupdater.jar -v -f -l https://data.iana.org/time-zones/releases/tzdata2018e.tar.gz
#java -jar tzupdater.jar -v -f -l https://data.iana.org/time-zones/releases/tzdata2018f.tar.gz
#java -jar tzupdater.jar -v -f -l https://github.com/lucasbasquerotto/my-projects/raw/master/tz/tzdata2018f-01.tar.gz
java -jar tzupdater.jar -v -f -l https://devops.venturus.org.br/tzdata2018f-01.tar.gz
