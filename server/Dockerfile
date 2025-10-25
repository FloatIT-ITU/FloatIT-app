FROM node:18-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
# Install production dependencies using npm ci for reproducibility
RUN npm ci --omit=dev --no-audit --no-fund
COPY . .
EXPOSE 5454
CMD ["npm", "start"]