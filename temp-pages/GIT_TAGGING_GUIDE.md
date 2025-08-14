# Git Tagging Guide

## Quick Reference

### Creating Tags

#### Lightweight Tag (Simple)
```bash
# Create a simple tag
git tag v1.0.0

# Tag a specific commit
git tag v1.0.0 abc1234
```

#### Annotated Tag (Recommended)
```bash
# Create annotated tag with message
git tag -a v1.0.0 -m "Release version 1.0.0"

# Create annotated tag with editor for message
git tag -a v1.0.0
# (Opens editor for detailed message)

# Tag a previous commit
git tag -a v1.0.0 abc1234 -m "Release version 1.0.0"
```

### Viewing Tags

```bash
# List all tags
git tag

# List tags with pattern
git tag -l "v1.*"

# Show tag details
git show v1.0.0

# List tags with messages
git tag -n
git tag -n5  # Show 5 lines of annotation
```

### Pushing Tags to Remote

```bash
# Push a specific tag
git push origin v1.0.0

# Push all tags
git push origin --tags

# Push commits and tags together
git push origin main --tags
```

### Deleting Tags

```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0
# or
git push origin :refs/tags/v1.0.0
```

### Checking Out Tags

```bash
# View code at a specific tag
git checkout v1.0.0

# Create branch from tag
git checkout -b hotfix-1.0.1 v1.0.0
```

## Semantic Versioning

Use semantic versioning for your tags:
- `v1.0.0` - Major release (breaking changes)
- `v1.1.0` - Minor release (new features, backwards compatible)
- `v1.0.1` - Patch release (bug fixes)

## Best Practices

1. **Always use annotated tags for releases** - They store more information
2. **Follow a consistent naming scheme** - e.g., `v1.0.0` or `release-1.0.0`
3. **Tag after thorough testing** - Tags should mark stable points
4. **Include release notes** - Use the annotation message for changes
5. **Sign important tags** - Use `git tag -s` for GPG signing

## Example Workflow

```bash
# 1. Commit all changes
git add .
git commit -m "feat: Add new feature"

# 2. Create annotated tag
git tag -a v1.2.0 -m "Release v1.2.0

Features:
- Added new API endpoint
- Improved performance

Bug fixes:
- Fixed memory leak issue"

# 3. Push commits and tag
git push origin main
git push origin v1.2.0

# 4. Verify on GitHub
# Go to: https://github.com/username/repo/releases
```

## GitHub Release from Tag

After pushing a tag, create a GitHub release:
1. Go to your repository on GitHub
2. Click "Releases" → "Create a new release"
3. Choose your tag from the dropdown
4. Add release title and notes
5. Attach binaries if needed
6. Click "Publish release"

## Common Issues

### Forgot to push tag?
```bash
# Check if tag exists locally
git tag

# Push it
git push origin v1.0.0
```

### Wrong tag name?
```bash
# Rename tag (delete and recreate)
git tag -d old-tag
git tag -a new-tag -m "Message"
git push origin :refs/tags/old-tag
git push origin new-tag
```

### Need to update a tag?
```bash
# Force update (use with caution!)
git tag -fa v1.0.0 -m "Updated message"
git push origin -f v1.0.0
```

---

💡 **Tip**: For this project, you already have a tag created:
```bash
# Push your existing tag
git push origin v1.0.0
```