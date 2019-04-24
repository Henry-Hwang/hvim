#!/bin/bash

DIR=$1
for item in $(ls $DIR)
do
	echo "$DIR/$item"
	tar -zxvf $DIR/$item -C $DIR
done
