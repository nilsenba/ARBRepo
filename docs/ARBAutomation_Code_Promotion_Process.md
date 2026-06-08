# ARBAutomation Code Promotion Process

Prepared: June 8, 2026

## Verified Qlik Automation Flow

The Qlik automation `ARBAutomation - Fixed` is available at automation ID `478b793c-823f-4d31-902a-ce4ab63c474a` in `novsandbox.us.qlikcloud.com`.

Observed editor flow:

1. Trigger: Qlik Cloud Services `App Published` webhook.
2. Lookup: `Get Space`.
3. Gate: continue when the space name contains ` - UAT` or equals `Monitoring Apps`.
4. Repository variable: `vSpace` is derived from the Qlik space name with replace transforms.
5. App metadata: `Get App Information`.
6. Artifact export: `Export App To Base 64 Encoded File`.
7. GitHub lookup/checks: get repository, list repositories, list branches, list references, and filter by `refs/heads/<app description>`.
8. Commit: GitHub `Create Or Update File Content` writes `<app name>.qvf` to the target repository and branch.
9. Audit: Snowflake `Insert Record` logs the migration event.

Important behavior: the target Git branch is driven by the Qlik app description. Use `dev`, `release/<name>`, or `main` as the app description when publishing, depending on the intended promotion lane.

## Target GitHub Strategy

Use `nilsenba/ARBRepo` as the single controlled repository for ARBAutomation.

Branch roles:

- `main`: production source of truth. Only production-ready code. Deploy from tagged releases.
- `dev`: integration branch for DEV/UAT changes.
- `feature/*`: developer work branches created from `dev`.
- `release/*`: optional frozen UAT candidates created from `dev`.
- `hotfix/*`: emergency production fixes created from `main`, then back-merged to `dev`.

The previous split between `ARBRepo_DEV` and `ARBRepo` should be retired after the first successful dry run into `ARBRepo/dev`.

## Qlik Publishing Rules

For DEV/UAT validation:

1. Publish ARBAutomation into the UAT-managed source space that passes the automation gate.
2. Set the Qlik app description to `dev` or `release/<release-name>`.
3. Confirm that the automation commits `<app name>.qvf` into `nilsenba/ARBRepo` on that branch.
4. Open a PR from `dev` or `release/*` into `main` after UAT approval.

For production:

1. Merge the approved PR into `main`.
2. Create an annotated release tag from `main`, for example `v2026.06.08.1`.
3. Deploy production only from the release tag.
4. Record the release tag, commit SHA, Qlik app ID, approver, and deployment timestamp.

## Required GitHub Protections

Configure these in GitHub after the repository scaffold is in place:

- Protect `main`.
- Require pull requests into `main`.
- Require passing checks before merge.
- Require at least one reviewer or code owner approval.
- Prevent direct pushes to `main`.
- Create GitHub environments named `DEV`, `UAT`, and `PROD`.
- Require manual approval for `UAT` and `PROD`.

## Required Secrets

Set these as GitHub environment secrets, not repository files:

| Environment | Secrets |
|---|---|
| DEV | `QLIK_TENANT_URL`, `QLIK_API_KEY`, `QLIK_SPACE_ID` |
| UAT | `QLIK_TENANT_URL`, `QLIK_API_KEY`, `QLIK_SPACE_ID` |
| PROD | `QLIK_TENANT_URL`, `QLIK_API_KEY`, `QLIK_SHARED_SPACE_ID`, `QLIK_MANAGED_SPACE_ID` |

Use separate Qlik service accounts/API keys for each environment.

## Release Checklist

Before UAT:

- Qlik automation committed the QVF into `dev` or `release/*`.
- GitHub validation passed.
- App reload/smoke test completed in UAT.
- Release notes started.

Before PROD:

- UAT approval is documented.
- PR to `main` is approved.
- Checks passed.
- Release tag is created from `main`.
- Rollback tag/commit is identified.

After PROD:

- Production smoke test completed.
- Release notes updated.
- Any manual Qlik changes exported back to Git.
- Hotfixes merged back into `dev`.
