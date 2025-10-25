FROM node:18-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
# Use npm install when package-lock.json may be missing in the build context.
# npm ci requires a lockfile; CI runners that build from source should be resilient
# so we install production deps while omitting devDependencies.
RUN npm install --omit=dev --no-audit --no-fund
COPY . .
EXPOSE 5454
CMD ["npm", "start"]