FROM mcr.microsoft.com/openjdk/jdk:17-ubuntu
# RUN addgroup -S spring && adduser -S spring -G spring
# USER spring:spring
# FROM mcr.microsoft.com/openjdk/jdk:17-distroless
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
COPY applicationinsights.json applicationinsights.json
# COPY src/main/resources/applicationinsights-agent-illuminate-3.3.1.jar applicationinsights-agent-illuminate-3.3.1.jar
# ENTRYPOINT ["java","-javaagent:applicationinsights-agent-illuminate-3.3.1.jar","-jar","/app.jar"]
COPY applicationinsights-agent-3.3.1.jar applicationinsights-agent-3.3.1.jar
ENTRYPOINT ["java","-javaagent:applicationinsights-agent-3.3.1.jar","-jar","/app.jar"]