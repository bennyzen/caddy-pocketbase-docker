# Code Review: caddy-pocketbase-docker

**Repository:** bennyzen/caddy-pocketbase-docker  
**Last Updated:** 2025-03-22 (almost a year old)  
**Review Date:** 2026-02-03  
**Status:** 🔴 **Outdated & Needs Updates**

---

## Executive Summary

This repo provides a Docker Compose setup for running Caddy with the PocketBase module. While the core concept is solid, **the implementation is significantly outdated** and has several issues that need addressing.

### Critical Issues
1. ❌ **Outdated Caddy version** (2.9.1 → should be 2.10.2+)
2. ❌ **Hardcoded bug workaround** still present in Caddyfile
3. ❌ **Missing `.env.example` documentation**
4. ⚠️ **Volume creation step is manual** (should be handled in docker-compose)
5. ⚠️ **No version pinning** for the caddy-pocketbase module

---

## Detailed Findings

### 1. **Dockerfile** - 🔴 Needs Update

**Current:**
```dockerfile
FROM caddy:2.9.1-builder AS builder
RUN xcaddy build --with github.com/mohammed90/caddy-pocketbase
FROM caddy:2.9.1
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```

**Issues:**
- Using Caddy 2.9.1 (released ~Aug 2024)
- Latest is **Caddy 2.10.2** (Aug 2025) with major improvements:
  - Encrypted ClientHello (ECH)
  - Post-quantum cryptography by default
  - Wildcard cert support improvements
  - libdns 1.0 APIs
- No version pinning for the caddy-pocketbase module

**Recommendation:**
```dockerfile
FROM caddy:2.10-builder AS builder
RUN xcaddy build \
    --with github.com/mohammed90/caddy-pocketbase@latest

FROM caddy:2.10
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```

Or pin to a specific version if stability is critical:
```dockerfile
FROM caddy:2.10.2-builder AS builder
```

---

### 2. **Caddyfile** - 🟡 Has Known Bug Workaround

**Current:**
```caddyfile
{
	pocketbase {
		listen 8090
		# data_dir /pb # data directory (BUG: this is not working)
	}
	order pocketbase before file_server
}

{$FQDN} {
	pocketbase
	handle /test {
		respond "Hello, World!"
	}
}
```

**Issues:**
- Contains commented-out `data_dir` directive with "BUG" note
- The workaround mounts `./pb:/data/caddy/pb_data` in docker-compose instead
- This couples the config to a specific implementation detail
- The `/test` endpoint is just demo code (should remove or document)

**Questions to investigate:**
- Has the `data_dir` bug been fixed in newer versions of caddy-pocketbase?
- Should we use the proper config directive instead of volume hacks?

**Recommendation:**
- Test if `data_dir /data/caddy/pb_data` works with latest module version
- If yes, use it; if no, document WHY the workaround is needed
- Remove `/test` endpoint or move to a separate example config

---

### 3. **docker-compose.yml** - 🟡 Functional but Improvable

**Current:**
```yaml
services:
  caddy:
    container_name: caddy
    build:
      context: .
      dockerfile: Dockerfile
    restart: unless-stopped
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
      - ./caddy/ca-certificates:/usr/local/share/ca-certificates
      - ./pb:/data/caddy/pb_data
    environment:
      - FQDN=${FQDN}

volumes:
  caddy_data:
    external: true
  caddy_config:
```

**Issues:**
- `caddy_data` is marked as `external: true` requiring manual creation
- This trips up new users (common Docker anti-pattern for local dev)
- No health check defined
- Missing resource limits (could be good to add)

**Recommendation:**
```yaml
volumes:
  caddy_data:
    # Remove 'external: true' for auto-creation
  caddy_config:

services:
  caddy:
    # ... existing config ...
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

Update README to remove the manual volume creation step.

---

### 4. **README.md** - 🟡 Good but Could Be Better

**Issues:**
- Instructions still reference manual volume creation (`docker volume create caddy_data`)
- Heavy emphasis on the superuser link workflow, which is confusing
- No troubleshooting section
- No info on upgrading PocketBase or Caddy versions
- The "Ideal for" section at the top is marketing fluff (duplicates the actual usage info)

**Strengths:**
- Clear step-by-step usage
- Good notes about localhost SSL certificates
- Links to PocketBase API docs

**Recommendation:**
- Add **Troubleshooting** section (SSL errors, superuser setup, etc.)
- Add **Upgrading** section (how to update Caddy/PocketBase)
- Simplify the intro (remove redundant "Ideal for" section)
- Document the `data_dir` workaround explicitly

---

### 5. **Security Considerations** - ⚠️ Not Addressed

**Missing:**
- No mention of changing default ports (8090 exposed internally)
- No guidance on securing the admin API endpoints (`/pocketbase/superuser`)
- No mention of firewall rules or network isolation
- The README suggests creating a superuser via browser link but doesn't mention securing this flow

**Recommendation:**
Add a **Security** section to README:
- How to restrict access to admin endpoints
- Best practices for production deployment
- Warning about exposing PocketBase admin UI publicly

---

### 6. **Testing** - ❌ No Tests

**Missing:**
- No CI/CD pipeline
- No automated tests (even a basic `docker-compose up` smoke test)
- No GitHub Actions workflow

**Recommendation:**
Add `.github/workflows/test.yml`:
```yaml
name: Test Build
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and start
        run: |
          docker-compose up -d --build
          sleep 10
          docker-compose ps
          curl -f http://localhost/api/health || exit 1
      - name: Check logs
        if: failure()
        run: docker-compose logs
```

---

## Priority Action Items

### 🔴 High Priority
1. **Update Caddy to 2.10.2+**
2. **Test and fix the `data_dir` directive** (remove workaround if possible)
3. **Remove `external: true` from volumes** (improve DX)
4. **Add health check to docker-compose**

### 🟡 Medium Priority
5. **Clean up README** (remove marketing fluff, add troubleshooting)
6. **Add security guidance**
7. **Add basic CI/CD tests**
8. **Document or remove `/test` endpoint**

### 🟢 Nice to Have
9. Pin caddy-pocketbase module version for stability
10. Add `docker-compose.prod.yml` example with resource limits
11. Add example `.env` with more options (e.g., ACME email)

---

## Suggested Immediate Changes

Here's what I'd do right now if this were my repo:

1. **Bump Caddy version** in Dockerfile to `2.10` or `2.10.2`
2. **Remove `external: true`** from `caddy_data` volume
3. **Update README** to remove manual volume creation step
4. **Add health check** to docker-compose
5. **Test the whole stack** to ensure it still works
6. **Add a GitHub Actions workflow** for basic smoke testing

---

## Questions for You

1. **Is this repo actively used in production?** If yes, we should be more conservative with updates.
2. **Do you want me to make these changes?** I can create a branch with the fixes.
3. **Should we test the `data_dir` directive fix?** I can spin up the stack and experiment.
4. **Any features you wanted to add** that never got implemented?

---

## Overall Grade: C+ (Functional but Outdated)

**Strengths:**
- ✅ Core concept is solid
- ✅ Actually works (when you follow all the manual steps)
- ✅ Good documentation of setup process

**Weaknesses:**
- ❌ Almost a year old with no updates
- ❌ Using outdated dependencies
- ❌ Contains known bug workarounds
- ❌ No automated testing or CI

**Verdict:** Needs a refresh pass before recommending to anyone new. With ~2-3 hours of work, this could be a solid, modern reference implementation.
