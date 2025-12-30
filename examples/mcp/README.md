# MCP Configuration Examples

These files are **examples/templates** to help you configure MCP servers for AI coding assistants.

> [!IMPORTANT]
> These examples are **not authoritative** and may drift from upstream MCP server changes.
> Always review upstream docs and pin versions where you need repeatability.

## Available Example Files

### Complete Configuration (Recommended)

**File**: [`mcpServers.complete.example.json`](./mcpServers.complete.example.json)

All servers combined in priority order (14 servers total):

1. Core development tools (filesystem, git, context7, shellwright)
2. Version control (github-remote)
3. AWS services (aws-ccapi, aws-docs, iam-policy-autopilot)
4. Cloudflare services (6 servers)

**Recommended for**: Most users. Start here, then delete any servers you don’t want.

### GitHub Integration (Optional)

**File**: [`mcpServers.github_remote.example.json`](./mcpServers.github_remote.example.json)

Standalone GitHub remote MCP server:

- **github-remote** - Repos, PRs, issues, Actions (remote hosted)

---

## Quick Start

### 1. Choose Your Configuration

Start with the configuration that matches your needs:

- **Recommended**: Use `mcpServers.complete.example.json`, then remove servers you don’t want.
- **Only GitHub remote tooling**: Use `mcpServers.github_remote.example.json`.

### 2. Set Environment Variables

Create or update your shell profile (`~/.zshrc`, `~/.bashrc`):

```bash
# Core Development Tools
export MCP_FILESYSTEM_ROOT="/Users/yourusername/code"

# Shellwright (optional customization)
export THEME="one-dark"
export FONT_SIZE="14"
export FONT_FAMILY="Hack, Monaco, Courier, monospace"
export TEMP_DIR="/tmp/shellwright"

# AWS Services
export AWS_REGION="us-east-1"
export FASTMCP_LOG_LEVEL="ERROR"
export DEFAULT_TAGS="enabled"
export SECURITY_SCANNING="enabled"

# GitHub (if using github-remote)
export GITHUB_MCP_PAT="your_github_personal_access_token_here"
```

> [!WARNING]
> Treat `GITHUB_MCP_PAT` as a secret. Do not commit it to git or paste it into JSON config files.
>
> [!TIP]
> Only set the environment variables needed for the servers you enable. For example, if you use only `mcpServers.github_remote.example.json`, you only need `GITHUB_MCP_PAT`.

### 3. Configure Your AI Assistant

#### Cursor

1. Create project MCP config:

```bash
mkdir -p .cursor
```

1. Copy your chosen example to `.cursor/mcp.json`:

```bash
# For complete configuration
cp mcpServers.complete.example.json .cursor/mcp.json
```

1. Cursor expects a top-level `servers` object. Edit `.cursor/mcp.json` and change `mcpServers` to `servers`:

```json
{
  "servers": {
    "filesystem": { ... },
    "git": { ... }
  }
}
```

#### Claude Desktop

1. Open Claude Desktop config:

```bash
# macOS
code ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

1. Copy the contents of your chosen example file directly (no need to change `mcpServers` to `servers`).

---

## Priority-Based Organization

The complete example follows this priority order for optimal AI agent performance:

### Tier 1: Core Development (Most Frequently Used)

- `filesystem` - Essential for all file operations
- `git` - Essential for version control
- `context7` - Maintains conversation context
- `shellwright` - Terminal automation

### Tier 2: Collaboration

- `github-remote` - GitHub operations

### Tier 3: Cloud Services (Used When Needed)

- AWS servers (aws-ccapi, aws-docs, iam-policy-autopilot)
- Cloudflare servers (6 services)

This ordering ensures AI agents prioritize local development tools before cloud services.

---

## Environment Variable Patterns

All examples use `${env:VARIABLE_NAME}` placeholders for flexibility:

### Required Variables

| Variable | Example | Used By | Required? |
|----------|---------|---------|-----------|
| `MCP_FILESYSTEM_ROOT` | `/Users/you/code` | filesystem | Yes |
| `AWS_REGION` | `us-east-1` | iam-policy-autopilot | Yes |
| `GITHUB_MCP_PAT` | `ghp_...` | github-remote | Yes |

### Optional Variables

| Variable | Default | Used By | Purpose |
|----------|---------|---------|---------|
| `FASTMCP_LOG_LEVEL` | `INFO` | aws-ccapi | Logging level |
| `DEFAULT_TAGS` | `disabled` | aws-ccapi | Auto-tagging resources |
| `SECURITY_SCANNING` | `disabled` | aws-ccapi | Checkov security scanning |
| `THEME` | `one-dark` | shellwright | Terminal color theme |
| `FONT_SIZE` | `14` | shellwright | Terminal font size |
| `FONT_FAMILY` | `Hack, Monaco, ...` | shellwright | Terminal font |
| `TEMP_DIR` | `/tmp/shellwright` | shellwright | Recording frames directory |

---

## Server Types

### stdio (Standard Input/Output)

Servers that communicate via standard input/output streams. These are typically Node.js or Python packages executed locally using `npx` or `uvx`.

**Examples**: filesystem, git, context7, shellwright, aws-ccapi, aws-docs, iam-policy-autopilot

### http (HTTP/HTTPS)

Remote servers accessed via HTTP(S) endpoints. These are hosted services provided by the respective vendors.

**Examples**: github-remote, cloudflare-* servers

---

## Prerequisites

### Required Tools

Install these tools before using the MCP servers:

```bash
# Node.js (for npx-based servers)
brew install node

# Python with uvx (for AWS servers)
brew install python
pip install uv

# Verify installations
npx --version
uvx --version
```

### Optional Tools

For enhanced functionality:

```bash
# fd - Fast file search (alternative to find)
brew install fd

# fzf - Fuzzy finder for interactive search
brew install fzf
$(brew --prefix)/opt/fzf/install  # Install shell integrations

# ripgrep - Fast text search (alternative to grep)
brew install ripgrep
```

---

## Security Best Practices

### 1. Scope Filesystem Access

Always set `MCP_FILESYSTEM_ROOT` to the minimum required directory:

```bash
# Good: Scoped to code directory
export MCP_FILESYSTEM_ROOT="/Users/you/code"

# Bad: Full filesystem access
export MCP_FILESYSTEM_ROOT="/"
```

### 2. Use Read-Only Tokens

For GitHub and Cloudflare:

- Use tokens with minimal required scopes
- Create separate tokens for different projects
- Rotate tokens regularly

### 3. Environment Variables Only

Never hardcode secrets in JSON configuration files:

```json
// Good: Use environment variable
{
  "headers": {
    "Authorization": "Bearer ${env:GITHUB_MCP_PAT}"
  }
}

// Bad: Hardcoded secret
{
  "headers": {
    "Authorization": "Bearer ghp_1234567890abcdef"
  }
}
```

### 4. Enable Security Scanning

For AWS work, always enable security scanning:

```bash
export SECURITY_SCANNING="enabled"
export DEFAULT_TAGS="enabled"
```

---

## Troubleshooting

### Server Not Starting

```bash
# Check package availability
npx -y @modelcontextprotocol/server-filesystem --version
uvx awslabs.ccapi-mcp-server@latest --version

# Verify environment variables
echo $MCP_FILESYSTEM_ROOT
echo $AWS_REGION
```

### Authentication Failures

```bash
# Verify GitHub token
curl -H "Authorization: Bearer $GITHUB_MCP_PAT" https://api.github.com/user

# Test AWS credentials
aws sts get-caller-identity
```

### Permission Errors

```bash
# Check filesystem permissions
ls -la $MCP_FILESYSTEM_ROOT

# Verify AWS IAM permissions
aws iam get-user
```

---

## Updating Servers

### Update All npm Packages

```bash
npm update -g @modelcontextprotocol/server-filesystem
npm update -g @modelcontextprotocol/server-git
npm update -g @upstash/context7-mcp
npm update -g @dwmkerr/shellwright
```

### Update AWS Servers

```bash
uvx --upgrade awslabs.ccapi-mcp-server@latest
uvx --upgrade awslabs.aws-documentation-mcp-server@latest
uvx --upgrade iam-policy-autopilot
```

### Pin Versions (Production)

For production stability, pin specific versions:

```json
{
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem@1.2.3"]
}
```

---

## Example Use Cases

### 1. Reading Source Code Files

**Server**: `filesystem`

```
AI: "Show me the contents of src/main.py"
```

### 2. Git Operations

**Server**: `git`

```
AI: "Create a new branch called feature/auth"
AI: "Show me the git diff for the current branch"
```

### 3. Terminal Automation

**Server**: `shellwright`

```
AI: "Open vim, write 'Hello World', save and quit. Give me a GIF of the process."
AI: "Run 'kubectl get pods' and capture a screenshot."
```

### 4. AWS Infrastructure

**Server**: `aws-ccapi`

```
AI: "Create an S3 bucket named 'my-app-logs' with versioning enabled"
AI: "Generate a CloudFormation template for an RDS PostgreSQL instance"
```

### 5. IAM Policy Generation

**Server**: `iam-policy-autopilot`

```
AI: "Analyze lambda_function.py and generate the minimal IAM policy needed"
AI: "Fix this AccessDenied error: User is not authorized to perform s3:GetObject"
```

### 6. GitHub Operations

**Server**: `github-remote`

```
AI: "Create a PR for the current branch"
AI: "List all open issues in the repository"
```

---

## Migration Guide

### Adopt the complete example (recommended)

If you want a single starting point, use `mcpServers.complete.example.json` and then prune servers you don’t need.

1. **Backup your current config**:

   ```bash
   cp .cursor/mcp.json .cursor/mcp.json.backup
   ```

2. **Copy complete example**:

   ```bash
   cp mcpServers.complete.example.json .cursor/mcp.json
   ```

3. **Update server object name**:

   ```bash
   sed -i '' 's/"mcpServers"/"servers"/' .cursor/mcp.json
   ```

4. **Verify environment variables** are set (see Environment Variables section)

5. **Restart your AI assistant** to load new servers

---

## Notes

- The AWS examples use `uvx` to run the servers. You'll need Python tooling that provides `uvx`.
- The Cloudflare entries are HTTP MCP endpoints - no local installation required.
- Node.js servers use `npx -y` to auto-install packages on first use.
- All examples include `metadata` for better discoverability in AI assistants.

---

## Resources

### Official Documentation

- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [MCP Registry](https://github.com/modelcontextprotocol/registry)
- [MCP SDK](https://github.com/modelcontextprotocol/sdk)

### Server Documentation

- [Filesystem MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem)
- [Git MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/git)
- [Context7](https://github.com/upstash/context7-mcp)
- [Shellwright](https://github.com/dwmkerr/shellwright)
- [AWS MCP Servers](https://github.com/awslabs/mcp)
- [Cloudflare MCP](https://developers.cloudflare.com/mcp/)

---
