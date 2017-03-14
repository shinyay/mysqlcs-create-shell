#!/bin/bash
# usage
cmdname=`basename $0`
function usage() {
cat << EOT
Usage:
  ${cmdname} [-t TEMPLATE] SERVICE-NAME MYSQL-PWD [DESCRIPTION]

Template:
1: (DEFAULT) Just Database
2: Database with Enterprise Monitor

Description:
  SERVICE-NAME: MySQL CS Service Instance Name
  MYSQL-PWD:    MySQL DB User(root) Password
  DESCRIPTION:  MySQL CS Description
EOT
exit 1
}

# check options
while getopts t: option
do
  case ${option} in
    t)
      TEMPLATE_OPT=${OPTARG}
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

# check arguments
if [ -z $1 ] || [ -z $2 ]; then
  usage
  exit 1
fi
if [ -z $3 ]; then
  SERVICE_DESC="My SQLCS"
else
  SERVICE_DESC=$3
fi

SERVICE_NAME=$1
MYSQL_PWD=$2
SSH_KEY="`cat ~/.ssh/id_rsa.pub`"
case ${TEMPLATE_OPT} in
  "1" ) TEMPLATE="template/mysqlcs-entry-template.json" ;;
  "2" ) TEMPLATE="template/mysqlcs-entry-with-monitor-template.json" ;;
  * ) TEMPLATE="template/mysqlcs-entry-template.json" ;;
esac
CURRENT_TIME=`date '+%y%m%d-%H%M%S'`

if [ ! -e ./json ]; then mkdir json ; fi

sed -e "s#SSH_KEY#${SSH_KEY}#g" ${TEMPLATE} | \
sed -e "s#SERVICE_NAME#${SERVICE_NAME}#g" | \
sed -e "s#MYSQL_PWD#${MYSQL_PWD}#g" | \
sed -e "s#SERVICE_DESC#${SERVICE_DESC}#g" > json/mysqlcs-entry-${CURRENT_TIME}.json


# main
echo "SERVICE-NAME=[${SERVICE_NAME}], MYSQL-PWD=[${MYSQL_PWD}], DESCRIPTION=[${SERVICE_DESC}]"
psm mysqlcs create-service -c json/mysqlcs-entry-${CURRENT_TIME}.json
exit 0
