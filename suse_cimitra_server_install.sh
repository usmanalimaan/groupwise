#!/bin/bash
###########################################
# suse_cimitra_server_install.sh          #
# Author: Tay Kratzer - tay@cimitra.com   #
# Version: 1.0                            #
# Modify date: 4/29/2020                  #
###########################################
# Cimitra SUSE Server Installation Script

declare -i UNINSTALL=0
declare -i SHOW_HELP=0

while getopts "hU" opt; do
  case ${opt} in
    U) UNINSTALL=1
      ;;
    h) SHOW_HELP="1"
      ;;
  esac
done


if [ $SHOW_HELP -eq 1 ]
then
echo ""
echo "--- Script Help ---"
echo ""
echo "Install Docker, Docker Compose Utility, Cimitra Server, Cimitra Agent"
echo ""
echo "$0"
echo ""
echo "Show Help"
echo ""
echo "$0 -h"
echo ""
echo "-------------------"
exit 0
fi

declare CIMITRA_SERVER_PORT="443"
declare -i PROCEED_WITH_AGENT_INSTALL=0
declare CIMITRA_API_SESSION_TOKEN=""
declare -i RUN_AGENT_INSTALL=1
declare CIMITRA_SERVER_ADMIN_ACCOUNT="admin@cimitra.com"
declare CIMITRA_SERVER_ADMIN_PASSWORD="changeme"
declare CIMITRA_SERVER_PORT="443"
declare CIMITRA_SERVER_ADDRESS=`ifconfig eth0 | grep "inet addr" | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1`
declare -i POST_OFFICE_IN_SET="0"
declare -i CIMITRA_AGENT_IN_SET="0"
declare CIMITRA_PAIRED_AGENT_ID=""
declare TEMP_FILE_DIRECTORY="/var/tmp"
declare SERVER_HOSTNAME=`hostname`
declare CIMITRA_AGENT_IN_UPPER=`basename ${SERVER_HOSTNAME} | tr [a-z] [A-Z]`
declare -i DOCKER_DAEMON_LOADED=0

CIMITRA_SERVER_DIRECTORY="/var/opt/cimitra/server"

function CALL_ERROR_EXIT()
{
ERROR_MESSAGE="$1"
echo ""
echo "$(tput setaf 1)ERROR:$(tput setab 7)${ERROR_MESSAGE}$(tput sgr 0)"
echo ""
exit 1
}

function CALL_INFO()
{
INFO_MESSAGE="$1"
echo ""
echo "$(tput setaf 2)INFO:$(tput setab 4)${INFO_MESSAGE}$(tput sgr 0)"
echo ""
}

# Confirm or install Docker
function CONFIRM_OR_INSTALL_DOCKER()
{

{
declare -i DOCKER_EXISTS=`docker ; echo $?`
} 1> /dev/null 2> /dev/null

if [ $DOCKER_EXISTS -eq 0 ]
then

CALL_INFO "Docker Installation Confirmed"

{
docker ps 
} 1> /dev/null 2> /dev/null

DOCKER_DAEMON_LOADED=`echo $?`


	if [ $DOCKER_DAEMON_LOADED -eq 0 ]
	then
	return 0
	fi

CALL_INFO "Starting Docker Daemon"

systemctl start docker

systemctl enable docker


{
docker ps 1> /dev/null 2> /dev/null
} 1> /dev/null 2> /dev/null

DOCKER_DAEMON_LOADED=`echo $?`

	if [ $DOCKER_DAEMON_LOADED -ne 0 ]
	then
	docker ps 
	CALL_ERROR_EXIT "Cannot Start The Docker Daemon"
	fi

return 0
fi

CALL_INFO "Docker Installation Beginning"

DOCKER_INSTALL_COMMAND="sudo zypper -n install docker"

${DOCKER_INSTALL_COMMAND}

{
declare -i DOCKER_EXISTS=`docker ; echo $?`
} 1> /dev/null 2> /dev/null


if [ $DOCKER_EXISTS -ne 0 ]
then
CALL_ERROR_EXIT "Docker Installation Failed"
fi

CALL_INFO "Starting Docker Daemon"

systemctl start docker

systemctl enable docker

{
docker ps 1> /dev/null 2> /dev/null
} 1> /dev/null 2> /dev/null


DOCKER_DAEMON_LOADED=`echo $?`

	if [ $DOCKER_DAEMON_LOADED -ne 0 ]
	then
	docker ps 
	CALL_ERROR_EXIT "Cannot Start The Docker Daemon"
	fi

}

# Confirm or install docker-compose
function CONFIRM_OR_INSTALL_DOCKER_COMPOSE()
{

{
declare -i DOCKER_COMPOSE_EXISTS=`docker-compose ; echo $?`
} 1> /dev/null 2> /dev/null

if [ $DOCKER_COMPOSE_EXISTS -lt 2 ]
then
CALL_INFO "Docker Compose (docker-compose) Installation Confirmed"
return 0
fi
CALL_INFO "Docker Compose (docker-compose) Installation Beginning"

sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

{
sudo chmod +x /usr/local/bin/docker-compose 
} 1> /dev/null 2> /dev/null

{
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
} 1> /dev/null 2> /dev/null

{
declare -i DOCKER_COMPOSE_EXISTS=`docker-compose ; echo $?`
} 1> /dev/null 2> /dev/null

if [ $DOCKER_COMPOSE_EXISTS -gt 1 ]
then
CALL_ERROR_EXIT "Docker Compose Utility Installation Failed"
fi

}


# Make the server directory /var/opt/cimitra/server
# Download the Cimitra Server YAML File
# Determine if port 443 is in use

function DOWNLOAD_CIMITRA_YAML_FILE()
{

{
mkdir -p ${CIMITRA_SERVER_DIRECTORY}
} 1> /dev/null 2> /dev/null

declare -i CD_WORKED=1

{
cd ${CIMITRA_SERVER_DIRECTORY}
} 1> /dev/null 2> /dev/null

CD_WORKED=`echo $?`

if [ $CD_WORKED -ne 0 ]
then
CALL_ERROR_EXIT "Cannot Access Path: ${CIMITRA_SERVER_DIRECTORY}"
fi

LOCAL_YAML_FILE="docker-compose.yml"

declare -i LOCAL_YAML_FILE_EXISTS=`test -f ./${LOCAL_YAML_FILE} ; echo $?`

if [ $LOCAL_YAML_FILE_EXISTS -eq 0 ]
then
CALL_INFO "YAML File: ${CIMITRA_SERVER_DIRECTORY}/${LOCAL_YAML_FILE} - Already Exists"
return 0
fi

CALL_INFO "Downloading YAML File To: ${CIMITRA_SERVER_DIRECTORY}/${LOCAL_YAML_FILE}"


DOWNLOAD_FILE="curl -LJO https://raw.githubusercontent.com/cimitrasoftware/docker/master/docker-compose.yml -o ./${LOCAL_YAML_FILE}"

{
cat < /dev/tcp/localhost/443 &
} 2> /dev/null

CONNECTION_PROCESS=$!

declare -i CONNECTION_PROCESS_WORKED=`ps -aux | grep ${CONNECTION_PROCESS} | grep -c "cat"`

if [ $CONNECTION_PROCESS_WORKED -gt 0 ]
then

{
cat < /dev/tcp/localhost/444 &
} 2> /dev/null

CONNECTION_PROCESS=$!

declare -i CONNECTION_PROCESS_WORKED=`ps -aux | grep ${CONNECTION_PROCESS} | grep -c "cat"`

	if [ $CONNECTION_PROCESS_WORKED -eq 0 ]
	then
	DOWNLOAD_FILE="curl -LJO https://raw.githubusercontent.com/cimitrasoftware/docker/master/docker-compose-444.yml"
	mv ${CIMITRA_SERVER_DIRECTORY}/docker-compose-444.yml  ${CIMITRA_SERVER_DIRECTORY}/${LOCAL_YAML_FILE}
	CIMITRA_SERVER_PORT="444"
	fi


fi


${DOWNLOAD_FILE}

}


# Bring up the Cimitra Server
function START_CIMITRA_DOCKER_CONTAINER()
{
CALL_INFO "Initiating Cimitra Server Docker Containers"

cd ${CIMITRA_SERVER_DIRECTORY}

docker-compose up -d

DOCKER_UP_STATUS=`echo $?`

if [ $DOCKER_UP_STATUS -ne 0 ]
then
CALL_ERROR_EXIT "Cannot Start the Cimitra Server Docker Container"
fi

CALL_INFO "The Cimitra Server Was Successfully Installed"

CIMITRA_SERVER_PORT=`cat ${CIMITRA_SERVER_DIRECTORY}/${LOCAL_YAML_FILE} | grep ":443" | head -1 | awk -F : '{printf $1}' | awk -F "-" '{printf $2}' | sed 's/  *//g'`

case $CIMITRA_SERVER_PORT in
443)
CALL_INFO "Log into Cimitra @ https://${CIMITRA_SERVER_ADDRESS}"
;;
*)
CALL_INFO "Log into Cimitra @ https://${CIMITRA_SERVER_ADDRESS}:${CIMITRA_SERVER_PORT}"
;;
esac
}

function CONNECT_TEST()
{

{
cat < /dev/tcp/${CIMITRA_SERVER_ADDRESS}/${CIMITRA_SERVER_PORT} &
} 2> /dev/null

CONNECTION_PROCESS=$!

declare -i CONNECTION_PROCESS_WORKED=`ps -aux | grep ${CONNECTION_PROCESS} | grep -c "cat"`

if [ $CONNECTION_PROCESS_WORKED -eq 0 ]
then
return 1
else
return 0
fi

}

function ESTABLISH_CIMITRA_API_SESSION()
{

# CALL_INFO "Establishing Connection to Cimitra Server"

BASEURL="https://${CIMITRA_SERVER_ADDRESS}:${CIMITRA_SERVER_PORT}/api" 

ENDPOINT="/users/login" 

URL="${BASEURL}${ENDPOINT}" 

DATA="{\"email\":\"${CIMITRA_SERVER_ADMIN_ACCOUNT}\",\"password\": \"${CIMITRA_SERVER_ADMIN_PASSWORD}\"}" 

{
RESPONSE=`curl -k -f -H "Content-Type:application/json" -X POST ${URL} --data "$DATA"`
} 2> /dev/null

declare -i STATUS=`echo "${RESPONSE}" | grep -c ',\"homeFolderId\":\"'` 

if [ ${STATUS} -eq 0 ] 
then
PROCEED_WITH_AGENT_INSTALL="1"
return 1
fi 

CIMITRA_API_SESSION_TOKEN=`echo "${RESPONSE}" | awk -F \"token\":\" '{printf $2}' | awk -F \" '{printf $1}'`

# CALL_INFO "Established API Connection to Cimitra Server"
}

function CREATE_PAIRED_CIMITRA_AGENT()
{

if [ $PROCEED_WITH_AGENT_INSTALL -ne 0 ]
then
return 1
fi

AGENT_NAME="${CIMITRA_AGENT_IN_UPPER}"

BASEURL="https://${CIMITRA_SERVER_ADDRESS}:${CIMITRA_SERVER_PORT}/api"
 
ENDPOINT="/agent" 

URL="${BASEURL}${ENDPOINT}" 

CALL_INFO "Creating a new Cimitra Agent by the name of: ${AGENT_NAME}"

JSON_TEMP_FILE_ONE="${TEMP_FILE_DIRECTORY}/$$.1.tmp.json"

THE_DESCRIPTION="Cimitra Agent Deployed to Server: ${AGENT_NAME}\nIf you need to install the agent again folllow these 4 Simple Steps\n1. Download the Cimitra Agent and put it on the Linux server: ${AGENT_NAME} \n2. Make the cimagent file executable: chmod +x ./cimagent\n3. Install the Cimitra Agent with the command: ./cimagent c\n4. Start the Cimitra Agent with the command: cimitra start"

echo "{
    \"name\": \"${AGENT_NAME}\",
    \"description\": \"${THE_DESCRIPTION}\",
    \"platform\": \"linux\",
    \"match_regex\":  \"node01\"
}" 1> ${JSON_TEMP_FILE_ONE} 


{
declare RESPONSE=`curl -k ${CURL_OUTPUT_MODE} -H 'Accept: application/json' \
-H "Authorization: Bearer ${CIMITRA_API_SESSION_TOKEN}" \
-X POST ${URL} -d @${JSON_TEMP_FILE_ONE}  \
-H "Content-Type: application/json"`
} 1> /dev/null 2> /dev/null

rm ${TEMP_FILE_DIRECTORY}/$$.tmp.agent.json 2> /dev/null

TEMP_FILE_ONE="${TEMP_FILE_DIRECTORY}/$$.1.tmp"

TEMP_FILE_TWO="${TEMP_FILE_DIRECTORY}/$$.2.tmp"

echo "$RESPONSE" 1> ${TEMP_FILE_ONE}

sed -e 's/[}"]*\(.\)[{"]*/\1/g;y/,/\n/' < ${TEMP_FILE_ONE} > ${TEMP_FILE_TWO}

declare -i ERROR_STATE=`cat ${TEMP_FILE_TWO} | grep -c "error"`

if [ $ERROR_STATE -gt 0 ]
then
rm ${TEMP_FILE_ONE} 2> /dev/null
rm ${TEMP_FILE_TWO} 2> /dev/null
return 1
fi

CALL_INFO "Created a new Cimitra Agent by the name of: ${AGENT_NAME}"


CIMITRA_PAIRED_AGENT_ID=`cat ${TEMP_FILE_TWO} | grep "_id:" | awk -F : '{printf $2}'`

rm ${TEMP_FILE_ONE} 2> /dev/null

rm ${TEMP_FILE_TWO} 2> /dev/null

}



function DOWNLOAD_AND_INSTALL_CIMITRA_AGENT()
{

if [ $PROCEED_WITH_AGENT_INSTALL -ne 0 ]
then
return
fi

CIMITRA_AGENT_BINARY_FILE="/usr/bin/cimagent"

declare -i CIMITRA_AGENT_INSTALLED=`test -f ${CIMITRA_AGENT_BINARY_FILE} ; echo $?`

# If an agent isn't installed....
if [ $CIMITRA_AGENT_INSTALLED -eq 1 ]
then

BASEURL="https://${CIMITRA_SERVER_ADDRESS}:${CIMITRA_SERVER_PORT}/api"
 
ENDPOINT="/agent" 

URL="${BASEURL}${ENDPOINT}" 

# Look for all agents
{
declare RESPONSE=`curl -k ${CURL_OUTPUT_MODE} -H 'Accept: application/json' \
-H "Authorization: Bearer ${CIMITRA_API_SESSION_TOKEN}" \
-X GET ${URL}`
} 1> /dev/null 2> /dev/null

TEMP_FILE_ONE="${TEMP_FILE_DIRECTORY}/$$.1.tmp"

TEMP_FILE_TWO="${TEMP_FILE_DIRECTORY}/$$.2.tmp"

echo "$RESPONSE" 1> ${TEMP_FILE_ONE}

sed -e 's/[}"]*\(.\)[{"]*/\1/g;y/,/\n/' < ${TEMP_FILE_ONE} > ${TEMP_FILE_TWO}

CIMITRA_AGENT_IN_SET=1

SERVER_HOSTNAME=`hostname`


	
	declare -i CIMITRA_AGENT_NAME_EXISTS=`cat ${TEMP_FILE_TWO} | grep -icw "name:${AGENT_NAME}"`

	if [ $CIMITRA_AGENT_NAME_EXISTS -gt 0 ]
	then
	CIMITRA_PAIRED_AGENT_ID=`cat ${TEMP_FILE_TWO} | grep -iwB 1 "name:${AGENT_NAME}" | head -1 | awk -F ":" '{printf $2}'`
	else
	CREATE_PAIRED_CIMITRA_AGENT
	fi		



fi

if [ $CIMITRA_AGENT_INSTALLED -eq 0 ]
then
# echo "AGENT IS INSTALLED...Let's keep checking"
# Determine if the installed Cimitra Agent is actually still registered in Cimitra


CIMITRA_AGENT_IN_SET=1
SERVER_HOSTNAME=`hostname`


CIMITRA_BINARY_AGENT_ID=`${CIMITRA_AGENT_BINARY_FILE} | grep -iA1 "agentid" | tail -1 | awk -F "= " '{printf $2}'`

BASEURL="https://${CIMITRA_SERVER_ADDRESS}:${CIMITRA_SERVER_PORT}/api"
 
ENDPOINT="/agent" 

URL="${BASEURL}${ENDPOINT}" 

{
declare RESPONSE=`curl -k ${CURL_OUTPUT_MODE} -H 'Accept: application/json' \
-H "Authorization: Bearer ${CIMITRA_API_SESSION_TOKEN}" \
-X GET ${URL}`
} 1> /dev/null 2> /dev/null

TEMP_FILE_ONE="${TEMP_FILE_DIRECTORY}/$$.1.tmp"

TEMP_FILE_TWO="${TEMP_FILE_DIRECTORY}/$$.2.tmp"

echo "$RESPONSE" 1> ${TEMP_FILE_ONE}

sed -e 's/[}"]*\(.\)[{"]*/\1/g;y/,/\n/' < ${TEMP_FILE_ONE} > ${TEMP_FILE_TWO}

SEARCH_FOR="${CIMITRA_BINARY_AGENT_ID}"

declare -i CIMITRA_AGENT_ID_EXISTS=`cat ${TEMP_FILE_TWO} | grep -icw "_id:${SEARCH_FOR}"`

# echo "CIMITRA_AGENT_ID_EXISTS = $CIMITRA_AGENT_ID_EXISTS"


	if [ $CIMITRA_AGENT_ID_EXISTS -gt 0 ]
	then
	CIMITRA_PAIRED_AGENT_ID=`cat ${TEMP_FILE_TWO} | grep -iw  "_id:${SEARCH_FOR}" | head -1 | awk -F ":" '{printf $2}'`
	CIMITRA_PAIRED_AGENT_NAME=`cat ${TEMP_FILE_TWO} | grep -A 1 ${SEARCH_FOR} | tail -1 | awk -F ":" '{printf $2}'`
	CIMITRA_PAIRED_AGENT_NAME_LOWER=`echo "${CIMITRA_PAIRED_AGENT_NAME}" | tr [A-Z] [a-z]`
	rm ${TEMP_FILE_ONE} 2> /dev/null
	rm ${TEMP_FILE_TWO} 2> /dev/null
	return 0

		
	else


		AGENT_NAME="${CIMITRA_AGENT_IN_UPPER}"


	declare -i CIMITRA_AGENT_NAME_EXISTS=`cat ${TEMP_FILE_TWO} | grep -icw "name:${AGENT_NAME}"`


		if [ $CIMITRA_AGENT_NAME_EXISTS -gt 0 ]
		then
			CIMITRA_PAIRED_AGENT_ID=`cat ${TEMP_FILE_TWO} | grep -iwB 1 "name:${AGENT_NAME}" | head -1 | awk -F ":" '{printf $2}'`
		else
			echo ""
			echo "Process: Replacing the existing Cimitra Agent"
			echo ""
			rm ${TEMP_FILE_ONE} 2> /dev/null
			rm ${TEMP_FILE_TWO} 2> /dev/null
			CREATE_PAIRED_CIMITRA_AGENT
		fi		


	fi

fi

rm ${TEMP_FILE_ONE} 2> /dev/null

rm ${TEMP_FILE_TWO} 2> /dev/null

DATA="{\"host\": \"${CIMITRA_SERVER_ADDRESS}\",\"port\": \"${CIMITRA_SERVER_PORT}\",\"root\": \"/api\",\"arch\": \"x64\"}" 

BASEURL="https://${CIMITRA_SERVER_ADDRESS}:${CIMITRA_SERVER_PORT}/api"

ENDPOINT="/agent/${CIMITRA_PAIRED_AGENT_ID}/download"

URL="${BASEURL}${ENDPOINT}" 

CIMAGENT_FILE="${TEMP_FILE_DIRECTORY}/cimagent"

# echo "CIMITRA_PAIRED_AGENT_ID = $CIMITRA_PAIRED_AGENT_ID"

# echo "DATA = $DATA"


rm ${CIMAGENT_FILE} 2> /dev/null

echo ""
echo "Process: Downloading the Cimitra Agent File (this may take a little bit...)"
echo ""
echo "-----------------------------------------------------------------------------"
echo ""

curl -k  \
-H "Accept: application/json" \
-H "Authorization: Bearer ${CIMITRA_API_SESSION_TOKEN}" \
-H "Cache-Control: no-cache" \
-X POST ${URL} \
-H "Content-Type: application/json" \
--data "${DATA}" -o ${CIMAGENT_FILE} 

echo ""
echo "-----------------------------------------------------------------------------"


declare -i CIMAGENT_FILE_EXISTS=`test -f ${CIMAGENT_FILE} ; echo $?`

if [ $CIMAGENT_FILE_EXISTS -ne 0 ]
then
echo ""
echo "Note: Could not Download the Cimitra Agent File"
return
fi

chmod +x ${CIMAGENT_FILE}

cd ${TEMP_FILE_DIRECTORY}

./cimagent 1> /dev/null 2> /dev/null 

DOWNLOAD_FILE_STATE=`echo $?`

if [ $DOWNLOAD_FILE_STATE -ne 0 ]
then

rm ${CIMAGENT_FILE} 2> /dev/null

echo ""
echo "Error: The Cimitra Agent Could Not Be Downloaded"
echo ""
echo "NOTE: Generally this means that the server that hosts..."
echo ""
echo "... the Cimitra Server Docker Image needs more memory allocated"
echo ""
return 1

BASEURL="http://${CIMITRA_SERVER_API_ADDRESS}:${CIMITRA_SERVER_API_PORT}"

URL="${BASEURL}${ENDPOINT}" 

echo ""
echo "Process: Downloading the Cimitra Agent File (this may take a little bit...)"
echo ""
echo "-----------------------------------------------------------------------------"
echo ""

curl -k  \
-H "Authorization: Bearer ${CIMITRA_API_SESSION_TOKEN}" \
-X POST ${URL} \
-H "Content-Type: application/json" \
--data "${DATA}" -o ${CIMAGENT_FILE} 

echo ""
echo "-----------------------------------------------------------------------------"

else
echo ""
echo "Success: Downloaded the Cimitra Agent File"

fi

chmod +x ${CIMAGENT_FILE}

./cimagent 1> /dev/null 2> /dev/null 

DOWNLOAD_FILE_STATE=`echo $?`

if [ $DOWNLOAD_FILE_STATE -eq 0 ]
then
./cimagent c

{
cimitra stop 2> /dev/null 
cimitra start  &
} 1> /dev/null 2> /dev/null
else
echo ""
echo "Note: Could not Download the Cimitra Agent File"
echo ""
echo "Task: You may need to Download the Cimitra Agent"
echo ""
fi

}

function LOOK_FOR_GROUPWISE()
{

{
rcgrpwise 1> /dev/null 2> /dev/null
} 1> /dev/null 2> /dev/null

declare -i GRPWISE_EXISTS=`echo $?`

if [ $GRPWISE_EXISTS -lt 3 ]
then
cd /tmp
{
curl -LJO https://raw.githubusercontent.com/cimitrasoftware/groupwise/master/install -o ./ 1> /dev/null 2> /dev/null 
} 1> /dev/null 2> /dev/null

chmod +x ./install 
./install

fi
}


function main()
{

CONFIRM_OR_INSTALL_DOCKER
CONFIRM_OR_INSTALL_DOCKER_COMPOSE
DOWNLOAD_CIMITRA_YAML_FILE
START_CIMITRA_DOCKER_CONTAINER

CONNECT_TEST

PROCEED_WITH_AGENT_INSTALL=`echo $1`

if [ $PROCEED_WITH_AGENT_INSTALL -ne 0 ]
then
return
fi

ESTABLISH_CIMITRA_API_SESSION

if [ $PROCEED_WITH_AGENT_INSTALL -ne 0 ]
then
return
fi

DOWNLOAD_AND_INSTALL_CIMITRA_AGENT

if [ $PROCEED_WITH_AGENT_INSTALL -ne 0 ]
then
return
fi

{
cimitra restart & 1> /dev/null 2> /dev/null &
} 1> /dev/null 2> /dev/null 

{
cimitra get import & 1> /dev/null 2> /dev/null &
} 1> /dev/null 2> /dev/null 

LOOK_FOR_GROUPWISE

}

function STOP_CIMITRA_DOCKER_CONTAINER()
{
CALL_INFO "Removing Cimitra Server Docker Container"

cd ${CIMITRA_SERVER_DIRECTORY}

docker-compose down

DOCKER_UP_STATUS=`echo $?`

if [ $DOCKER_UP_STATUS -ne 0 ]
then
CALL_ERROR_EXIT "Cannot Remove the Cimitra Server Docker Container"
fi

CALL_INFO "The Cimitra Server Docker Container Was Successfully Removed"

}

function REMOVE_DOCKER()
{

DOCKER_UNINSTALL_COMMAND="sudo zypper -n rm docker"

${DOCKER_UNINSTALL_COMMAND}

}

function REMOVE_CIMITRA_DOCKER_COMPONENTS()
{

declare -i CIMITRA_WEB_IMAGE_EXISTS=`docker images -a | grep "cimitra/web" | wc -m`

if [ $CIMITRA_WEB_IMAGE_EXISTS -gt 2 ]
then
CIMITRA_WEB_IMAGE=`docker images -a | grep "cimitra/web" | awk '{printf $3}'`
CALL_INFO "Removing Cimitra Web Client Docker Image"
docker rmi ${CIMITRA_WEB_IMAGE}
fi

declare -i CIMITRA_SERVER_IMAGE_EXISTS=`docker images -a | grep "cimitra/server" | wc -m`

if [ $CIMITRA_SERVER_IMAGE_EXISTS -gt 2 ]
then
CIMITRA_SERVER_IMAGE=`docker images -a | grep "cimitra/server" | awk '{printf $3}'`
CALL_INFO "Removing Cimitra Server Docker Image"
docker rmi ${CIMITRA_SERVER_IMAGE}
fi

}


function REMOVE_ALL_COMPONENTS()
{

{
cimitra stop & 1> /dev/null 2> /dev/null &
} 1> /dev/null 2> /dev/null 

STOP_CIMITRA_DOCKER_CONTAINER

REMOVE_CIMITRA_DOCKER_COMPONENTS

REMOVE_DOCKER

CALL_INFO "Successfully Uninstalled Cimitra and Supporting Components"
}

if [ $UNINSTALL -eq 0 ]
then
main
else
REMOVE_ALL_COMPONENTS
fi


