# Compliance and Security Readiness

This document outlines the business and technical measures needed to make the estate management platform secure and compliant with applicable laws, expectations from estate stakeholders, and future regulatory scrutiny (e.g., audits, B2B onboarding, procurement).

Applies to: Ireland and broader EU (e.g., GDPR, eIDAS readiness)

---

## 1. Legal & Regulatory Compliance (Business Context)

| Area              | Compliance Concern                              | Required Action                                                    |
|-------------------|--------------------------------------------------|---------------------------------------------------------------------|
| GDPR              | Handling resident/user personal data             | Data minimization, consent, opt-outs, privacy policy, DSR process   |
| Financial Data    | Managing estate treasury, bills, payments        | Secure handling, audit logs, PCI-lite treatment (no PAN storage)    |
| Document Storage  | Sharing documents between residents and admins   | eIDAS-aligned digital trust, access control, encryption at rest     |
| User Roles        | Admins managing estates, residents being onboarded | Role-based access enforcement, business logic hardening             |
| Reputation Risk   | Multi-estate operation, admin failures           | Admin audit trails, lockout policies, delegated roles               |

---

## 2. Data Governance

- [ ] **Data Mapping**: Document what data is collected, from whom, and why  
- [ ] **Data Minimization**: Only collect data necessary to support estate functionality  
- [ ] **Data Deletion/Export**: Implement a process to handle GDPR Data Subject Requests (DSR)  
- [ ] **Consent Management**: Use explicit consent for notifications, billing, or third-party integrations  
- [ ] **Privacy Policy**: Maintain an accessible and clear privacy policy tailored to estates

---

## 3. Authentication & Access Control

- [ ] Residents and admins must have separate roles and permissions
- [ ] Admins must not have access to resident billing unless explicitly authorized
- [ ] Implement secure onboarding (email/OTP, social login optional but privacy-reviewed)
- [ ] Firebase Authentication is acceptable if access rules are properly scoped
- [ ] Use session timeouts and invalidation for admin panels

---

## 4. Data Security and Storage

- [ ] All sensitive data (PII, billing info) must be encrypted at rest and in transit
- [ ] Firebase Security Rules must enforce estate-level access segregation
- [ ] File uploads (e.g., documents) must be scanned and validated for type and size
- [ ] Store signed documents in a tamper-evident format (e.g., PDF with hash validation)
- [ ] Firebase Storage access must be tied to authentication and estate context

---

## 5. Payments and Treasury

- [ ] No payment details (PAN, CVV) are stored — use Stripe, Revolut, or secure 3rd-party processor
- [ ] All treasury actions should have double-entry validation, audit logging, and rollback strategy
- [ ] Maintain per-estate billing isolation
- [ ] Future PCI-DSS requirements should be offloaded via hosted fields (e.g., Stripe Elements)

---

## 6. Administrative Safeguards

- [ ] Admins must not have unrestricted access across all estates unless super-admin scoped
- [ ] Every admin action (e.g., edit document, change billing, remove user) must be logged
- [ ] Delegated access must be auditable (e.g., committee-based access, shared role ownership)
- [ ] Lockout protection for abusive admin actions (e.g., throttling, alerting)

---

## 7. Incident Response and Audit Readiness

- [ ] Define an internal breach response process (24–72 hour rule under GDPR Article 33)
- [ ] Document incident categories (data breach, admin abuse, financial error)
- [ ] Maintain CI/CD and Firebase audit logs for at least 90 days
- [ ] Prepare for due diligence questions from B2B or estate-wide adoption reviews

---

## 8. Trusted Communications and Legal Validity

- [ ] System must track when documents are uploaded, shared, and signed (if applicable)
- [ ] For legal notices, support timestamps, read confirmations, and immutability (digital signatures optional)
- [ ] Use Firebase Functions or Firestore triggers for irreversible event logs
- [ ] Email/SMS notifications must be traceable and linked to backend logs

---

## 9. Business Risk Controls for Estate Operations

| Risk                    | Mitigation                                                             |
|-------------------------|------------------------------------------------------------------------|
| Admin impersonation     | Auth logs, IP alerts, device fingerprinting (in roadmap)               |
| Tenant billing disputes | Versioned billing history, no auto-deletes, per-estate ledger support  |
| Estate document loss    | Cloud backup, redundant access logs, versioned document handling       |
| Data disclosure errors  | Access control reviews, SAST scanning, Firebase Rules tests            |

---

## 10. Compliance Roadmap (Phase-based)

| Phase   | What to enforce early                     | What to scale later into                   |
|---------|--------------------------------------------|--------------------------------------------|
| MVP     | GDPR basics, secret scanning, RBAC         | Audit logging, DAST, treasury access flows |
| Early PMF | Consent, data minimization, email auth logs | GDPR DSR APIs, compliance dashboard        |
| Scale   | Role delegation, contract validation        | SOC 2/ISO prep, third-party security review|

---

## Compliance Artifacts to Maintain

| Artifact                                | Location                          |
|-----------------------------------------|-----------------------------------|
| `compliance/compliance-readiness.md`    | Overall controls and status       |
| `compliance/gdpr-policy.md`             | Resident rights, data handling    |
| `compliance/licenses-and-third-party.md`| OSS license audit trail           |
| `security/incident-response.md`         | Security incident playbook        |
| `release/release-checklist.md`          | Pre-release security and privacy  |
| `ci-cd/env-vars-and-secrets.md`         | Production secret handling        |

---

## Contact Roles

- **Data Controller**: Business product owner  
- **Data Processor**: Technical team (Firebase + app backend)  
- **Security Reviewer**: Engineering lead or compliance proxy  
- **Escalation Path**: Defined in `security/incident-response.md`

---

This document should be reviewed quarterly or before new feature sets go live that introduce personal data, payments, or admin-level access.
