#FROM public.ecr.aws/amazoncorretto/amazoncorretto:17-al2-native-jdk
#amazoncorretto:17.0.14

# Set the working directory in the container
#WORKDIR /app

# Copy the JAR file into the Docker image #your-artifact.jar
#COPY java-artifact.jar /app/java-artifact.jar

#EXPOSE 8080 

# Run the JAR file as the main command
#CMD ["java", "-Dserver.port=8080", "-jar", "/app/java-artifact.jar"]



FROM public.ecr.aws/nginx/nginx:1.26

# Copy custom configuration file (optional)
# COPY default.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for HTTP traffic.
EXPOSE 80

# Start Nginx in the foreground.
CMD ["nginx", "-g", "daemon off;"]