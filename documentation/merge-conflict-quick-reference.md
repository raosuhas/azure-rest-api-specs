# Quick Reference: Resolving Merge Conflicts

## TL;DR - Quick Commands

```bash
# Add upstream remote (one-time setup)
git remote add upstream https://github.com/Azure/azure-rest-api-specs.git

# Fetch latest changes
git fetch upstream

# Update your feature branch (choose one method)

# Method 1: Rebase (recommended)
git rebase upstream/main
# If conflicts, resolve them, then:
git add <resolved-files>
git rebase --continue
git push --force-with-lease

# Method 2: Merge (alternative)
git merge upstream/main
# If conflicts, resolve them, then:
git add <resolved-files>
git commit
git push
```

## Using the Helper Script

```bash
# Run from repository root
./documentation/scripts/resolve-conflicts.sh
```

The script will:
- ✓ Check your current branch
- ✓ Configure upstream remote if needed
- ✓ Fetch latest changes
- ✓ Handle uncommitted changes
- ✓ Guide you through rebase or merge
- ✓ List conflicted files
- ✓ Open files in your editor

## Understanding Conflict Markers

When you open a conflicted file, you'll see:

```
<<<<<<< HEAD (your changes)
Your code here
=======
Incoming changes from main
>>>>>>> main
```

**To resolve:**
1. Decide which changes to keep
2. Edit the file to the final desired state
3. Remove ALL conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
4. Save the file
5. Stage with `git add <file>`

## Common Scenarios

### Scenario 1: JSON Specification Conflict

```json
<<<<<<< HEAD
{
  "version": "2024-01-01",
  "property": "yourValue"
}
=======
{
  "version": "2024-02-01",
  "property": "theirValue"
}
>>>>>>> main
```

**Resolution:**
- Keep the most recent version
- Merge non-conflicting properties
- Ensure valid JSON syntax

```json
{
  "version": "2024-02-01",
  "property": "yourValue"
}
```

### Scenario 2: Multiple Files

```bash
# Resolve each file
vim file1.json
git add file1.json

vim file2.json
git add file2.json

# Continue
git rebase --continue  # or git commit for merge
```

### Scenario 3: Binary Files

```bash
# Keep your version
git checkout --ours path/to/file

# Keep their version
git checkout --theirs path/to/file

# Stage the chosen version
git add path/to/file
```

## Aborting

If you want to start over:

```bash
# Abort a rebase
git rebase --abort

# Abort a merge
git merge --abort
```

## After Resolving

### If you used rebase:
```bash
git push origin your-branch --force-with-lease
```

### If you used merge:
```bash
git push origin your-branch
```

## Visual Studio Code Tips

When using VS Code:
1. Open the conflicted file
2. Look for inline buttons above conflict markers:
   - **Accept Current Change** (your changes)
   - **Accept Incoming Change** (main branch)
   - **Accept Both Changes**
   - **Compare Changes**
3. Click the appropriate button
4. Save the file
5. Stage with Git panel or `git add`

## Troubleshooting

### "You have unstaged changes"
```bash
git stash
git rebase upstream/main
git stash pop
```

### "Your branch has diverged"
This is normal after rebasing. Force push:
```bash
git push --force-with-lease
```

### Package lock files
```bash
git rm package-lock.json
npm install
git add package-lock.json
```

## Getting Help

If stuck, provide in your issue:
```bash
git status
git log --oneline -5
git remote -v
```

## Full Documentation

For complete instructions, see:
- [Detailed Merge Conflict Guide](./merge-conflict-resolution.md)

## Best Practices

✓ Sync regularly with upstream  
✓ Make small, focused commits  
✓ Test after resolving conflicts  
✓ Use `--force-with-lease` instead of `--force`  
✓ Review changes carefully before pushing  

## Important Warnings

⚠️ Never force-push to `main` branch  
⚠️ Always review resolved conflicts  
⚠️ Run tests after conflict resolution  
⚠️ Don't commit conflict markers  
