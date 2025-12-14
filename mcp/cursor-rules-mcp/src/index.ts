#!/usr/bin/env node

import { CursorRulesMcpServer } from './server/mcp-server.js';

async function main() {
  const baseUrl = process.env.CURSOR_RULES_PATH;
  const server = new CursorRulesMcpServer(baseUrl);
  await server.start();
}

main().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
