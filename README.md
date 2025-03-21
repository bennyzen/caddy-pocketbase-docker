# Caddy meets PocketBase

Caddy with builtin PocketBase (as Caddy module), all nicely wrapped up in an
easy to use Docker Compose stack.

## Usage

- copy the `.env.example` to `.env` and fill in the required values
- run `docker volume create caddy_data` to create a volume for Caddy
- run `docker-compose up --build -d && docker-compose logs -f` to start the
  stack and follow the logs
- to create a superuser, copy the link from the logs and paste it into your
  browser. You will need to replace the `http://127.0.0.1:12345` part with
  `https://${FQDN}`.
- visit `https://${FQDN}/api/health` to do a health check.
- visit `https://${FQDN}/_/` to see the PocketBase dashboard and login with the
  superuser credentials you've previously created.
- create an new user using the dashboard in the `users` collection. Use this user
  to authenticate and interact with the API.

> When using localhost as FQDN, make sure you install the CA certificate in your
> browser to avoid SSL errors. The CA certificate is located in the
> `caddy/ca-certificates` directory, once you've started the stack.

## Admin API Endpoints

The module provides admin API endpoints under `/pocketbase/`:

- `POST /pocketbase/superuser` - Create a new superuser
- `PUT /pocketbase/superuser` - Upsert a superuser
- `PATCH /pocketbase/superuser` - Update superuser password
- `DELETE /pocketbase/superuser` - Delete a superuser
- `POST /pocketbase/superuser/{email}/otp` - Generate OTP for superuser

All the above endpoints require a JSON payload, except for the OTP endpoint. The
JSON payload for the superuser endpoints is as follows:

```json
{
  "email_address": "...",
  "password": "..."
}
```

The `DELETE` endpoint does not expect the `password` field.

Refer to the [PocketBase API documentation](https://pocketbase.io/docs/api-records/)
for more information on how to interact with the API.

Thanks to [mohammed90](https://github.com/mohammed90) for the
[caddy-pocketbase](https://github.com/mohammed90/caddy-pocketbase) module.
