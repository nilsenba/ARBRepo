# Qlik Tag to Git Branch Mapping

Prepared: June 8, 2026

## Decision

For the current implementation, the Qlik app tag is the Git branch selector.

Repository selection and branch selection should be separate:

- Qlik space maps to the GitHub repository.
- Qlik tag maps to the Git branch.

## Mapping Rule

| Qlik source | GitHub target |
|---|---|
| Qlik space name | Repository name |
| Qlik app tag | Branch name |

Examples:

| Qlik space | Normalized GitHub repository | Qlik tag | Git branch |
|---|---|---|---|
| `Monitoring Apps` | `nilsenba/Monitoring-Apps` | `dev` | `dev` |
| `Monitoring Apps - UAT` | `nilsenba/Monitoring-Apps` | `release/2026-06-08` | `release/2026-06-08` |
| `Monitoring Apps` | `nilsenba/Monitoring-Apps` | `main` | `main` |

## Qlik Automation Changes Needed

In `ARBAutomation - Fixed`, update the branch selector fields from app description to Qlik tag.

Replace this current branch source:

`Get App Information > Info > Attributes > Description`

with the selected Qlik app tag.

Update these automation locations:

1. `Create Or Update File Content` > `Branch`.
2. Branch/reference filter that checks `refs/heads/<branch>`.
3. Commit message text that describes the target GitHub environment.

After the update, branch/reference filtering should compare against:

`refs/heads/<selected Qlik tag>`

## Tag Contract

Use exactly one promotion tag for GitHub commits:

- `dev`
- `main`
- `release/<release-name>`

If an app has no promotion tag, or has multiple promotion tags, the automation should stop and record a validation failure instead of committing to GitHub.

## Why This Is Better Than App Description

The app description should remain human-readable metadata for release notes, Jira ticket references, or deployment comments. A Qlik tag is a cleaner control value because it is explicit, constrained, and easier to validate before committing to GitHub.
