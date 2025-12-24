# MCP configuration examples

These files are **examples/templates** to help you configure MCP servers.

> [!IMPORTANT]
> These examples are **not authoritative** and may drift from upstream MCP server changes.
> Always review upstream docs and pin versions where you need repeatability.

## Files

- **`mcpServers.common.example.json`**: Common MCP servers (AWS + Cloudflare)
- **`mcpServers.github_remote.example.json`**: Optional GitHub remote MCP server example
- **`mcpServers.shellwright.example.json`**: Shellwright terminal automation MCP server

## How to use the common MCP servers

This section shows how to use `mcpServers.common.example.json`.

### Cursor Agent

1. Open (or create) your project MCP config:

```bash
mkdir -p .cursor
code .cursor/mcp.json
```

1. Cursor expects a top-level `servers` object. Copy the server entries from `mcpServers.common.example.json`'s `mcpServers` object and paste them under `servers`.

Example:

```json
{
  "servers": {
    "aws-docs": {
      "type": "stdio",
      "command": "uvx",
      "args": ["awslabs.aws-documentation-mcp-server@latest"]
    }
  }
}
```

> [!TIP]
> If you add more servers later, merge entries at the same level (don't nest `servers` inside `servers`).

### Claude Desktop (optional)

If you use a client that expects `mcpServers` at the top level, you can usually paste the contents of `mcpServers.common.example.json` directly into that client's config (or merge the keys under its existing `mcpServers` object).

## Optional: GitHub remote MCP server

If you want to add GitHub's remote MCP server, use `mcpServers.github_remote.example.json` and provide `GITHUB_MCP_PAT` via environment variables.

## Environment variables

Some examples use environment variable placeholders.

- **AWS region**: set `AWS_REGION` (used by `iam-policy-autopilot`)
- **GitHub remote token**: set `GITHUB_MCP_PAT` (used only in the GitHub remote example)

> [!WARNING]
> Treat `GITHUB_MCP_PAT` as a secret. Do not commit it to git or paste it into JSON config files.

## Notes

- The AWS examples use `uvx` to run the servers. You'll need Python tooling that provides `uvx`.
- The Cloudflare entries are HTTP MCP endpoints.

## Shellwright Terminal Automation

Shellwright enables AI agents to automate terminal sessions, capture screenshots, and create GIF recordings.

### Quick Setup

1. Add Shellwright to your `.cursor/mcp.json`:

```json
{
  "servers": {
    "shellwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@dwmkerr/shellwright"]
    }
  }
}
```

2. Restart Cursor to load the MCP server.

3. Use prompts like:

   - "Open Vim. Write a message saying how to close Vim. Close Vim. Give me a screenshot of each step and a GIF recording."
   - "Open htop and show the most resource intensive process. Take a screenshot."
   - "Run `ls -la` and capture a screenshot of the output."

### Configuration Options

Optional environment variables (set in your shell or `.env`):

- `THEME`: Color theme (`one-dark`, `one-light`, `dracula`, `solarized-dark`, `nord`) - Default: `one-dark`
- `FONT_SIZE`: Font size in pixels - Default: `14`
- `FONT_FAMILY`: Font family - Default: `Hack, Monaco, Courier, monospace`
- `TEMP_DIR`: Directory for recording frames - Default: `/tmp/shellwright`

Example with custom theme:

```json
{
  "servers": {
    "shellwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@dwmkerr/shellwright"],
      "env": {
        "THEME": "dracula",
        "FONT_SIZE": "16"
      }
    }
  }
}
```

### Available Tools

Shellwright provides these MCP tools:

- `shell_start` - Start a new PTY session
- `shell_send` - Send input to a session
- `shell_read` - Read the terminal buffer
- `shell_screenshot` - Capture terminal as PNG/SVG/ANSI/text
- `shell_record_start` - Start recording frames for GIF
- `shell_record_stop` - Stop recording and render GIF
- `shell_stop` - Stop a PTY session

### Example Use Cases

- **Terminal Tutorials**: Record terminal workflows as GIFs for documentation
- **Application Testing**: Automate terminal applications (vim, htop, k9s) programmatically
- **Screenshot Generation**: Capture terminal output for documentation or presentations
- **AI Agent Automation**: Enable AI agents to interact with terminal applications

See [`mcpServers.shellwright.example.json`](./mcpServers.shellwright.example.json) for a complete configuration example.

For more details, see the [Shellwright documentation](https://github.com/dwmkerr/shellwright).
