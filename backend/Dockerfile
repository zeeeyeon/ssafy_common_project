FROM openjdk:17
ARG JAR_FILE=build/libs/backend-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} /app.jar
COPY ./config/application.yml /config/application.yml
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar", "spring.config.location=file:/config/application.yml"]