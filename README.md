# Couchdb Self-Hosted

Self-hosted Obsidian setup with live-sync functionality using Docker. This setup provides a complete solution for running Obsidian with synchronization capabilities across multiple devices.

## Quick Start

1. Clone this repository
2. Run the setup command:
   ```bash
   make setup
   ```
3. Edit `.env` file with your desired configuration
4. Start services:
   ```bash
   make up
   ```

## Architecture

### Services
- **CouchDB**: Database backend for Obsidian LiveSync plugin

### Volumes
- `couchdb_data`: CouchDB database files
- `couchdb_config`: CouchDB configuration

### Default Ports
- CouchDB: `5984`

## Configuration

Configuration is managed through the `.env` file. Copy `.env.example` to `.env` and modify as needed:

```bash
cp .env.example .env
```

Key configuration options:
- `COUCHDB_USER`: Admin username for CouchDB
- `COUCHDB_PASSWORD`: Admin password for CouchDB
- `COUCHDB_PORT`: Port for CouchDB (default: 5984)
- `DATABASE_NAME`: Name for Obsidian database (default: obsidiandb)
- `COUCHDB_EXTERNAL_DOMAIN`: External domain for reverse proxy access (e.g., `https://couchdb.your-domain.com`)

## Development Setup

### Prerequisites
- Docker
- Docker Compose
- Make (optional, but recommended)

### Getting Started

1. **Clone and setup:**
   ```bash
   git clone <repository-url>
   cd couchdb-self-hosted
   make setup
   ```

2. **Configure environment:**
   Edit `.env` file with your preferences

3. **Start development environment:**
   ```bash
   make dev
   ```

## Available Commands

Run `make help` to see all available commands for managing the Docker services.

## Usage

### First Time Setup

1. Start services: `make up`
2. Configure CouchDB: `make setup-couchdb`
3. Configure Obsidian LiveSync plugin in your Obsidian desktop/mobile app

The `make setup-couchdb` command will:
- Wait for CouchDB to be ready
- Setup CouchDB as single node
- Create the database (default: `obsidiandb`)
- Apply all required configuration for Obsidian LiveSync
- Verify the installation

### Obsidian LiveSync Configuration

Configure the LiveSync plugin with:
- **Database URL**: `http://localhost:5984` (local) or your `COUCHDB_EXTERNAL_DOMAIN` (remote)
- **Database name**: `obsidiandb` (or as configured in `.env`)
- **Username/Password**: As configured in `.env`

### External Access via Reverse Proxy

For external access using reverse proxy setup:

1. Set `COUCHDB_EXTERNAL_DOMAIN` in `.env` to your external domain
2. Configure reverse proxy following [jirigrill/reverse-proxy-setup](https://github.com/jirigrill/reverse-proxy-setup)
3. Run `make setup-couchdb` to configure CORS for external access
4. Use the external domain in Obsidian LiveSync configuration

## Backup and Recovery

### Creating Backups
```bash
make backup
```
Backups are stored in the `backups/` directory with timestamps.

### Restoring from Backup
To restore from a backup, stop services and restore the volumes:
```bash
make down
# Extract backup files to appropriate volume locations
make up
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Check if port 5984 is already in use
2. **Permission issues**: Ensure Docker has proper permissions
3. **Volume mounting**: Check that volume paths exist and are accessible

### Viewing Logs
```bash
# All services
make logs

# Specific service
make logs-couchdb
```

### Resetting Everything
If you encounter persistent issues:
```bash
make reset
```
**Warning**: This removes all data and configurations.