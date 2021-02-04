#!/bin/bash
sed -i "1s/\#//g" $1
gzip -c $1 > $1.gz 
