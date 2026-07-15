# Versioning

This project follows [Semantic Versioning](https://semver.org/).

## Version Format

`MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes and minor updates

## Creating a Release

### Automated (Recommended)

```bash
# Bump patch version (1.0.0 → 1.0.1)
./scripts/bump-version.sh

# Bump minor version (1.0.0 → 1.1.0)
./scripts/bump-version.sh minor

# Bump major version (1.0.0 → 2.0.0)
./scripts/bump-version.sh major

# Push changes and tag
git push origin main
git push origin v1.0.1
```

### Manual

```bash
# Update VERSION file
echo "1.0.1" > VERSION

# Commit
git add VERSION
git commit -m "chore: bump version to v1.0.1"

# Create tag
git tag v1.0.1 -m "Release v1.0.1"

# Push
git push origin main
git push origin v1.0.1
```

## Release Process

1. Version bump creates tag
2. Tag push triggers release workflow
3. Workflow generates changelog from commits
4. GitHub release is created automatically

## Version Guidelines

### Patch Release
- Tool version updates
- Bug fixes
- Documentation updates

### Minor Release
- New tools added
- New features (workflows, scripts)
- Configuration improvements

### Major Release
- Breaking changes to installation
- Major restructuring
- Incompatible configuration changes