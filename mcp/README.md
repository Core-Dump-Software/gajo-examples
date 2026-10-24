# Gajo MCP server

Gajo runs a remote [MCP](https://modelcontextprotocol.io) server at `https://gajo.io/mcp` (Streamable HTTP). Connect an
AI assistant and it can shorten links, find them, and read their stats, on your plan's limits. It's listed in
[Claude's Connectors Directory](https://claude.ai/directory/connectors/gajo-url-shortener) as Gajo URL Shortener, in the
[official MCP Registry](https://registry.modelcontextprotocol.io) as `io.gajo/url-shortener`, and on
[Smithery](https://smithery.ai/servers/cds/gajo).

There are two ways to connect:

- **Sign in with your Gajo account** (OAuth). Clients that support MCP sign-in, like Claude, open a Gajo sign-in page
  the first time you use a tool. No key to copy.
- **Send an API key** as the `x-api-key` header, for clients without sign-in support or for scripts.

Both work on every plan, including Free: [sign up](https://gajo.io/account/signup) (no credit card). Your API key is
under **API → Keys**, and apps you've signed in to are under **API → Connected Apps**, where you can disconnect them.

## Tools

| Tool | What it does | Plan |
|---|---|---|
| `shorten_url` | Create a short link; Pro adds `customCode` and app deep links with `fallbackUrl` | All |
| `list_urls`, `get_url` | Find your links | All |
| `get_url_stats` | Click analytics, bots excluded | All |
| `update_url` | Change a link's destination | Pro |
| `create_app_link`, `update_app_link` | One link that sends iPhones to the App Store, Android to Google Play, and shows other devices a page with a QR code | Pro |
| `deactivate_url`, `reactivate_url` | Turn a link off, or back on | All |
| `delete_url` | Delete a link for good, erasing its destination and clicks | All |
| `get_usage` | Plan and remaining monthly quota | All |

Tool calls count against your plan's per-minute API rate limit.

## Claude (claude.ai, Desktop, and mobile)

Open [Gajo URL Shortener](https://claude.ai/directory/connectors/gajo-url-shortener) in Claude's Connectors Directory, click **Connect**, and sign in to Gajo. No API key
needed. (A custom connector with the URL `https://gajo.io/mcp` works the same way.)

## Claude Code

```bash
claude mcp add --scope user --transport http gajo https://gajo.io/mcp
```

Then run `/mcp` in a session, choose **gajo**, and **Authenticate** to sign in. To use an API key instead:

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

If your editor supports MCP sign-in, you can leave out `headers` and sign in to Gajo when it asks instead.

## Other clients

Any MCP client works: point it at `https://gajo.io/mcp` and either sign in when it asks or send
`x-api-key: YOUR_API_KEY`. Clients that only support bearer tokens can send `Authorization: Bearer YOUR_API_KEY`.

Sign-in follows the MCP authorization spec: a tool call without credentials answers `401` with a `WWW-Authenticate`
header pointing at `https://gajo.io/.well-known/oauth-protected-resource/mcp`. Gajo supports Client ID Metadata
Documents and Dynamic Client Registration, with PKCE.

The server supports MCP protocol revision 2026-07-28 (stateless, `server/discover`) as well as clients that start
with `initialize` (2025-03-26 to 2025-11-25). Listing tools doesn't need a key, so you can check the connection first:

```bash
curl -s https://gajo.io/mcp -H "Content-Type: application/json" \
  -d '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}'
```

Keep your key out of shared repositories: in a team project, prefer user-level config or your editor's secret storage.
