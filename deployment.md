# Kamal Deployment Steps

## Issue with Environment Variables
Kamal doesn't automatically load `.env` files. You need to export the environment variables before running Kamal commands.

## Deployment Steps

### 1. Load Environment Variables
```bash
# Load environment variables from .env file
export $(grep -v '^#' .env | grep -v '^$' | xargs)
```

### 2. Verify Environment Variables
```bash
# Check if variables are loaded
echo "REGISTRY_PASSWORD: ${REGISTRY_PASSWORD}"
echo "KAMAL_REGISTRY_PASSWORD: ${KAMAL_REGISTRY_PASSWORD}"
```

### 3. Test Secrets Loading
```bash
# Test if secrets file can access the variables
source .kamal/secrets
echo "KAMAL_REGISTRY_PASSWORD from secrets: ${KAMAL_REGISTRY_PASSWORD}"
```

### 4. Run Kamal Setup
```bash
# Run kamal setup with environment variables loaded
kamal setup
```

### 5. Alternative: One-liner Setup
```bash
# Load env and run kamal setup in one command
export $(grep -v '^#' .env | grep -v '^$' | xargs) && kamal setup
```

## Future Deployments
For regular deployments after setup:
```bash
# Load environment variables and deploy
export $(grep -v '^#' .env | grep -v '^$' | xargs) && kamal deploy
```

## Quick Commands Reference
```bash
# Load env variables (run this first)
export $(grep -v '^#' .env | grep -v '^$' | xargs)

# Then run any kamal command
kamal setup
kamal deploy
kamal app logs
kamal accessory logs db
```

## Troubleshooting

### Docker Registry Login Error
- If you get "flag needs an argument: 'p'" error, it means REGISTRY_PASSWORD is not loaded
- Always load environment variables before running Kamal commands

### Docker Buildx Cgroup Error
If you get "cgroup-parent for systemd cgroup should be a valid slice named as xxx.slice" error:

**Option 1: Configure Kamal to use default builder**
```bash
# Edit deploy.yml to use default builder
# Add this to your deploy.yml under builder section:
# builder:
#   multiarch: false
#   cache:
#     type: gha
```

**Option 2: Fix the buildx builder**
```bash
# Remove any existing kamal builders
docker buildx ls | grep kamal | cut -d' ' -f1 | xargs -r docker buildx rm

# Create new builder without cgroup issues
docker buildx create --name kamal-local-docker-container --driver docker-container --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760 --buildkitd-flags='--allow-insecure-entitlement security.insecure --allow-insecure-entitlement network.host'
```

**Option 3: Use local builder (simplest)**
```bash
# Force Kamal to use local builder by removing all docker-container builders
docker buildx ls | grep docker-container | cut -d' ' -f1 | xargs -r docker buildx rm
```

Then retry the deployment.

### General Troubleshooting
- Commit your changes before deployment (Kamal builds from git)
- Make sure Docker is running on your local machine
- Ensure you have proper SSH access to the server