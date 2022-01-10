FROM node:10 AS build
WORKDIR /app/src
COPY . .
RUN apt-get update -y && apt-get install -y zip
RUN zip -9 -r Pong2D.love ./classes ./fonts ./includes ./sounds main.lua
RUN npm install -g love.js
RUN love.js -c Pong2D.love /app/dist --title "Pong2D" --verbose

FROM nginx:1.17.0-alpine
COPY --from=build /app/dist /usr/share/nginx/html