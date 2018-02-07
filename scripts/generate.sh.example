#!/bin/bash

while read linein ; do
  argarray=($linein)
  manifest=${argarray[0]}
  echo $manifest
  ruby ../converter.rb ${manifest}
done <list
