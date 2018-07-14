#!/bin/sh

echo "\n"

echo Committing...|lolcat -a -d 50

echo "\n"

git add -A

git commit -m "$1"

git push

echo "\n"
