# Gajo MCP server

Gajo runs a remote [MCP](https://modelcontextprotocol.io) server at `https://gajo.io/mcp` (Streamable HTTP). Connect an
AI assistant with your Gajo API key and it can shorten links, find them, and read their stats, on your plan's limits.
It's also listed in the [official MCP Registry](https://registry.modelcontextprotocol.io) as `io.gajo/url-shortener`.

Free accounts include an API key: [sign up](https://gajo.io/account/signup), then open **API → Keys**.

## Tools

| Tool | What it does | Plan |
|---|---|---|
| `shorten_url` | Create a short link; Pro adds `customCode` and app deep links with `fallbackUrl` | All |
| `list_urls`, `get_url` | Find your links | All |
| `get_url_stats` | Click analytics, bots excluded | All |
| `update_url` | Change a link's destination | Pro |
| `deactivate_url` | Turn a link off | All |
| `get_usage` | Plan and remaining monthly quota | All |

Tool calls share your key's per-minute rate limit with the REST API.

## Claude Code

```bash
claude mcp add --scope user --transport http gajo https://gajo.io/mcp --header "x-api-key: YOUR_API_KEY"
```

`--scope user` makes Gajo available in every project. Start a new session, then ask something like
*"Shorten https://example.com/launch with Gajo"*.

## Cursor

`~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "gajo": {
      "url": "https://gajo.io/mcp",
      "headers": { "x-api-key": "YOUR_API_KEY" }
    }
  }
}
```

## VS Code

`.vscode/mcp.json` in your workspace:

```json
{
  "servers": {
    "gajo": {
      "type": "http",
      "url": "https://gajo.io/mcp",
      "headers": { "x-api-key": "YOUR_API_KEY" }
    }
  }
}
```

## Other clients

Any MCP client that can send a header works: point it at `https://gajo.io/mcp` and send `x-api-key: YOUR_API_KEY`.
Clients that only support bearer tokens can send `Authorization: Bearer YOUR_API_KEY` instead.

The server supports MCP protocol revision 2026-07-28 (stateless, `server/discover`) as well as clients that start
with `initialize` (2025-03-26 to 2025-11-25). Listing tools doesn't need a key, so you can check the connection first:

```bash
curl -s https://gajo.io/mcp -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}'
```

Keep your key out of shared repositories: in a team project, prefer user-level config or your editor's secret storage.
