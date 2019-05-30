#!/bin/bash

cp -r ../../build/release/* public/
cp ../nfsn/index.html public/
firebase deploy