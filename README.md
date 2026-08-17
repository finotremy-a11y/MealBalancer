# MealBalancer

Rails 8 application for composing meals and balancing ingredient portions against a calorie target.

## Local setup

Requirements: Ruby `3.4.2`, Bundler and SQLite.

```bash
bin/setup
bin/dev
```

The application is available at `http://localhost:3000`. Seed sample data with:

```bash
bin/rails db:seed
```

## Validation

```bash
bin/ci
bin/rails test:system
```

There are currently no Capybara scenarios, but the system-test task is configured and ready for them.

## Production deployment

The supported deployment path is a single Linux VPS running Docker and Kamal. SQLite, Solid Cache, Solid Queue and Solid Cable use the persistent `meal_balancer_storage` Docker volume. This deployment model is appropriate for a single application server; move to PostgreSQL and a separate job process before horizontal scaling.

Before the first deploy, configure DNS so `APP_HOST` resolves to the VPS, open ports `80` and `443`, install Docker, and allow SSH key access for the deployment user.

Export the required deployment configuration locally:

```bash
export KAMAL_HOST="203.0.113.10"
export APP_HOST="meals.example.com"
export KAMAL_IMAGE="your-github-user/meal_balancer"
export KAMAL_REGISTRY="ghcr.io"
export KAMAL_REGISTRY_USERNAME="your-github-user"
export KAMAL_REGISTRY_PASSWORD="a-registry-token"
```

`RAILS_MASTER_KEY` falls back to the local `config/master.key`; never commit that key. Inspect the generated deployment configuration before the first deploy:

```bash
bin/kamal config
bin/kamal setup
bin/kamal deploy
bin/kamal app logs -f
```

Kamal uses the current Git commit as the release version. This repository must therefore have an initial commit before `bin/kamal setup` or `bin/kamal deploy`.

Kamal Proxy issues and renews the TLS certificate. Rails enables HTTPS, secure cookies, HSTS and host authorization from `APP_HOST`. Health checks use `https://$APP_HOST/up`.

## GitHub Actions deployment

The manual `Deploy production` workflow requires a GitHub `production` environment. Add these environment variables:

```text
APP_HOST=meals.example.com
KAMAL_IMAGE=your-github-user/meal_balancer
```

Add these environment secrets:

```text
KAMAL_HOST
KAMAL_SSH_PRIVATE_KEY
KAMAL_REGISTRY_PASSWORD
RAILS_MASTER_KEY
```

Run the workflow manually after the CI workflow is green. It deliberately does not deploy on every push.

## Backups and restore drill

Create a backup before every deploy and at least daily from a trusted machine. The script streams the complete persistent volume, including SQLite databases and local uploads, then verifies the archive:

```bash
export KAMAL_HOST="203.0.113.10"
BACKUP_DIRECTORY="$HOME/meal-balancer-backups" script/backup-production-sqlite
```

Copy archives to off-site storage with retention. Test restoration before relying on backups: stop the app, replace the `meal_balancer_storage` volume from a verified archive, run `bin/kamal deploy`, then verify `/up` and a representative meal update. Keep at least one successful restore drill per release cycle.

## Operational checks

```bash
curl --fail --silent --show-error https://$APP_HOST/up
bin/kamal app details
bin/kamal app logs -f
```

Monitor the `/up` endpoint, container restart count, disk capacity for the Docker volume and backup success. Configure SMTP credentials only when the application begins sending email.
