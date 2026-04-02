# Cothrom Documentation

Welcome to the Cothrom project documentation. Cothrom is a self-hosted stack of business and productivity services deployed using Docker Compose.

## Quick Navigation

- **[Getting Started](getting-started.md)** - Prerequisites, environment setup, and first run
- **[Architecture](architecture.md)** - System design, networks, and compose structure
- **[Operations](operations.md)** - Daily operations, commands, and troubleshooting

### Configuration

- **[Paths and Volumes](configuration/paths-and-volumes.md)** - Volume strategy, bind mounts, and path resolution
- **[Environment Variables](configuration/environment.md)** - Complete `.env` reference
- **[Labels](configuration/labels.md)** - `io.cothrom.*` labeling scheme

### Services

- **[Active Stacks](stacks/active.md)** - Currently deployed services
- **[Planned Stacks](stacks/planned.md)** - Future services and lower priority stacks
- **[Stack Overview](stacks/README.md)** - How stacks are organized

### Development

- **[Service Templates](service_templates.md)** - Templates for adding new services
- **[Backup Scripts](../scripts/README.md)** - Automated database and config backups using Docker labels

## Project Overview

Cothrom provides a comprehensive suite of self-hosted services:

- **File Management** - ProjectSend for file sharing
- **Data & Databases** - NocoDB, PostgreSQL, pgAdmin
- **Calendar & Contacts** - Baikal (CalDAV/CardDAV)
- **CRM** - Twenty CRM
- **ERP** - Dolibarr (planned)
- **Applications** - Budibase for low-code app development
- **Documents** - Etherpad for collaborative editing
- **Tools** - Grammar checking, PDF manipulation, drawing tools
- **Accounting** - Akaunting
- **Dashboard** - Dashy for service overview

All services are containerized using Docker Compose with a modular architecture allowing individual stacks to be enabled/disabled as needed.

## Getting Help

- Check the [Operations](operations.md) guide for troubleshooting
- Review service-specific logs: `make logs <container_id>`
- See the main [README.md](../README.md) for the service list and status
