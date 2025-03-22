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

Access the PocketBase dashboard under https://${FQDN}/_/

Access the PocketBase API under https://${FQDN}/api/

Refer to the [PocketBase API documentation](https://pocketbase.io/docs/api-records/)
for more information on how to interact with the API.

Thanks to [mohammed90](https://github.com/mohammed90) for the
[caddy-pocketbase](https://github.com/mohammed90/caddy-pocketbase) module.
