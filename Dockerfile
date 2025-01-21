# Stage 1: Build Stage
FROM node:18.12.0-alpine as build

WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./
RUN yarn install

# Copy source code
COPY . .

# Build the application
RUN yarn build

# Stage 2: Production Stage
FROM nginx:1.19.9-alpine

# Install Node.js 18
RUN apk add --update nodejs npm
RUN npm i -g yarn@1.22.22

WORKDIR /app

# Copy built files from build stage
COPY --from=build /app/dist /usr/share/nginx/html
COPY *.js .
COPY *.json .
COPY src /app/src

RUN yarn install

COPY --chown=nginx nginx.conf.template /etc/nginx/conf.d/default.conf
COPY rebuild.sh rebuild.sh

CMD './rebuild.sh'