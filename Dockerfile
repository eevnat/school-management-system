FROM tomcat:10-jdk17

COPY studentcardgenerator.war /usr/local/tomcat/webapps/

EXPOSE 8080