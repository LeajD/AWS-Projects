FROM nginx:latest

# Copy custom static content to the NGINX html directory
COPY index.html /usr/share/nginx/html/

# Expose port 80 to the container
EXPOSE 80

# Run NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]