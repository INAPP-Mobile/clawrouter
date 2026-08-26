FROM node:22-slim

# Install dependencies for node modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install ClawRouter globally
RUN npm install -g @blockrun/clawrouter

# Create non-root user
RUN useradd -m -s /bin/bash clawrouter

# Volume for persistent wallet + config
VOLUME /home/clawrouter/.openclaw/blockrun

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/v1/models || exit 1

# Switch to non-root user
USER clawrouter
WORKDIR /home/clawrouter

# Setup and run
CMD sh -c "clawrouter setup --yes && clawrouter --port ${PORT:-8080}"
