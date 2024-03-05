# Stage 1: Build the Spring Boot JAR
FROM maven:3.8.3-openjdk-11 AS build
WORKDIR /app

# Copy the project's POM file and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline
# Copy the source code and build the JAR
COPY src /app/src
RUN mvn clean verify sonar:sonar -Dsonar.projectKey=${bamboo.sonarProjectKey} -Dsonar.host.url=${bamboo.sonarHostUrl} -Dsonar.login=${bamboo.sonarLoginToken} -DskipTests

# Stage 2: Create the final image with the built JAR
FROM openjdk:11-jre-slim
WORKDIR /app

# Copy the built JAR from the build stage
COPY --from=build /app/target/*-SNAPSHOT.jar app.jar

# Expose the port that the Spring Boot app will run on
EXPOSE 8080

# Specify the command to run the Spring Boot application
CMD ["java", "-jar", "app.jar"]
