# Caddy with builtin PocketBase: A Streamlined Docker Deployment

This repository provides a ready-to-deploy Docker Compose stack that seamlessly integrates Caddy, a powerful, easy-to-use web server, with PocketBase, a lightweight, open-source backend. By packaging PocketBase as a Caddy module, this setup offers a simplified and efficient way to manage your backend and frontend services.

**Key Features:**

* **Integrated Caddy and PocketBase:** Leverage Caddy's automatic HTTPS and reverse proxy capabilities alongside PocketBase's real-time database and authentication features, all within a single, cohesive environment.
* **Simplified Docker Compose Deployment:** Get your application up and running quickly with a pre-configured Docker Compose stack, minimizing setup complexity.
* **Easy Superuser Creation:** Streamlined superuser creation process via a generated link in the logs, simplifying initial setup.
* **Secure HTTPS by Default:** Caddy's automatic HTTPS ensures your application is served securely.
* **Local Development with Self-Signed Certificates:** Provides clear instructions for handling self-signed certificates when using localhost for development.
* **Comprehensive Usage Instructions:** Step-by-step guidance for setting up, configuring, and interacting with the stack.
* **PocketBase API Access:** Direct access to PocketBase's robust API for data management and user authentication.

**Ideal for:**

* Rapid prototyping of web applications.
* Developing backend-as-a-service (BaaS) applications.
* Creating simple, data-driven websites and mobile apps.
* Users looking for a straightforward and efficient development workflow.

This repository streamlines the deployment of Caddy and PocketBase, empowering you to focus on building your application rather than managing complex server configurations.


Caddy with builtin PocketBase (as Caddy module), all nicely wrapped up in an
easy to use Docker Compose stack.

## Usage

- copy the `.env.example` to `.env` and fill in the required values (e.g., `FQDN=localhost` or your domain)
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

Access the PocketBase dashboard under https://${FQDN}/_/

Access the PocketBase API under https://${FQDN}/api/

Refer to the [PocketBase API documentation](https://pocketbase.io/docs/api-records/)
for more information on how to interact with the API.

## Troubleshooting

### SSL Certificate Errors (localhost development)

When using `localhost` as FQDN, Caddy generates a self-signed certificate. You have two options:

1. **Install the CA certificate** (recommended): The CA certificate is auto-generated in `caddy/ca-certificates/` after first run. Install it in your browser/system trust store.
2. **Accept the risk**: Bypass the SSL warning in your browser (not recommended for production).

### Superuser Creation Issues

If the superuser creation link doesn't work:
- Make sure you replaced `http://127.0.0.1:12345` with `https://${FQDN}` in the link from the logs
- Check that your FQDN resolves correctly (add to `/etc/hosts` if testing locally)
- Verify the container is healthy: `docker-compose ps`

### Health Check Failures

If the health check keeps failing:
- Check logs: `docker-compose logs caddy`
- Verify PocketBase is responding: `curl -k https://localhost/api/health`
- Ensure port 80/443 are not already in use

## Security Considerations

**⚠️ Important for Production Deployments:**

- **Admin API Endpoints**: This setup exposes PocketBase admin endpoints at `/pocketbase/*` (for superuser management). In production, consider restricting access via firewall rules or Caddy matchers.
- **Change Default Ports**: The internal PocketBase port (8090) is configurable in the Caddyfile if you need to avoid conflicts.
- **HTTPS Only**: Always use valid certificates in production (Let's Encrypt via Caddy is automatic for public domains).
- **Admin UI Access**: The PocketBase dashboard at `/_/` should be restricted to authorized IPs in production environments.

## Upgrading

To upgrade Caddy or PocketBase:

1. **Caddy**: Update the version in `Dockerfile` (e.g., `FROM caddy:2.10-builder`)
2. **PocketBase Module**: The module version is pulled at build time via `xcaddy build --with github.com/mohammed90/caddy-pocketbase@latest`
3. Rebuild: `docker-compose up --build -d`

## Thanks

Thanks to [mohammed90](https://github.com/mohammed90) for the
[caddy-pocketbase](https://github.com/mohammed90/caddy-pocketbase) module.
