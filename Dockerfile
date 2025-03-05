FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY ./target/*.war /app.war
CMD ["java", "-war", "/app.war"]
