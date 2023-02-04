FROM node:18-alpine
RUN apk add --no-cache python3 g++ make
WORKDIR /usr/src/app

COPY package*.json .
RUN yarn install

ENV NODE_OPTIONS --openssl-legacy-provider
