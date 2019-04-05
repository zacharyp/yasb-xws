#!/bin/bash

git submodule foreach git pull origin master

cd xwing
npm install
grunt

cd ..

rm -rf app
cp -R ./xwing/app ./
