# Gajo API examples

Runnable examples for the [Gajo](https://gajo.io) URL shortener API in **curl**, **JavaScript** (Node 18+, no
dependencies), and **Python**, plus setup for Gajo's **MCP server** so AI assistants can shorten links for you.

Every Gajo account, including the free plan, comes with an API key. No credit card.

## Get a key

1. [Create a free account](https://gajo.io/account/signup).
2. In your account, open **API → Keys** and generate a key.
3. Export it for the examples:

```bash
export GAJO_API_KEY="your-api-key"
```

## Shorten a link

```bash
curl -X POST https://gajo.io/api/v1/shorten \
  -H "x-api-key: $GAJO_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com/blog/launch-announcement"}'
```

The response (trimmed):

```json
{
  "success": true,
  "message": "URL shortened successfully",
  "data": {
    "shortCode": "AbCdEf",
    "originalUrl": "https://example.com/blog/launch-announcement",
    "isCustomCode": false,
    "expiresDate": "2026-12-13T12:00:00Z"
  }
}
```

The short link is `https://gajo.io/{shortCode}`, or `https://gajo.io/c/{shortCode}` when `isCustomCode` is true.

## Examples

| Task | curl | JavaScript | Python | Plan |
|---|---|---|---|---|
| Shorten a link | [shorten.sh](curl/shorten.sh) | [shorten.js](javascript/shorten.js) | [shorten.py](python/shorten.py) | All |
| List all your links (paginated) | [list-links.sh](curl/list-links.sh) | [list-links.js](javascript/list-links.js) | [list_links.py](python/list_links.py) | All |
| Click stats for a link | [link-stats.sh](curl/link-stats.sh) | [link-stats.js](javascript/link-stats.js) | [link_stats.py](python/link_stats.py) | All |
| Remaining monthly quota | [usage.sh](curl/usage.sh) | [usage.js](javascript/usage.js) | [usage.py](python/usage.py) | All |
| Custom code (`gajo.io/c/launch`) | [custom-code.sh](curl/custom-code.sh) | | | Pro |
| App deep link with a web fallback | [deep-link.sh](curl/deep-link.sh) | [deep-link.js](javascript/deep-link.js) | [deep_link.py](python/deep_link.py) | Pro |
| Shorten up to 100 links at once | [batch.sh](curl/batch.sh) | | [batch.py](python/batch.py) | Pro |
| Change where a link points | [update-destination.sh](curl/update-destination.sh) | | | Pro |
| App store link: iPhone → App Store, Android → Google Play, a page for everyone else | [app-link.sh](curl/app-link.sh) | | | Pro |
| Deactivate a link | [deactivate.sh](curl/deactivate.sh) | | | All |
| Reactivate a deactivated link | [reactivate.sh](curl/reactivate.sh) | | | All |
| Delete a link permanently (erases its destination and clicks) | [delete.sh](curl/delete.sh) | | | All |

[`javascript/gajo.js`](javascript/gajo.js) and [`python/gajo.py`](python/gajo.py) are small, dependency-light clients
you can copy into your own project.

You need curl (with [jq](https://jqlang.org) for pretty output, optional), Node 18+ (no packages), or Python 3.9+ with
`requests` (`pip install -r python/requirements.txt`).

## AI assistants (MCP)

Gajo runs a remote MCP server at `https://gajo.io/mcp`. In Claude, add [Gajo URL Shortener](https://claude.ai/directory/connectors/gajo-url-shortener) from the
Connectors Directory and sign in. Connect Claude Code, Cursor, or VS Code with your API key and ask the assistant to
shorten, list, or look up links. Setup for each is in [mcp/](mcp/README.md).

```bash
claude mcp add --scope user --transport http gajo https://gajo.io/mcp --header "x-api-key: $GAJO_API_KEY"
```

## Limits and errors

- **Monthly links:** 50 on Free, 500 on Basic, 10,000 on Pro. `GET /usage` shows what's left.
- **Requests per minute:** per key, by plan. Every response carries `X-RateLimit-Limit` and `X-RateLimit-Remaining`;
  a `429` includes `Retry-After` (seconds). The clients here wait and retry once.
- **Link lifetime:** up to 60 days on Free, 120 on Basic, unlimited on Pro.
- Errors share one shape, `{"success": false, "message": "...", "data": null}`, with the usual status codes:
  `400` invalid input, `401` missing or invalid key, `403` feature not on your plan or account not active, `404` unknown link,
  `409` custom code taken, `429` rate limited.

Plans and prices: [gajo.io/pricing](https://gajo.io/pricing).

## Reference

- [API documentation](https://gajo.io/docs)
- [OpenAPI 3.1 spec](https://gajo.io/openapi.json)
- [llms.txt](https://gajo.io/llms.txt) for AI tools
- [How Gajo compares](https://gajo.io/compare) with Bitly, Rebrandly, Dub, and Short.io

## License

MIT. See [LICENSE](LICENSE).
