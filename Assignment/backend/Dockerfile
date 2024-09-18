# Dockerfile for Node.js API
FROM node:14
WORKDIR /app
COPY package.json /app/
RUN npm install
COPY . /app
CMD ["node", "server.js"]
EXPOSE 3001

