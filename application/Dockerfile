FROM node:15.9.0-alpine
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "tsconfig.json*", "./"]
RUN npm install 
COPY . .
EXPOSE 3000
RUN chown -R node /usr/src/app
USER node
CMD ["npm", "start"]
