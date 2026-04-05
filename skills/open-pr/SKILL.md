---
name: open-pr
description: Opens a pull request against master for the current branch. Pushes the branch to remote if not already pushed, then creates the PR using gh CLI.
disable-model-invocation: true
allowed-tools: Bash(git status), Bash(git log*), Bash(git diff*), Bash(git push*), Bash(gh auth status*), Bash(gh pr create*), Bash(gh pr view*)
---

Open a pull request against master for the current branch. Follow these steps:

1. Run `git status` to confirm there is nothing uncommitted that should be included.
2. Run `git log master..HEAD --oneline` (or `git log origin/master..HEAD --oneline` if master is not local) to summarise the commits that will be in the PR.
3. Run `git push -u origin HEAD` to push the current branch to remote (this is safe to run even if already pushed).
4. Use `gh pr create --base master` to open the PR. Derive the title and body from the commit history:
   - Title: concise summary of the change (under 70 characters)
   - Body: use this template:
     ```
     ## Summary
     <bullet points summarising what changed and why>

     ## Test plan
     <bulleted checklist of how to verify the changes>

     🤖 Generated with [Claude Code](https://claude.com/claude-code)
     ```

If `gh` is not authenticated, tell the user to run `gh auth login` first.
If the PR already exists for this branch, report the existing PR URL instead.
If $ARGUMENTS is provided, use it as additional context when writing the PR description.
