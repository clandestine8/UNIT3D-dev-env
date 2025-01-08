# UNIT3D Dev Enviroment

### Setup (Requires Docker & Docker Compose)

1. Clone The Dev Environment Repo or Extract the Archive
2. Run `docker compose build`
3. Run `docker compose pull`
4. Run `git clone https://github.com/HDInnovations/UNIT3D-Community-Edition.git ./Repos/UNIT3D`
5. Run `cd ./Repos/UNIT3D && bun update && composer update --ignore-platform-req=*`
6. Run `cp .env.example .env && touch laravel-echo-server.json` & then edit the .env & laravel-echo-server.json file with your setting from the `docker-compose.yml` file in the root directory.
7. Run `cd ../.. && docker compose up -d`
8. Run `docker compose exec unit3d /usr/bin/first`



#### Example Environment File
```dotenv
APP_NAME=UNIT3D
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_LOG_LEVEL=debug
APP_URL=https://unit3d.localhost

MIX_ECHO_ADDRESS=https://://unit3d.localhost

LARAVEL_ECHO_SERVER_HOST=unit3d
LARAVEL_ECHO_SERVER_PORT=8443

LOG_CHANNEL=daily

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=unit3d
DB_USERNAME=unit3d
DB_PASSWORD=Unit3d!!

BROADCAST_CONNECTION=redis
CACHE_STORE=redis
SESSION_DRIVER=redis
SESSION_CONNECTION=session
SESSION_LIFETIME=120
SESSION_SECURE_COOKIE=true
QUEUE_CONNECTION=redis

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_FROM_ADDRESS='support@unit3d.localhost'
MAIL_FROM_NAME='UNIT3D Support'

DEFAULT_OWNER_NAME=UNIT3D
DEFAULT_OWNER_EMAIL=unit3d@example.com
DEFAULT_OWNER_PASSWORD=UNIT3D

TMDB_API_KEY=
TWITCH_CLIENT_ID=
TWITCH_CLIENT_SECRET=

MEILISEARCH_HOST=http://meilisearch:7700
MEILISEARCH_KEY=MASTER_KEY

PROXY_SCHEME=https
FORCE_ROOT_URL=https://unit3d.localhost/
HSTS_ENABLED=false
CSP_ENABLED=false
```

#### Example Laravel Echo Server JSON File
```json
{
  "authHost": "https://unit3d.localhost",
  "authEndpoint": "/broadcasting/auth",
  "clients": [],
  "database": "redis",
  "databaseConfig": {
    "redis" : {
      "port": "6379",
      "host": "redis"
   }
},
  "devMode": true,
  "host": null,
  "port": "8443",
  "protocol": "http",
  "socketio": {},
  "sslPassphrase": "",
  "apiOriginAllow": {
      "allowCors": false,
      "allowOrigin": "",
      "allowMethods": "",
      "allowHeaders": ""
  }
}

```