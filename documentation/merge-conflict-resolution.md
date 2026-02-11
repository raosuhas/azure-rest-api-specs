# Resolving Merge Conflicts in Azure REST API Specs

This guide provides step-by-step instructions for resolving merge conflicts when contributing to the azure-rest-api-specs repository.

## Understanding Merge Conflicts

Merge conflicts occur when:
1. You've made changes to a file in your branch
2. Someone else has made different changes to the same file in the main branch
3. Git cannot automatically merge these changes

## Prerequisites

Before resolving conflicts, ensure you have:
- Git installed on your local machine
- Your fork cloned locally
- The upstream repository configured as a remote

## Step-by-Step Conflict Resolution

### Step 1: Set Up Your Repository

If you haven't already, add the upstream repository as a remote:

```bash
# Navigate to your local repository
cd path/to/azure-rest-api-specs

# Add the upstream Azure repository
git remote add upstream https://github.com/Azure/azure-rest-api-specs.git

# Verify remotes are configured
git remote -v
```

You should see:
- `origin` pointing to your fork (e.g., `https://github.com/yourusername/azure-rest-api-specs.git`)
- `upstream` pointing to the original repository (`https://github.com/Azure/azure-rest-api-specs.git`)

### Step 2: Fetch Latest Changes

Fetch the latest changes from the upstream repository:

```bash
# Fetch all branches from upstream
git fetch upstream

# Check your current branch
git branch
```

### Step 3: Update Your Local Main Branch

Before resolving conflicts, update your local main branch:

```bash
# Switch to your main branch
git checkout main

# Update it with upstream changes
git pull upstream main

# Push updates to your fork (optional but recommended)
git push origin main
```

### Step 4: Rebase Your Feature Branch

Switch back to your feature branch and rebase it on top of the latest main:

```bash
# Switch to your feature branch
git checkout your-feature-branch

# Start the rebase
git rebase main
```

**Alternative: Merge Instead of Rebase**

If you prefer merging over rebasing:

```bash
# Switch to your feature branch
git checkout your-feature-branch

# Merge main into your branch
git merge main
```

### Step 5: Identify Conflicts

If there are conflicts, Git will output something like:

```
CONFLICT (content): Merge conflict in specification/example/resource.json
Automatic merge failed; fix conflicts and then commit the result.
```

List all conflicted files:

```bash
git status
```

Files with conflicts will be listed under "Unmerged paths" or "both modified".

### Step 6: Resolve Conflicts

#### Option A: Using VS Code (Recommended)

1. Open the conflicted file in VS Code
2. Look for conflict markers:
   ```
   <<<<<<< HEAD (or your branch)
   Your changes
   =======
   Changes from main
   >>>>>>> main (or commit hash)
   ```
3. VS Code provides buttons to:
   - Accept Current Change (your changes)
   - Accept Incoming Change (main branch changes)
   - Accept Both Changes
   - Compare Changes
4. Choose the appropriate action or manually edit to keep the correct code
5. Remove all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
6. Save the file

#### Option B: Using Command Line Editor

```bash
# Open the conflicted file in your editor
vim specification/example/resource.json
# or
code specification/example/resource.json
# or
nano specification/example/resource.json
```

Manually resolve conflicts by:
1. Finding conflict markers
2. Deciding which changes to keep
3. Removing conflict markers
4. Saving the file

#### Option C: Using Git Merge Tool

```bash
# Use Git's default merge tool
git mergetool

# Or specify a tool
git mergetool --tool=vimdiff
```

### Step 7: Mark Conflicts as Resolved

After resolving each file:

```bash
# Stage the resolved file
git add specification/example/resource.json

# Verify status
git status
```

### Step 8: Complete the Merge/Rebase

#### If you used `git merge`:

```bash
# Commit the merge
git commit -m "Resolve merge conflicts with main"
```

#### If you used `git rebase`:

```bash
# Continue the rebase
git rebase --continue
```

If there are more conflicts, repeat steps 6-8 until the rebase is complete.

### Step 9: Push Your Changes

```bash
# Force push if you rebased (rewrites history)
git push origin your-feature-branch --force

# Or regular push if you merged
git push origin your-feature-branch
```

⚠️ **Warning**: `--force` (or `-f`) rewrites history. Only use it on your feature branches, never on shared branches like main.

### Step 10: Verify the PR

1. Go to your Pull Request on GitHub
2. Verify that the "Merge conflicts" message is gone
3. Check that CI/CD pipelines pass
4. Request review if needed

## Common Conflict Scenarios

### Scenario 1: JSON Specification Conflicts

When two developers modify the same API specification:

```json
<<<<<<< HEAD
{
  "apiVersion": "2024-01-01",
  "title": "My API"
}
=======
{
  "apiVersion": "2024-02-01",
  "title": "Updated API"
}
>>>>>>> main
```

**Resolution**: 
- Determine which version is correct or if both changes should be merged
- Keep the most recent API version
- Combine title changes if both are valid

### Scenario 2: Multiple Files with Conflicts

```bash
# Resolve each file individually
git add file1.json
git add file2.json
git add file3.json

# Continue rebase or commit merge
git rebase --continue  # or git commit
```

### Scenario 3: Binary File Conflicts

For binary files (images, PDFs), you must choose one version:

```bash
# Keep your version
git checkout --ours path/to/binary-file

# Keep the main branch version
git checkout --theirs path/to/binary-file

# Stage the resolved file
git add path/to/binary-file
```

## Aborting Conflict Resolution

If you want to start over:

```bash
# Abort a merge
git merge --abort

# Abort a rebase
git rebase --abort
```

This returns your branch to its state before the merge/rebase.

## Best Practices

1. **Sync regularly**: Frequently pull from upstream to minimize conflicts
   ```bash
   git fetch upstream
   git merge upstream/main
   ```

2. **Small commits**: Make smaller, focused commits that are easier to merge

3. **Communicate**: If working on the same files as others, coordinate changes

4. **Review carefully**: After resolving conflicts, review all changes to ensure nothing was lost

5. **Test**: Run tests after conflict resolution to ensure functionality

6. **Keep clean history**: Consider rebasing for a cleaner history (for feature branches only)

## Troubleshooting

### "Cannot rebase: You have unstaged changes"

```bash
# Stash your changes
git stash

# Do the rebase
git rebase main

# Reapply your changes
git stash pop
```

### "Your branch and 'origin/your-branch' have diverged"

This happens after rebasing. Force push to update the remote:

```bash
git push origin your-feature-branch --force-with-lease
```

`--force-with-lease` is safer than `--force` as it prevents overwriting others' work.

### Conflict in Package Files

For `package-lock.json` or similar dependency files:

```bash
# Remove the file
git rm package-lock.json

# Regenerate it
npm install

# Stage the regenerated file
git add package-lock.json
```

## Getting Help

If you're stuck:
1. Ask in the repository's discussions or issues
2. Provide the output of `git status` and `git log --oneline -5`
3. Describe what you've tried
4. Share the conflict markers if it's not sensitive

## Additional Resources

- [Git Documentation on Merge Conflicts](https://git-scm.com/docs/git-merge#_how_conflicts_are_presented)
- [Atlassian Git Merge Tutorial](https://www.atlassian.com/git/tutorials/using-branches/merge-conflicts)
- [GitHub Resolving Conflicts](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/addressing-merge-conflicts/resolving-a-merge-conflict-using-the-command-line)

## Quick Reference Commands

```bash
# Setup
git remote add upstream https://github.com/Azure/azure-rest-api-specs.git
git fetch upstream

# Update main
git checkout main
git pull upstream main

# Rebase approach (preferred)
git checkout feature-branch
git rebase main
# Resolve conflicts
git add <resolved-files>
git rebase --continue
git push --force-with-lease

# Merge approach (alternative)
git checkout feature-branch
git merge main
# Resolve conflicts
git add <resolved-files>
git commit
git push

# Abort if needed
git rebase --abort  # or git merge --abort
```
