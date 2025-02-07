FROM public.ecr.aws/amazoncorretto/amazoncorretto:17-al2-native-jdk
#amazoncorretto:17.0.14

# Set the working directory in the container
WORKDIR /app

# Copy the JAR file into the Docker image #your-artifact.jar
COPY java-artifact.jar /app/java-artifact.jar

EXPOSE 8080 

# Run the JAR file as the main command
CMD ["java", "-Dserver.port=8080", "-jar", "/app/java-artifact.jar"]
