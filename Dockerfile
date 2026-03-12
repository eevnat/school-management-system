FROM tomcat:10-jdk17

# remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# copy WAR
COPY studentcardgenerator.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080