"""Pro: shorten up to 100 links in one request. Usage: python batch.py <url> [url ...]

Each item succeeds or fails on its own; every created link counts toward your monthly allowance.
"""

import sys

from gajo import Gajo

if len(sys.argv) < 2:
    sys.exit("Usage: python batch.py <url> [url ...]")

gajo = Gajo()
for item in gajo.shorten_batch(sys.argv[1:]):
    if item["success"]:
        print(f"{gajo.short_url(item['url'])}  ->  {item['url']['originalUrl']}")
    else:
        print(f"failed: {item['originalUrl']}: {item['error']}")
