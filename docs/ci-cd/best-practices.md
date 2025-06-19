# Mobile App CI/CD and Security Best Practices

## Tooling Philosophy

| Principle                | Strategy                                                                 |
|--------------------------|--------------------------------------------------------------------------|
| Start free               | Prefer OSS or freemium tools initially                                   |
| Upgrade by maturity      | Integrate paid tools when scale or compliance requires                   |
| Seamless developer UX    | Prioritize tools that work in CI/CD with no local installs               |
| Modular + Reproducible   | All automation must run headlessly in CI, not on developer machines      |

---

## Glossary of Terms

| Term         | Description                                                                 |
|--------------|-----------------------------------------------------------------------------|
| **CI/CD**    | Continuous Integration / Delivery                                           |
| **SCA**      | Software Composition Analysis – scans third-party packages for CVEs/licenses |
| **SAST**     | Static App Security Testing – scans source code for flaws                  |
| **DAST**     | Dynamic App Security Testing – scans running builds/APIs                   |
| **CVE**      | Common Vulnerabilities and Exposures – known security issues in dependencies |
| **IaC**      | Infrastructure as Code – e.g., Firebase rules, GitHub branch policies       |
| **Artifact** | Binary output (e.g., APK), test reports, coverage files                     |

---

## 1. CI/CD Workflow

| Stage      | Open Source / Free Tier                      | Commercial (Upgrade Path)                  |
|------------|----------------------------------------------|--------------------------------------------|
| **CI/CD**  | GitHub Actions (free for public repos)       | Bitrise, Codemagic                         |
| **Build**  | `flutter build apk`, `flutter build ios`     | Fastlane Enterprise, AppCenter             |
| **Deploy** | Firebase App Distribution (free tier)        | App Store Connect API, Play Console API    |
| **Artifacts** | GitHub Actions artifacts                  | S3, Artifactory, GitHub Releases           |

**Recommended Setup**:
- Use `main`, `develop`, and `feature/*` branches
- Trigger pipeline on PRs, tags, and pushes to `main`

---

## 2. Security Integration

### 2.1 Software Composition Analysis (SCA)

| Feature                 | Open Source / Free                       | Production-Grade Upgrade               |
|-------------------------|------------------------------------------|----------------------------------------|
| CVE detection           | GitHub Dependabot                        | Snyk (team/commercial tiers)           |
| License enforcement     | FOSSA CLI (OSS)                          | Snyk, WhiteSource, FOSSA SaaS          |
| Transitive deps scan    | `pub deps`, `pub outdated`, FOSSA        | Full license & policy enforcement      |

**Startup Strategy**:
- Enable GitHub Dependabot for `pubspec.yaml`
- Use [FOSSA CLI](https://github.com/fossas/fossa-cli) to generate SBOM and license scan

### 2.2 Static Application Security Testing (SAST)

| Feature                 | Open Source / Free                     | Commercial Upgrade                      |
|-------------------------|----------------------------------------|------------------------------------------|
| Flutter code scan       | `dart_code_metrics`, `pana`            | Semgrep (commercial rules)               |
| PR scanning             | Semgrep OSS, CodeQL for Dart (custom)  | GitHub Advanced Security                 |
| Rule enforcement        | CI step with `dart_code_metrics`       | Semgrep Cloud                            |

**Startup Strategy**:
- Use Semgrep OSS with community rules or write minimal `.semgrep.yaml`
- Run `dart_code_metrics` in CI with warning thresholds

### 2.3 Dynamic Application Security Testing (DAST)

| Feature                 | Open Source / Free                       | Commercial Upgrade                      |
|-------------------------|------------------------------------------|------------------------------------------|
| Live scan               | OWASP ZAP CLI                            | ZAP Pro, Detectify, StackHawk            |
| APK scan                | MobSF (open source)                      | MobSF Pro API                            |

**Startup Strategy**:
- Run MobSF in Docker: scan APK after `flutter build apk`
- Run OWASP ZAP headless against Firebase or hosted staging endpoint

---

## 3. Infrastructure Security (IaC + Secrets)

| Area                    | Open Source / Free                  | Commercial Upgrade                          |
|-------------------------|-------------------------------------|----------------------------------------------|
| Firebase rules testing  | Firebase Emulator Suite             | n/a                                           |
| GitHub policy           | Native branch protection            | GitHub Enterprise policies, Datadog audit    |
| Secrets scanning        | truffleHog, Gitleaks (pre-commit)   | GitHub Advanced Security, GitGuardian        |
| Secrets management      | GitHub Secrets, GCP Secret Manager  | HashiCorp Vault, Doppler                     |

**Startup Strategy**:
- Add secret scanning with `truffleHog` in CI
- Run Firebase emulators to validate `.read/.write` rules
- Protect `main` and `develop` with required reviews and status checks

---

## 4. Testing & Coverage

| Area                    | Free / Open Source                     | Upgrade Options                            |
|-------------------------|----------------------------------------|---------------------------------------------|
| Unit / Widget tests     | `flutter test`, `integration_test`     | Codemagic test grid, Firebase Test Lab      |
| Coverage reports        | `lcov`, upload to Codecov (free tier)  | SonarCloud, Codecov Pro                     |
| Test enforcement        | GitHub Actions + pass/fail gates       | GitHub Checks API + dashboards              |

**Startup Strategy**:
- Run `flutter test --coverage` in CI
- Upload `.lcov.info` to Codecov via GitHub Action

---

## 5. Build & Release Management

| Area                    | Free / OSS Tools                       | Commercial Upgrade                          |
|-------------------------|----------------------------------------|----------------------------------------------|
| Build automation        | GitHub Actions, Flutter CLI            | Fastlane + Code Signing API                  |
| Versioning              | Git tags + `flutter build --build-name`| Semantic Release, Release Drafter            |
| Artifact storage        | GitHub Actions artifacts               | S3, GitHub Releases, Firebase Hosting        |
| Manual approval         | GitHub Environments                    | GitHub Enterprise protected environments     |

**Startup Strategy**:
- Use manual `workflow_dispatch` to trigger production deploys
- Store unsigned APK as CI artifact; sign only in production job

---

## 6. Quality Gates

| Gate                     | Toolset (Free/OSS)                          | Upgrade (Optional)                        |
|--------------------------|---------------------------------------------|--------------------------------------------|
| Lint                     | `flutter analyze`, `dart format`            | Static code analyzers                      |
| CVE Blocking             | Dependabot alerts + CI filter               | Snyk enforcement rules                     |
| License policy           | FOSSA CLI + denylist enforcement in CI      | Snyk License Policies                      |
| Secret detection         | truffleHog pre-push + GitHub scanning       | GitGuardian                                |
| Firebase rules tested    | Emulator + CI exit code                     | Custom Rules CI pipelines                  |
| Minimum coverage         | Codecov config + fail thresholds            | SonarCloud rulesets                        |

---

## 7. Recommended Stack

| Purpose             | Tools (Free First)                     | Upgrade Path                          |
|---------------------|----------------------------------------|----------------------------------------|
| CI/CD               | GitHub Actions                         | Bitrise, Codemagic                     |
| SCA                 | GitHub Dependabot, FOSSA               | Snyk                                   |
| SAST                | dart_code_metrics, Semgrep OSS         | Semgrep Cloud                          |
| DAST                | MobSF, OWASP ZAP                       | Detectify, MobSF Pro                   |
| Coverage            | lcov + Codecov.io                      | SonarCloud                             |
| Secrets Detection   | truffleHog, Gitleaks                   | GitGuardian                            |
| Firebase Rules      | Firebase Emulator CLI                  | Custom test harnesses                  |
| Deploy              | Firebase App Distribution              | Fastlane Enterprise                    |

---

## Summary: Startup-Ready, Enterprise-Scalable

- Start with **GitHub-native tools**, open source scanners, and Firebase's free tier
- Integrate **security checks from day one** (SCA, SAST, DAST, secret scan)
- Keep builds **modular, testable, artifact-driven**, and CI-reproducible
- Use **Codecov, truffleHog, Semgrep, and FOSSA** to enforce early guardrails
- Upgrade to **Snyk, GitGuardian, Bitrise** as team and compliance demands grow

This approach enables secure, scalable mobile engineering with **zero developer friction** and full **DevSecOps compatibility**.
