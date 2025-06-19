# Engineering Docs

This folder contains essential documentation to help us build and ship our mobile app securely, reliably, and efficiently.
It serves as a central knowledge base for our engineering practices, tools, and workflows.

It includes our decisions, development standards, and automation practices.
This documentation is meant to be a living resource that evolves with our team and projects.

## Structure

| Folder         | Description                                                           |
|----------------|-----------------------------------------------------------------------|
| `architecture/`| App structure, Firebase setup, and dependencies                       |
| `adr/`         | Architectural Decision Records – key technical decisions and rationale|
| `ci-cd/`       | CI/CD setup, GitHub Actions, build and deploy processes               |
| `security/`    | Basic security practices, secret management, SCA/SAST/DAST configs    |
| `quality/`     | Linting, testing, and review process                                  |
| `release/`     | How we tag, version, and distribute builds                            |
| `onboarding/`  | Developer setup, git workflows, contribution guidance                 |
| `tools/`       | Scripts, utilities, and tools used in development                     |

## Getting Started

- Start in `onboarding/getting-started.md` to set up your local dev environment.
- See `ci-cd/pipeline-overview.md` for how builds and deploys are automated.
- Follow `quality/code-review-checklist.md` before opening a pull request.

## Key Practices

- We use GitHub Actions for CI/CD
- We store secrets in GitHub Secrets
- Firebase is used for backend services and deployment
- All code must pass lint, test, and build stages before merging to `main`
- Security scans (dependencies, secrets) are automated in CI

## Contributions

- Keep documentation in sync with code or infra changes.
- Prefer clear, actionable language.
- If in doubt, add a simple `.md` file to this folder and improve iteratively.

