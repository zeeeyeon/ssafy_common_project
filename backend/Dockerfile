FROM openjdk:17
RUN ln -snf /usr/share/zoneinfo/Asia/Seoul /etc/localtime && echo Asia/Seoul > /etc/timezone
ARG JAR_FILE=build/libs/*.jar
COPY ${JAR_FILE} /app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar", "-Dspring.profiles.active=dev", "-Duser.timezone=Asia/Seoul"]