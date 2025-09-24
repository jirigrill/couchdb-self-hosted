# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Self-hosted Obsidian setup with live-sync functionality using Docker. The setup includes:
- CouchDB for Obsidian LiveSync plugin backend
- Optional web-based Obsidian interface
- Docker Compose orchestration

## Common Commands

### Docker Operations
- Start services: `docker-compose up -d`
- Stop services: `docker-compose down`
- View logs: `docker-compose logs -f`
- Restart services: `docker-compose restart`
- Update images: `docker-compose pull && docker-compose up -d`

### Configuration
- Environment variables are stored in `.env` file
- Modify `.env` to change ports, passwords, or other settings
- Default CouchDB runs on port 5984
- Default Obsidian web interface runs on port 8080

## Architecture Notes

### Services
- **couchdb**: Database backend for Obsidian LiveSync plugin
- **obsidian-web**: Web-based Obsidian interface (optional)

### Volumes
- `couchdb_data`: CouchDB database files
- `couchdb_config`: CouchDB configuration
- `obsidian_vaults`: Obsidian vault files
- `obsidian_config`: Obsidian configuration

### Setup Process
1. Configure `.env` with desired credentials and ports
2. Run `docker-compose up -d`
3. Access CouchDB at http://localhost:5984/_utils
4. Configure Obsidian LiveSync plugin to connect to CouchDB
5. Optionally access web Obsidian at http://localhost:8080