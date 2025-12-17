---
title: New Repo Setup Checklist
description: Quick checklist to wire Cursor rules and context templates into a repository.
---

# New Repo Setup Checklist

## Setup rules

- [ ] Add the rules (recommended: submodule + symlink):

```bash
git submodule add https://github.com/d-padmanabhan/cursor-engineering-rules.git .cursor-rules
mkdir -p .cursor
ln -s ../.cursor-rules/rules .cursor/rules
```

- [ ] Confirm `.cursor/rules` points where you expect:

```bash
ls -la .cursor/rules
readlink .cursor/rules
```

## Setup workspace context files

- [ ] Create `extras/` (workspace-local, gitignored)
- [ ] Create `extras/tasks.md` (minimum)

```bash
mkdir -p extras
cp .cursor/rules/templates/tasks.md.template extras/tasks.md
```

Optional (for complex work):

- [ ] `extras/project-brief.md`
- [ ] `extras/active-context.md`
- [ ] `extras/progress.md`

```bash
cp .cursor/rules/templates/project-brief.md.template extras/project-brief.md
cp .cursor/rules/templates/active-context.md.template extras/active-context.md
cp .cursor/rules/templates/progress.md.template extras/progress.md
```

## Git hygiene (recommended)

- [ ] Ensure `extras/` is ignored (add to your repo’s `.gitignore`):

```gitignore
# Private/local documentation
extras/
```
