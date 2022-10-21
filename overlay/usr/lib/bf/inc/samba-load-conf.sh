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

JSON=`cat ${SAMBA_SHARES_CONF} | jq '.'`

declare -a SAMBA_USERS=(`jq -r '.users[].name' <<< "${JSON}"`)
declare -a SAMBA_SHARES=(`jq -r '.shares[].name' <<< "${JSON}"`)


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
function get-users() { get-share "${1}" | jq -r '.users? | join(" ")' ; }
function get-browseable() { get-share "${1}" | jq -r 'if .browseable == false then "no" else "yes" end' ; }
function get-writeable() { get-share "${1}" | jq -r 'if .writeable == false then "no" else "yes" end' ; }
