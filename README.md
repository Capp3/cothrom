# readme

| Service                                                 | Description                     | Sub Name  | Stage | done |
| ------------------------------------------------------- | ------------------------------- | --------- | :---: | ---- |
| [Project Send](https://www.projectsend.org/)            | File Sharing                    | files     |   1   | x    |
| [NocoDB](https://www.nocodb.com/)                       | Airtable/DB Management          | data      |   1   | x    |
| [Open Meetings](https://openmeetings.apache.org/)       | Group wear                      | meetings  |   1   | x    |
| [Language Tool](https://languagetool.org/)              | Grammar Tool                    | grammar   |   1   | x    |
| [collabora](https://www.collaboraonline.com/)           | Office                          | office    |   1   |      |
| [Grist](https://www.getgrist.com/)                      | Airtable Replacement            | grist     |   1   | x    |
| [Gist](https://github.com/thomiceli/opengist)           | Paste bin                       | pastebin  |   1   |      |
| [Dashy](https://dashy.to/)                              | Dashboard                       | home      |   1   |      |
| MyIP                                                    | Network tools                   | network   |   1   |      |
| [dolibarr](https://www.dolibarr.org/)                   | ERP / CRM                       | company   |   1   |      |
| [Appsmith](https://www.appsmith.com/)                   | app creator                     | apps      |   1   | x    |
| Shlink                                                  | URL Shortener                   | url       |   1   |      |
| [Baikal](https://sabre.io/baikal/)                      | Calender Management             | cal       |   1   | x    |
| [Etherpad](https://etherpad.org/)                       | Collaborative Document Creation | documents |       |
| [AnythingLLM](https://anythingllm.com/)                 | Self hosted LLM agent           | ai        |       |
| [twenty](https://twenty.com/)                           | CRM                             | crm       |       |
| [WooCommerce]()                                         | EShop                           | store     |       |
| [Frappe HR]()                                           | HR Management                   | hr        |       |
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
