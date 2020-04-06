#!/bin/bash

if [ -e deploy-images ]; then
  echo "Warning: bbconfigs is not clean!"
  while true; do
    echo -n "Clean bbconfigs? [y/n]: "
    read ans
    [ ! -z $ans ] && [ $ans == 'y' -o $ans == 'n' ] && break
  done
  [ $ans == 'y' ] && make clean-bbconfigs
fi

echo "Available machines are:"
read -d" " -r -a machines <<< $(make list-machine | sed 's| \* ||')

for idx in ${!machines[@]}; do
  echo "$((${idx}+1)). ${machines[$idx]}"
done

while true; do
  echo -n "Choose machine [1..${#machines[@]}]: "
  read ans
  [ ! -z $ans ] && [ $ans -gt 0 ] && [ $ans -le ${#machines[@]} ] && break
done

machine=${machines[$(($ans - 1))]}

echo "Available machine configurations are:"
read -d" " -r -a configs <<< \
  $(make MACHINE=${machine} list-config | sed 's| \* ||' | sed "/${machine}/d")

for idx in ${!configs[@]}; do
  echo "$((${idx}+1)). ${configs[$idx]}"
done

while true; do
  echo -n "Choose machine configuration [1..${#configs[@]}]: "
  read ans
  [ ! -z $ans ] && [ $ans -gt 0 ] && [ $ans -le ${#configs[@]} ] && break
done

machine_config=${configs[$(($ans - 1))]}

make MACHINE=${machine} MACHINE_CONFIG=${machine_config} configure
