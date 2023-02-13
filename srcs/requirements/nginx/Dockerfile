FROM alpine:3.16

# Update package and install nginx without save sources in the cache
RUN apk update && apk upgrade && apk add --no-cache nginx

# Port 
EXPOSE 443

# Execute the configuration
# daemon make it run in the background
CMD ["nginx", "-g", "daemon off;"]


