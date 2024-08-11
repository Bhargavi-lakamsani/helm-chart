# Use the official Nginx image from Docker Hub
FROM nginx:latest

# Copy custom Nginx configuration file
COPY config/nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

