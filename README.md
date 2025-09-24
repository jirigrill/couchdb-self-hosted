# Obsidian Self-Hosted

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
- **Obsidian Web**: Web-based Obsidian interface (optional)

### Volumes
- `couchdb_data`: CouchDB database files
- `couchdb_config`: CouchDB configuration
- `obsidian_vaults`: Obsidian vault files
- `obsidian_config`: Obsidian configuration

### Default Ports
- CouchDB: `5984`
- Obsidian Web Interface: `8080`

## Configuration

Configuration is managed through the `.env` file. Copy `.env.example` to `.env` and modify as needed:

```bash
cp .env.example .env
```

Key configuration options:
- Database credentials
- Port mappings
- Volume paths

## Development Setup

### Prerequisites
- Docker
- Docker Compose
- Make (optional, but recommended)

### Getting Started

1. **Clone and setup:**
   ```bash
   git clone <repository-url>
   cd obsidian-self-hosted
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
2. Access CouchDB admin interface: http://localhost:5984/_utils
3. Configure Obsidian LiveSync plugin to connect to your CouchDB instance
4. (Optional) Access web Obsidian interface: http://localhost:8080

### Obsidian LiveSync Configuration

Configure the LiveSync plugin with:
- **Database URL**: `http://localhost:5984`
- **Database name**: Your chosen database name
- **Username/Password**: As configured in `.env`

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

1. **Port conflicts**: Check if ports 5984 or 8080 are already in use
2. **Permission issues**: Ensure Docker has proper permissions
3. **Volume mounting**: Check that volume paths exist and are accessible

### Viewing Logs
```bash
# All services
make logs

# Specific service
make logs-couchdb
make logs-obsidian
```

### Resetting Everything
If you encounter persistent issues:
```bash
make reset
```
**Warning**: This removes all data and configurations.