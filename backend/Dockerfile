FROM openjdk:17
ARG JAR_FILE=build/libs/backend-0.0.1-SNAPSHOT.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
COPY ${JAR_FILE} /app.jar
