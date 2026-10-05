# editalmind-infra

[![ci](https://github.com/For-Davi/editalmind-infra/actions/workflows/ci.yml/badge.svg)](https://github.com/For-Davi/editalmind-infra/actions/workflows/ci.yml)

Infrastructure for [EditalMind](https://github.com/For-Davi/editalmind): Docker Compose for local development and, later, deployment files.

## Local environment

| Service | Image | Host address | Purpose |
|---|---|---|---|
| MySQL | `mysql:8.4` | `127.0.0.1:3307` | Users, subscriptions, payments, quotas |
| MongoDB | `mongodb/mongodb-atlas-local:8` | `127.0.0.1:27017` | Exam notices, study plans, generated content, vectors (Vector Search) |
| Redis | `redis:7.4-alpine` | `127.0.0.1:6379` | Celery broker and cache |
| MinIO | `cgr.dev/chainguard/minio` | API `127.0.0.1:9000`, console `127.0.0.1:9001` | S3-compatible storage for PDFs |
| Mailpit | `axllent/mailpit` | SMTP `127.0.0.1:1025`, inbox `127.0.0.1:8025` | Fake SMTP server for development |

With `make up-apps`, the application services are built from `../editalmind-api`, `../editalmind-ai` and `../editalmind-web` (profile `apps`): api on `127.0.0.1:8000`, ai-api on `127.0.0.1:8001`, ai-worker without ports, web on `127.0.0.1:8080`.

Every port is bound to `127.0.0.1` and can be changed in `.env`.

### Usage

```bash
make up       # creates .env from .env.example, starts the infrastructure, waits for health checks, creates the bucket
make up-apps  # same, plus api, ai-api, ai-worker and web built from the sibling repositories
make ps       # status and health of each service
make logs     # follow logs
make down     # stop, keeping data
make reset    # stop and delete every volume
```

`make up` is idempotent: running it again keeps the existing data and bucket.

The CI pipeline validates the compose file and boots the infrastructure from scratch on every pull request.

### Notes

- Upstream `minio/minio` images are no longer published, so the stack uses the Chainguard build of MinIO. Application code talks to it through the S3 API, so any S3-compatible server works.
- MySQL is exposed on port `3307` to avoid clashing with a MySQL server already installed on the host.
