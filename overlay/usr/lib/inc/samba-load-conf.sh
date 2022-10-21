#!/bin/bash


#======================================================================================================================
# Check JSON configuration file exists.
#======================================================================================================================

if [ ! -f "${SAMBA_SHARES_CONF}" ] ; then
    bf-error "You must create ${SAMBA_SHARES_CONF} - see samba-conf-sample.json." "inc/samba-load-conf.sh"
    exit 1
fi


#======================================================================================================================
# Load JSON and create USERS and SHARES arrays.
#======================================================================================================================

JSON=`cat "${SAMBA_SHARES_CONF}" | jq '.'`

declare -a USERS=(`jq -r '.users[].name' <<< "${JSON}"`)
declare -a SHARES=(`jq -r '.shares[].name' <<< "${JSON}"`)


#======================================================================================================================
# Gets an object from the JSON configuration.
#
# Arguments
#   1   User or share name to select
#======================================================================================================================

function get-user() { jq --arg NAME "${1}" '.users[] | select(.name == $NAME)' <<< "${JSON}" ; }
function get-share() { jq --arg NAME "${1}" '.shares[] | select(.name == $NAME)' <<< "${JSON}" ; }

function get-pass() { get-user "${1}" | jq -r '.pass' ; }
function get-comment() { get-share "${1}" | jq -r '.comment?' ; }
function get-users() { get-share "${1}" | jq -r '.users[]?' ; }
function get-browsable() { get-share "${1}" | jq -r '.browsable == true' ; }
function get-writable() { get-share "${1}" | jq -r '.writable == true' ; }
