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
| `/plan` | Enter planning phase | Starting a new task, designing solution |
| `/build` | Enter implementation phase | After plan is approved |
| `/review` | Enter review phase | After implementation complete |
| `/creative` | Enter creative/design phase | Complex tasks requiring design decisions |
| `/qa` | Run QA validation | Before implementation (Level 2+ tasks) |

## Workflow

### Simple Tasks (Level 1)

```
/build -> /review
```

### Moderate Tasks (Level 2)

```
/plan -> /qa -> /build -> /review
```

### Complex Tasks (Level 3-4)

```
/plan -> /creative -> /qa -> /build -> /review
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
