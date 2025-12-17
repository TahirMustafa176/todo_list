# MongoDB Dockerfile (Custom - for reference)
# In production, use official mongo image: mongo:latest

FROM mongo:latest

# Set environment variables
ENV MONGO_INITDB_DATABASE=todo_list_db

# Expose MongoDB port
EXPOSE 27017

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD echo 'db.runCommand("ping").ok' | mongosh localhost:27017/test --quiet

# Use default MongoDB entrypoint
CMD ["mongod"]
