#!/bin/bash

if [ -z "$1" ];
then
com_name="Something changed. No comment given"
else
com_name=$1
fi

git add *.ino
git commit -m $com_name
git push
