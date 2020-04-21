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
$ZCLI farm create -farmname $FARMNAME -vip $IP -vport $PORT_INI -profile $PROFILE

echo "setting a farm"
$ZCLI farm set $FARMNAME -vport $PORT -listener $LISTENER

echo "creating a service"
$ZCLI farm-service add $FARMNAME -id $SERVICE_NAME

echo "setting a service"
$ZCLI farm-service set $FARMNAME $SERVICE_NAME -vhost $VIRTUAL_HOST -persistence $PERSISTENCE

echo "creating a backend"
$ZCLI farm-service-backend add $FARMNAME $SERVICE_NAME -ip $BAKEND_IP_INI -port $BAKEND_PORT_INI

echo "setting a backend"
$ZCLI farm-service-backend set $FARMNAME $SERVICE_NAME $BACKEND_ID -ip $BAKEND_IP -port $BAKEND_PORT

echo "restarting a farm"
$ZCLI farm restart $FARMNAME

echo "stopping a farm"
$ZCLI farm stop $FARMNAME

echo "starting a farm"
$ZCLI farm start $FARMNAME

echo "deleting a backend"
$ZCLI farm-service-backend delete $FARMNAME $SERVICE_NAME $BACKEND_ID

echo "deleting a service"
$ZCLI farm-service delete $FARMNAME $SERVICE_NAME

echo "deleting a farm"
$ZCLI farm delete $FARMNAME