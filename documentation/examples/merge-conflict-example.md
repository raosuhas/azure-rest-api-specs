# Example: Resolving a JSON Specification Conflict

This example walks through a typical merge conflict scenario when modifying Azure REST API specifications.

## Scenario

You've been working on updating the API specification for a service. While you were working on your branch, someone else merged changes to the same specification file in the main branch.

## Initial State

### Your branch (`feature/update-api`)
```json
{
  "swagger": "2.0",
  "info": {
    "version": "2024-01-01",
    "title": "My Service API",
    "description": "Updated description with new features"
  },
  "paths": {
    "/resources": {
      "get": {
        "operationId": "Resources_List",
        "description": "Lists all resources with enhanced filtering"
      }
    }
  }
}
```

### Main branch
```json
{
  "swagger": "2.0",
  "info": {
    "version": "2024-02-01",
    "title": "My Service API",
    "description": "Enhanced service with better performance"
  },
  "paths": {
    "/resources": {
      "get": {
        "operationId": "Resources_List",
        "description": "Lists all resources"
      }
    }
  }
}
```

## Step 1: Attempt to Rebase

```bash
git checkout feature/update-api
git fetch upstream
git rebase upstream/main
```

**Output:**
```
CONFLICT (content): Merge conflict in specification/myservice/stable/2024-01-01/myservice.json
Automatic merge failed; fix conflicts and then commit the result.
```

## Step 2: View the Conflict

Opening the file shows:

```json
{
  "swagger": "2.0",
  "info": {
<<<<<<< HEAD
    "version": "2024-01-01",
    "title": "My Service API",
    "description": "Updated description with new features"
=======
    "version": "2024-02-01",
    "title": "My Service API",
    "description": "Enhanced service with better performance"
>>>>>>> main
  },
  "paths": {
    "/resources": {
      "get": {
        "operationId": "Resources_List",
<<<<<<< HEAD
        "description": "Lists all resources with enhanced filtering"
=======
        "description": "Lists all resources"
>>>>>>> main
      }
    }
  }
}
```

## Step 3: Analyze the Conflicts

Look at each conflict section:

### Conflict 1: API Version and Description
- **Your change:** Version `2024-01-01`, description mentions "new features"
- **Main branch:** Version `2024-02-01`, description mentions "better performance"
- **Decision:** Keep the newer version (`2024-02-01`) from main, but merge the descriptions

### Conflict 2: Operation Description
- **Your change:** "Lists all resources with enhanced filtering"
- **Main branch:** "Lists all resources"
- **Decision:** Your change adds value (mentions filtering), so keep it

## Step 4: Resolve the Conflicts

Edit the file to the resolved state:

```json
{
  "swagger": "2.0",
  "info": {
    "version": "2024-02-01",
    "title": "My Service API",
    "description": "Enhanced service with better performance and new features"
  },
  "paths": {
    "/resources": {
      "get": {
        "operationId": "Resources_List",
        "description": "Lists all resources with enhanced filtering"
      }
    }
  }
}
```

**Key changes made:**
1. Used the newer version `2024-02-01` from main
2. Combined both descriptions to include all improvements
3. Kept the enhanced operation description with filtering info
4. Removed ALL conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
5. Ensured valid JSON syntax

## Step 5: Validate the Resolution

Before marking as resolved, validate:

```bash
# Check JSON syntax
cat specification/myservice/stable/2024-01-01/myservice.json | jq . > /dev/null

# Look for any remaining conflict markers
grep -n "<<<<<<" specification/myservice/stable/2024-01-01/myservice.json
grep -n ">>>>>>>" specification/myservice/stable/2024-01-01/myservice.json
```

If no output from grep commands, conflicts are fully resolved.

## Step 6: Mark as Resolved

```bash
git add specification/myservice/stable/2024-01-01/myservice.json
git status
```

**Output:**
```
rebase in progress; onto abc1234
You are currently rebasing branch 'feature/update-api' on 'abc1234'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   specification/myservice/stable/2024-01-01/myservice.json
```

## Step 7: Continue the Rebase

```bash
git rebase --continue
```

If there are more conflicts in other files, repeat steps 2-6.

## Step 8: Push the Changes

```bash
# Force push is required after rebase
git push origin feature/update-api --force-with-lease
```

## Step 9: Verify on GitHub

1. Go to your Pull Request
2. Confirm "Merge conflicts" message is gone
3. Check the "Files changed" tab to verify your changes are correct
4. Wait for CI/CD checks to complete

## Common Mistakes to Avoid

❌ **Keeping conflict markers in the file**
```json
{
  "version": "2024-02-01",  <<<< This would break the JSON
```

❌ **Invalid JSON after resolution**
```json
{
  "version": "2024-02-01",
  "description": "Some text"
  "paths": {  // Missing comma after description!
```

❌ **Accidentally removing valid code**
Make sure all properties from both versions are accounted for in the resolution.

❌ **Using `git push --force` instead of `--force-with-lease`**
`--force` can overwrite other people's work; `--force-with-lease` is safer.

## Tips for Complex Conflicts

1. **Use a diff tool**: Tools like VS Code, `vimdiff`, or `meld` can help visualize conflicts
2. **Review both versions**: Use `git show HEAD:path/to/file` and `git show main:path/to/file`
3. **Test thoroughly**: Run validation and tests after resolving
4. **Ask for help**: If unsure which changes to keep, ask the other contributor or your team
5. **Check the commit history**: Use `git log` to understand what changes were made and why

## Alternative: Using VS Code

If using VS Code:

1. Open the conflicted file
2. You'll see inline buttons above each conflict:
   - **Accept Current Change** (your version)
   - **Accept Incoming Change** (main branch version)
   - **Accept Both Changes** (includes both)
   - **Compare Changes** (side-by-side view)

3. For this example:
   - Conflict 1: Click "Compare Changes" to see differences, then manually edit
   - Conflict 2: Click "Accept Current Change" to keep your enhanced description

4. Save, stage, and continue the rebase

## Summary

Resolving conflicts successfully requires:
- Understanding what each change does
- Deciding which changes to keep or merge
- Maintaining valid file syntax
- Thorough testing after resolution
- Clear communication if unsure

For more details, see the [full documentation](../merge-conflict-resolution.md).
