"""Pro: a link that opens your app, falling back to the App Store, Google Play, or your site
when the app isn't installed.

Usage: python deep_link.py <appUrl> <fallbackUrl>
Example: python deep_link.py myapp://product/42 https://apps.apple.com/app/id123456789
"""

import sys

from gajo import Gajo

if len(sys.argv) < 3:
    sys.exit("Usage: python deep_link.py <appUrl> <fallbackUrl>")

gajo = Gajo()
link = gajo.shorten(sys.argv[1], fallbackUrl=sys.argv[2])
print(f"{gajo.short_url(link)} opens {link['originalUrl']}, or {link['fallbackUrl']} without the app")
