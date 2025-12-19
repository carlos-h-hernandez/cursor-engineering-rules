---
description: Run QA validation checks before implementation
---

# QA VALIDATION MODE ACTIVATED

You are now in **QA VALIDATION** phase.

## Purpose

Technical validation to prevent implementation failures. Run this before `/build` for Level 2+ tasks.

## Four-Point Validation

### 1. Dependency Verification

Check:

- All required packages/tools installed
- Versions compatible with requirements
- No missing dependencies

```bash
# Examples to run:
# Python: pip list, uv pip list
# Node: npm list, package.json check
# Go: go mod verify
```

### 2. Configuration Validation

Check:

- Configuration files exist and are valid
- Syntax correct (JSON, YAML, TOML)
- Platform compatibility (Windows/macOS/Linux)
- Required settings present

### 3. Environment Validation

Check:

- Build tools available (npm, pip, make, etc.)
- Permissions sufficient
- Environment variables set (if needed)
- Required ports available

### 4. Minimal Build Test

Check:

- Build process works
- Core functionality testable
- No blocking errors

```bash
# Examples:
# Python: python -c "import main_module"
# Node: npm run build
# Go: go build ./...
```

## Output Format

### Success Report

```
✅ QA VALIDATION PASSED

1️⃣ Dependencies: All required packages installed
2️⃣ Configuration: Valid and platform-compatible
3️⃣ Environment: Build tools ready
4️⃣ Build Test: Core functionality verified

-> Clear to proceed to /build
```

### Failure Report

```
❌ QA VALIDATION FAILED

Issues found:

1️⃣ DEPENDENCY ISSUES:
   - Missing: [package name]
   - Fix: [command to install]

2️⃣ CONFIGURATION ISSUES:
   - File: [config file]
   - Problem: [description]
   - Fix: [how to fix]

3️⃣ ENVIRONMENT ISSUES:
   - Missing: [tool/permission]
   - Fix: [how to resolve]

4️⃣ BUILD TEST ISSUES:
   - Error: [error message]
   - Fix: [how to resolve]

⛔ IMPLEMENTATION BLOCKED until issues resolved.
Run /qa again after fixing.
```

## Common Fixes

**Dependency Issues:**

- `npm install`, `pip install -r requirements.txt`, `uv sync`

**Configuration Issues:**

- Validate JSON/YAML syntax
- Check for missing required keys

**Environment Issues:**

- Install missing tools
- Fix file permissions
- Set environment variables

**Build Issues:**

- Check error messages
- Verify minimal configuration
