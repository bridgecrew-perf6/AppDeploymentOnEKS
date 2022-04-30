FROM nginx

COPY /weatherfiles/.  /usr/share/nginx/html/

EXPOSE 80
