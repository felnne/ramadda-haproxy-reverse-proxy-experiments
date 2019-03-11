FROM unidata/tomcat-docker:8.5

USER root
WORKDIR /data/repository

RUN curl -SL \
# using custom build with HTTP headers for debugging
https://geodesystems.com/repository/entry/get/repository.war?entryid=synth%3A498644e1-20e4-426a-838b-65cffe8bd66f%3AL3JhbWFkZGFfMi4zL3JlcG9zaXRvcnkud2Fy \
-o ${CATALINA_HOME}/webapps/repository.war

ENV JAVA_OPTS="-server -d64 -Xms512m -Xmx4G -Dorg.apache.catalina.security.SecurityListener.UMASK=0007 -Dramadda_home=/data/repository -Dfile.encoding=utf-8"
ENV CATALINA_OPTS="-Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true"
RUN trap "echo TRAPed signal" HUP INT QUIT KILL TERM

COPY docker/startram.sh docker/startram.sh /usr/local/tomcat/bin/
COPY docker/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD /usr/local/tomcat/bin/startram.sh
