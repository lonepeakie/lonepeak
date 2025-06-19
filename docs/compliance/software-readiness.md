# Compliance Readiness Checklist

This document outlines the technical, operational, and procedural steps required to make our platform audit-ready for common compliance frameworks (SOC 2, ISO 27001, GDPR) and customer security reviews.

---

## 1. Access Control & Identity

- [ ] Enforce 2FA on all GitHub and CI/CD accounts
- [ ] Use role-based access control (RBAC) for Firebase, GitHub, and deployment environments
- [ ] Limit production access to only authorized personnel
- [ ] Document onboarding/offboarding processes in `onboarding/access-control.md`

---

## 2. Infrastructure & Environment Security

- [ ] Use environment-based separation (dev/staging/prod) for secrets and services
- [ ] Define and validate Firebase Security Rules for all data access
- [ ] All secrets injected through GitHub Secrets or secure vaults (not .env files)
- [ ] Use least-privilege service accounts for all CI/CD and deployment integrations

---

## 3. Application Security

- [ ] SCA (dependency CVE scanning) enabled via GitHub Dependabot or Snyk
- [ ] SAST (static code analysis) via `dart_code_metrics` or Semgrep on CI
- [ ] DAST (dynamic scan) via MobSF or OWASP ZAP before release
- [ ] Secrets scanning enabled via truffleHog or GitHub's secret scanning feature
- [ ] Perform a manual security review before production deployments

---

## 4. Logging & Monitoring (Basic)

- [ ] Firebase/Cloud logs accessible and auditable for production events
- [ ] Deployment logs retained in CI/CD system for 90+ days
- [ ] Track all code changes with GitHub protected branches and audit trail
- [ ] Capture failed login or auth attempts via Firebase Auth logs

---

## 5. CI/CD Integrity

- [ ] CI/CD pipelines enforce test, lint, build, and security checks before merge
- [ ] All production deploys are triggered only from `main` and are reproducible
- [ ] Artifact signing or hash validation process is documented (if applicable)
- [ ] Manual approval (protected environment) required for production deploys

---

## 6. Data Privacy (GDPR Readiness)

- [ ] Firebase Analytics and Crashlytics privacy settings reviewed and minimized
- [ ] App includes a privacy policy URL and opt-out controls (if required)
- [ ] Data collected is documented, minimal, and stored securely
- [ ] GDPR data access/deletion requests process is documented in `compliance/gdpr-policy.md`

---

## 7. Open Source & Licensing

- [ ] All third-party dependencies scanned with FOSSA or Snyk for license compliance
- [ ] License whitelist maintained (MIT, Apache-2.0 allowed; GPL, AGPL disallowed)
- [ ] `compliance/licenses-and-third-party.md` maintained with audit output

---

## 8. Documentation & Evidence

- [ ] Maintain audit trail of all CI/CD runs and deployments
- [ ] Document key decisions via `adr/` (architecture decision records)
- [ ] Store and version all policies under `docs/compliance/` or similar
- [ ] Maintain a tooling inventory in `compliance/tooling-inventory.md`

---

## Optional (Recommended at Scale)

- [ ] Implement device encryption and MDM for team devices
- [ ] Centralized log aggregation for Firebase and CI/CD events
- [ ] Run quarterly vulnerability assessments
- [ ] Establish a formal incident response process

---

## Ownership

- **Compliance Lead**: [Name / Role]
- **Security Reviewer**: [Name / Role]
- **DevOps Contact**: [Name / Role]

This checklist evolves with compliance requirements and should be reviewed every 30–60 days.