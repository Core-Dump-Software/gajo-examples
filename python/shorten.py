"""Shorten a link. Usage: python shorten.py <url> [lifetimeDays]"""

import sys

from gajo import Gajo, GajoError

if len(sys.argv) < 2:
    sys.exit("Usage: python shorten.py <url> [lifetimeDays]")

gajo = Gajo()
options = {"lifetimeDays": int(sys.argv[2])} if len(sys.argv) > 2 else {}
try:
    link = gajo.shorten(sys.argv[1], **options)
except GajoError as error:
    sys.exit(f"Gajo error {error.status}: {error.message}")

print(gajo.short_url(link))
print(f"expires: {link.get('expiresDate') or 'never'}")
