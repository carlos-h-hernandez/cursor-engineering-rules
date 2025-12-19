# Cursor Commands

Cursor commands for workflow phase transitions. These provide "progressive disclosure" - loading context only when explicitly triggered.

## Installation

Copy the `commands/` folder to your project's `.cursor/` directory:

```bash
# From your project root
cp -r /path/to/cursor-engineering-rules/commands .cursor/commands
```

Or symlink:

```bash
ln -s /path/to/cursor-engineering-rules/commands .cursor/commands
```

## Available Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/init` | Initialize task | Starting new work, detecting complexity |
| `/plan` | Enter planning phase | Designing solution, documenting approach |
| `/creative` | Enter creative/design phase | Complex tasks requiring design decisions |
| `/qa` | Run QA validation | Before implementation (Level 2+ tasks) |
| `/build` | Enter implementation phase | After plan is approved |
| `/review` | Enter review phase | After implementation complete |
| `/archive` | Archive completed task | Document lessons learned (Level 3-4) |

## Workflow

### Simple Tasks (Level 1)

```
/init -> /build -> /review
```

### Moderate Tasks (Level 2)

```
/init -> /plan -> /qa -> /build -> /review
```

### Complex Tasks (Level 3-4)

```
/init -> /plan -> /creative -> /qa -> /build -> /review -> /archive
```

## Usage

Type the command in Cursor chat:

```
/plan Add user authentication to the application
```

The AI will enter that phase and follow the corresponding workflow guidelines.

## Relationship to Rules

Commands trigger specific behaviors but work alongside rules:

- **Commands** - Explicit phase transitions (`/plan`, `/build`)
- **Rules** - Standards that apply based on file patterns (`.mdc` files)
- **MCP Server** - On-demand rule loading via tool calls

Use all three together for maximum flexibility.
