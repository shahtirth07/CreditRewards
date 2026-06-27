# Contributing

Thanks for your interest in contributing. This project is maintained by a
single owner, all merges to `main` go through that owner. Anyone is welcome
to open issues or submit pull requests.

## How to contribute

1. Fork this repository to your own GitHub account.
2. Clone your fork locally:
   ```
   git clone https://github.com/<your-username>/<repo-name>.git
   cd <repo-name>
   ```
3. Create a branch for your change:
   ```
   git checkout -b your-branch-name
   ```
4. Make your changes, commit them with a clear message.
5. Push to your fork:
   ```
   git push origin your-branch-name
   ```
6. Open a pull request from your fork's branch into this repository's `main`
   branch.

You do not need write access to this repository to do any of the above.
Forking and opening a PR from your fork is the expected workflow for all
contributors.

## Reporting issues

Open an issue describing the bug or feature request. Include steps to
reproduce for bugs, and the motivation/use case for feature requests.

## Pull request guidelines

- Keep PRs focused on a single change. Smaller PRs are easier to review and
  more likely to be merged quickly.
- Describe what changed and why in the PR description.
- If your change affects app behavior, describe how you tested it (which
  platform/simulator, manual steps, or tests added).
- Match the existing code structure and naming in the files you touch.

## Credential and authentication boundary

This app reads bank/card data through a webview session after the user logs
in directly on the bank's own page. The app never captures, stores, or
transmits the user's bank password.

Any pull request that touches code in or related to the bank reader/auth
flow (webview handling, session/cookie management, login screens, or
anything that reads page content after authentication) will get extra
scrutiny before merge, regardless of how small the change looks. Please call
this out explicitly in your PR description if your change touches this area,
so it gets reviewed with that in mind.

## Code of conduct

Be respectful and constructive in issues and PR discussions. Disagreements
about implementation approach are fine and expected; keep them focused on
the code.