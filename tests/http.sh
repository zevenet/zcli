#!/bin/bash

source "tests_includes.sh"

# Define the farm
# IP  is defined in tests_includes
PORT_INI="81"
PORT="80"
PROFILE="http"
FARMNAME="http-example"
LISTENER="https"

# Define the service 
SERVICE_NAME="service-example"
VIRTUAL_HOST="www.example.domain"
PERSISTENCE="IP"

# Define the backend
BACKEND_ID="0"
BAKEND_IP_INI="192.168.100.253"
BAKEND_PORT_INI="81"
BAKEND_IP="192.168.100.254"
BAKEND_PORT="80"


# Launching tests

echo "creating a farm"
$ZCLI farms create -farmname $FARMNAME -vip $IP -vport $PORT_INI -profile $PROFILE

echo "setting a farm"
$ZCLI farms set $FARMNAME -vport $PORT -listener $LISTENER

echo "creating a service"
$ZCLI farms-services create $FARMNAME -id $SERVICE_NAME

echo "setting a service"
$ZCLI farms-services set $FARMNAME $SERVICE_NAME -vhost $VIRTUAL_HOST -persistence $PERSISTENCE

echo "creating a backend"
$ZCLI farms-services-backends create $FARMNAME $SERVICE_NAME -ip $BAKEND_IP_INI -port $BAKEND_PORT_INI

echo "setting a backend"
$ZCLI farms-services-backends set $FARMNAME $SERVICE_NAME $BACKEND_ID -ip $BAKEND_IP -port $BAKEND_PORT

echo "restarting a farm"
$ZCLI farms restart $FARMNAME

echo "stopping a farm"
$ZCLI farms stop $FARMNAME

echo "starting a farm"
$ZCLI farms start $FARMNAME

echo "deleting a backend"
$ZCLI farms-services-backends delete $FARMNAME $SERVICE_NAME $BACKEND_ID

echo "deleting a service"
$ZCLI farms-services delete $FARMNAME $SERVICE_NAME

echo "deleting a farm"
$ZCLI farms delete $FARMNAME