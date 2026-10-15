"""Click stats for one link, bots excluded. Usage: python link_stats.py <shortCode>"""

import sys

from gajo import Gajo

if len(sys.argv) < 2:
    sys.exit("Usage: python link_stats.py <shortCode>")

stats = Gajo().stats(sys.argv[1])
print(f"{stats['totalClicks']} clicks in total")
for day in stats.get("clicksByDay") or []:
    print(f"  {day['date']}  {day['clicks']}")
# referrers, devices, countries, and regions are filled in on Basic and Pro
for referrer in stats.get("topReferrers") or []:
    print(f"  from {referrer['source']}: {referrer['count']}")
