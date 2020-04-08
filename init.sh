#!/bin/bash


# init.sh script for "play" with docker-compose command

if [[ $EUID -ne 0 ]]
then
echo -e "The user is not ROOT, so it is not allowed to run the script"
exit 1
fi

usage() {

  echo >&2
  echo "Usage: ${0} [-prdu]" >&2
  echo '  -p  Pull images of all the containers' >&2
  echo '  -r  Docker compose restart' >&2  
  echo '  -d  Docker compose down' >&2
  echo '  -u  Docker compose up' >&2
  echo '  -c  Docker clean (prune)' >&2
  exit 1
}

while getopts prduc OPTION
do
  case ${OPTION} in
    p) pull='true' ;;
    r) restart='true' ;;
    d) down='true' ;;
    u) up='true' ;;
    c) clean='true' ;;
    ?) usage ;;
  esac
done

#shift "$(( OPTIND - 1 ))"

if [[ "${#}" < 1 ]]
then
  usage
fi

  if [[ "${pull}" = 'true' ]]; then  
  echo -e "Pulling all the images for containers:\n"
  docker ps | awk '{print $2}' | tail -n +2
  echo -e "\n"
  for i in $(docker ps | awk '{print $2}' | tail -n +2); do docker pull $i ; done
  # Recreate containers with the new image
  docker-compose up -d 
  # Clean up old container
  docker system prune -f
  fi

  if [[ "${restart}" = 'true' ]]; then
  docker-compose restart 
  fi
   
  if [[ "${down}" = 'true' ]]; then
  docker-compose down 
  fi 
 
  if [[ "${up}" = 'true' ]]; then
  docker-compose up -d 
  fi

  if [[ "${clean}" = 'true' ]]; then 
  docker system prune -af 
  fi

exit 0
