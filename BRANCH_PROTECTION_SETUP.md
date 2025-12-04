# Branch Protection Setup Guide

## Prerequisites
- Repository must be pushed to GitHub
- You must have admin access to the repository

## Steps to Configure Branch Protection

### 1. Navigate to Branch Protection Settings
1. Go to your GitHub repository
2. Click on **Settings** → **Branches**
3. Under "Branch protection rules", click **Add rule**

### 2. Configure Protection for `main` Branch
Enter the following settings:

**Branch name pattern:** `main`

**Protect matching branches:**
- ✅ Require a pull request before merging
  - ✅ Require approvals: **1**
  - ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require status checks to pass before merging
  - ✅ Require branches to be up to date before merging
  - **Search for status checks:** Type `build-and-test` and select it
- ✅ Do not allow bypassing the above settings
- ✅ Restrict who can push to matching branches (optional - select senior developers)

**Rules applied to everyone including administrators:**
- ✅ Prevent force pushes
- ✅ Allow deletions: ❌ (uncheck this)

Click **Create** to save.

### 3. Repeat for `develop` Branch (if applicable)
Follow the same steps for the `develop` branch.

## Verification
1. Try to push directly to `main` - it should be blocked
2. Create a feature branch and open a PR
3. Verify that CI checks run automatically
4. Verify that you cannot merge until:
   - CI passes
   - At least 1 approval is given

## Troubleshooting

### Status check "build-and-test" not appearing
- Make sure you've pushed the `.github/workflows/ci.yml` file
- Trigger a workflow run by creating a PR
- Wait for the workflow to complete at least once
- Return to branch protection settings and search again

### Cannot require approvals
- Ensure you have a GitHub Pro, Team, or Enterprise account
- Free accounts can use branch protection but with limited features

## Additional Security (Recommended)
Consider enabling:
- **Require signed commits** (for extra security)
- **Include administrators** (to prevent accidents)
- **Require linear history** (to keep git history clean)
