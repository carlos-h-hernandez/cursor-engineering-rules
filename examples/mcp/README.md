# MCP configuration examples

These files are **examples/templates** to help you configure MCP servers.

> [!IMPORTANT]
> These examples are **not authoritative** and may drift from upstream MCP server changes.
> Always review upstream docs and pin versions where you need repeatability.

## Files

- **`claude_desktop_config.common.example.json`**: A starter `mcpServers` block for common servers (AWS + Cloudflare). **Does not include** GitHub remote
- **`claude_desktop_config.github_remote.example.json`**: A separate example for the GitHub remote MCP server

## How to use (Claude Desktop)

1. Open Claude Desktop config:

```bash
code ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

1. Merge one or both example files under the top-level `mcpServers` key.

> [!TIP]
> Claude Desktop expects a single `mcpServers` object. If you copy/paste multiple examples, merge the objects (don’t nest `mcpServers` inside `mcpServers`).

## Environment variables

Some examples use environment variable placeholders.

- **AWS region**: set `AWS_REGION` (used by `iam-policy-autopilot`)
- **GitHub remote token**: set `GITHUB_MCP_PAT` (used only in the GitHub remote example)

> [!WARNING]
> Treat `GITHUB_MCP_PAT` as a secret. Do not commit it to git or paste it into JSON config files.

## Notes

- The AWS examples use `uvx` to run the servers. You’ll need Python tooling that provides `uvx`.
- The Cloudflare entries are HTTP MCP endpoints.
