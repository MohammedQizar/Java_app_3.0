FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY ./target/*.jar /app.war
CMD ["java", "-jar", "/app.war"]
