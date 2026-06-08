# ARBRepo

Production source-of-truth repository for ARBAutomation Qlik app and automation promotion.

Branch model:

- `main`: production-ready source of truth. Deploy only from tagged releases.
- `dev`: integration branch for DEV/UAT validation.
- `feature/*`: working branches created from `dev`.
- `release/*`: optional frozen UAT candidate branches.
- `hotfix/*`: emergency production fixes created from `main` and back-merged to `dev`.

See `docs/ARBAutomation_Code_Promotion_Process.md` for the full promotion process.
