# Cothrom

A comprehensive self-hosted stack for business and productivity services.

## Documentation

📚 **[Complete documentation available in docs/](docs/)**

- [Getting Started](docs/getting-started.md) - Setup and first run
- [Architecture](docs/architecture.md) - System design and networks
- [Operations](docs/operations.md) - Daily operations and troubleshooting
- [Configuration](docs/configuration/) - Environment, paths, and labels
- [Active Stacks](docs/stacks/active.md) - Currently deployed services

## Services Overview

| Service                                                 | Description                     | Sub Name  | Stage | done |
| ------------------------------------------------------- | ------------------------------- | --------- | :---: | ---- |
| [Project Send](https://www.projectsend.org/)            | File Sharing                    | files     |   1   | x    |
| [NocoDB](https://www.nocodb.com/)                       | Airtable/DB Management          | data      |   1   | x    |
| [Open Meetings](https://openmeetings.apache.org/)       | Group wear                      | meetings  |   1   | x    |
| [Language Tool](https://languagetool.org/)              | Grammar Tool                    | grammar   |   1   | x    |
| [collabora](https://www.collaboraonline.com/)           | Office                          | office    |   1   | x    |
| [Grist](https://www.getgrist.com/)                      | Airtable Replacement            | grist     |   1   | x    |
| [Gist](https://github.com/thomiceli/opengist)           | Paste bin                       | pastebin  |   1   |      |
| [Dashy](https://dashy.to/)                              | Dashboard                       | home      |   1   | x    |
| MyIP                                                    | Network tools                   | network   |   1   |      |
| [dolibarr](https://www.dolibarr.org/)                   | ERP / CRM                       | company   |   1   | x    |
| [Appsmith](https://www.appsmith.com/)                   | app creator                     | apps      |   1   | x    |
| Shlink                                                  | URL Shortener                   | url       |   1   |      |
| [Baikal](https://sabre.io/baikal/)                      | Calender Management             | cal       |   1   | x    |
| [Etherpad](https://etherpad.org/)                       | Collaborative Document Creation | documents |       |      |
| [AnythingLLM](https://anythingllm.com/)                 | Self hosted LLM agent           | ai        |       |      |
| [twenty](https://twenty.com/)                           | CRM                             | crm       |       | x    |
| WooCommerce                                             | EShop                           | store     |       |
| Frappe HR                                               | HR Management                   | hr        |       |
| Snipeit                                                 | Inventory Management            | inventory |       |
| [SyncThing](https://syncthing.net/)                     | File Backup                     | sync      |       |
| [Paperless](https://docs.paperless-ngx.com/)            | Document Storage                | docs      |       |
| [Omnitools](https://omnitools.app/)                     | Business Tools                  | tools     |       |
| Wordpress                                               | Web thing                       | blog, www |       |
| [Immich](https://immich.app/)                           | Photo Management                | photos    |       |
| [Open Project](https://www.openproject.org/)            | project management              | project   |       |
| Authelia                                                | auth management                 | auth      |       |
| [AppFlowy](https://appflowy.com/)                       | todo system                     | todo      |       |
| Traefik                                                 | Reverse Proxy                   |           |       |
| [Perplexica](https://github.com/ItzCrazyKns/Perplexica) | LLM Research Assistant          | research  |       |

## Service Template

```yaml
serviceName:
  image: <image>/<image>
  container_name: <sub_image>
  environment:
    - PUID=${PUID}
  volumes:
    - <volume>:/config
  ports:
    - external:internal
  restart: unless-stopped
  depends_on:
    <serviceName>:
      condition: service_healthy
  labels:
    - 'com.example.description=Accounting webapp'
```

standard DB: postgres:17-bookworm

## Labeling

```yaml
    labels:
      # database | app | proxy | worker | cache | storage
      - io.cothrom.role="app"
      - io.cothrom.stack="documents"
      - io.cothrom.data="true"
      # database | files | config
      - io.cothrom.data.class="config"
      # postgres | mysql | mariadb | redis
      - io.cothrom.db.engine="mysql"
      - io.cothrom.db.backup.command=pg_dump -U $POSTGRES_USER -d $POSTGRES_DB
      - io.cothrom.db.backup.command="mysqldump -u $MYSQL_USER -p $MYSQL_ROOT_PASSWORD $MYSQL_DATABASE"
      # daily | hourly | weekly
      - io.cothrom.backup.policy="daily"
```
