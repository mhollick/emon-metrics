#!/bin/bash

# Don't really need to redefine these - but I find it easier to keep
# track of variables this way. Feel free to burn this bit.
readonly S_EMAIL_USER=${EMAIL_USER}
readonly S_EMAIL_PASS=${EMAIL_PASS}
readonly S_EMAIL_ALERT_ADDR=${EMAIL_ALERT_ADDR}
readonly S_EMAIL_HOST=${EMAIL_HOST}
readonly S_CENTRAL_METRICS_SERVER=${CENTRAL_METRICS_SERVER}
readonly S_CARBON_LOCAL_RETENTION=${CARBON_LOCAL_RETENTION}
readonly S_CARBON_CENTRAL_RETENTION=${CARBON_CENTRAL_RETENTION}
readonly S_SYSLOG_HOST=${SYSLOG_HOST}
readonly S_HOSTING=${HOSTING}
readonly S_LOCATION=${LOCATION}
readonly S_SERVICE=${SERVICE}
readonly S_ENVIRONMENT=${ENVIRONMENT}
readonly S_GA_API_EMAIL_ADDRESS=${GA_API_EMAIL_ADDRESS}
readonly S_GA_API_VIEW_ID=${GA_API_VIEW_ID}
readonly S_GA_API_FRIENDLY_NAME=${GA_API_FRIENDLY_NAME}

config_postfix () {
    #Configure postfix email relay to send all
    #emails through Amazon EMAIL to a single user
    local user=$1
    local pass=$2
    local address=$3
    local server=$4
    echo "${server} ${user}:${pass}" >> /etc/postfix/sasl_passwd
    echo "/.+@.+/ ${address}" > /etc/postfix/virtual-regexp
    postmap /etc/postfix/virtual-regexp
    postfix set-permissions
}

config_relay () {
    #Configure carbon c relay
    #send metrics to local server and optionally through to a central
    #metrics server. If none is defined, or if the variable passed is 'none'
    #then the forwarding configuration element is removed.
    local server=$1
    local hosting=$2
    local environment=$3
    local service=$4
    if [ -n "${server}" -a "${server}x" != "nonex" ]; then
        ln -s /etc/relay_with-central-server.conf /etc/relay.conf
        sed -i "s/__FORWARD_TO__/${server}/g" /etc/relay.conf
    else
        ln -s /etc/relay_local-only.conf /etc/relay.conf
    fi
    sed -i "s/__HOSTING__/${hosting}/g" /etc/relay.conf
    sed -i "s/__ENVIRONMENT__/${environment}/g" /etc/relay.conf
    sed -i "s/__SERVICE__/${service}/g" /etc/relay.conf
}

config_go_carbon () {
    #Configure go-carbon
    #See the storage-schemas.conf file for a better idea of what is happening here.
    local local_retention=$1
    local central_retention=$2
    local hosting=$3
    sed -i "s/__CENTRAL_RETENTION__/${central_retention}/g" /etc/storage-schemas.conf
    sed -i "s/__LOCAL_RETENTION__/${local_retention}/g" /etc/storage-schemas.conf
    sed -i "s/__HOSTING__/${hosting}/g" /etc/storage-schemas.conf /etc/storage-aggregation.conf
    mkdir /data/whisper
    chown carbon:carbon /data/whisper
}

config_graphite_api () {
    # Placeholder - no customisation here yet
    return 0
}

config_monit () {
    mkdir /data/monit
}

config_nginx () {
    # Placeholder - Nginx reverse authenticating proxy not implemented yet
    return 0
}

# Not bothering with a main function - cant see that it will add
# legibility 
config_postfix ${S_EMAIL_USER} ${S_EMAIL_PASS} ${S_EMAIL_ALERT_ADDR} ${S_EMAIL_HOST}
config_relay ${S_CENTRAL_METRICS_SERVER} ${S_HOSTING} ${S_ENVIRONMENT} ${S_SERVICE}
config_go_carbon ${S_CARBON_LOCAL_RETENTION} ${S_CARBON_CENTRAL_RETENTION} ${S_HOSTING}

/usr/bin/monit -c /etc/monitrc -I
