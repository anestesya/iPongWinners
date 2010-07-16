#!/bin/bash

## executa o shotgun com o main na porta 3001

HOST=0.0.0.0
PORT=3001
FILE='main.rb'
 
   if [ -f $FILE ]; 
    then
     /usr/bin/shotgun -p $PORT -o $HOST $FILE
   fi
 
