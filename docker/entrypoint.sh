#!/bin/bash
set -e

if [ "$1" = 'startram.sh' ]; then
    USER_ID=${TOMCAT_USER_ID:-1000}
    GROUP_ID=${TOMCAT_GROUP_ID:-1000}

    groupadd -r tomcat -g ${GROUP_ID} && \
    useradd -u ${USER_ID} -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin \
        -c "Tomcat user" tomcat
    
    ###
    # Change CATALINA_HOME ownership to tomcat user and tomcat group
    # Restrict permissions on conf
    # Ensure RAMADDA data directory is owned by tomcat
    ###
    chown -R tomcat:tomcat ${CATALINA_HOME} && \
    chown -R tomcat:tomcat /data/repository && \
    chmod 400 ${CATALINA_HOME}/conf/*
    sync
    exec gosu tomcat "$@"
fi

exec "$@"
