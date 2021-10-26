#!/bin/bash

if [ -e deploy-images ]; then
  if [ ! -z "$1" ]; then
    # Non-interactive run
    echo "Cleaninig bbconfigs..."
    make clean-bbconfigs
  else
    echo "Warning: bbconfigs is not clean!"
    while true; do
      echo -n "Clean bbconfigs? [y/n]: "
      read ans
      [ ! -z $ans ] && [ $ans == 'y' -o $ans == 'n' ] && break
    done
    [ $ans == 'y' ] && make clean-bbconfigs
  fi
fi

# Non-interactive
if [ ! -z "$1" ]; then
  machine=$(make list-machine | sed 's| \* ||' | grep -i "$1")
  [ $(echo ${machine} | wc -w) -ne 1 ] \
    && { echo -e "\e[31mMachine selection $1 is ambiguous, fallback to interactive mode.\e[0m" && unset machine; } \
    || echo -e "\e[32mUsing machine ${machine}.\e[0m"
fi

# Interactive
if [ -z "$machine" ]; then
  echo -e "\e[33mAvailable machines are:\e[0m"
  read -d" " -r -a machines <<< $(make list-machine | sed 's| \* ||')

  for idx in ${!machines[@]}; do
    echo "$((${idx}+1)). ${machines[$idx]}"
  done

  ans=1
  if [ ${#machines[@]} -ne 1 ]; then
      while true; do
        echo -n "Choose machine [1..${#machines[@]}]: "
        read ans
        [ ! -z $ans ] && [ $ans -gt 0 ] && [ $ans -le ${#machines[@]} ] && break
      done
  fi
  machine=${machines[$(($ans - 1))]}
fi

# Non-interactive
if [ ! -z "$2" ]; then
  machine_config=$(make MACHINE=${machine} list-config | sed 's| \* ||' | grep -i "$2")
  [ $(echo ${machine_config} | wc -w) -ne 1 ] \
    && { echo -e "\e[31mMachine configuration $1 is ambiguous, fallback to interactive mode.\e[0m" && unset machine_config; } \
    || echo -e "\e[32mUsing machine configuration ${machine_config}.\e[0m"
fi

# Interactive
if [ -z "$machine_config" ]; then
  echo -e "\e[33mAvailable machine configurations are:\e[0m"
  read -d" " -r -a configs <<< \
    $(make MACHINE=${machine} list-config | sed 's| \* ||' | sed "/${machine}/d")

  for idx in ${!configs[@]}; do
    echo "$((${idx}+1)). ${configs[$idx]}"
  done

  ans=1
  if [ ${#configs[@]} -ne 1 ]; then
      while true; do
        echo -n "Choose machine configuration [1..${#configs[@]}]: "
        read ans
        [ ! -z $ans ] && [ $ans -gt 0 ] && [ $ans -le ${#configs[@]} ] && break
      done
  fi
  machine_config=${configs[$(($ans - 1))]}
fi

[ -z "$2" ] && [ -t 0 ] && \
    echo -e "\e[32mTip: use '$0 ${machine} ${machine_config}' for non-interactive mode.\e[0m"

make MACHINE=${machine} MACHINE_CONFIG=${machine_config} clean-links configure
