FROM openjdk:17-jre-slim

# Set the working directory in the container
WORKDIR /app

# Copy the JAR file into the Docker image
COPY *.jar /app/ #your-artifact.jar

EXPOSE 8080

# Run the JAR file as the main command
CMD ["java", "-Dserver.port=8080", "-jar", "/app/your-artifact.jar"]
