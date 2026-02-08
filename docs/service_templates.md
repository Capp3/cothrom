# Docker Templates

## Substitutions

## Services

### Databases

#### Postgress

```yaml
  <ServiceName_db>:
    <<: [*post_health_policy, *db_restart_policy, *post-image, *db-network]
    container_name: <ServiceName_db>
    environment:
      POSTGRES_DB: <ServiceName_db>
      POSTGRES_PASSWORD: ${DATA_ASSDISASTER_POSTGRES_PASSWORD}
      POSTGRES_USER: <ServiceName_db>
    volumes:
      - <ServiceName_db>:/var/lib/postgresql/data
```
