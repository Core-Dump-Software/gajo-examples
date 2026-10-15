"""Print every link on the account, newest first. Usage: python list_links.py"""

from gajo import Gajo

gajo = Gajo()
count = 0
for link in gajo.all_links():
    count += 1
    status = f"{link['clickCount']} clicks" if link["active"] else "inactive"
    print(f"{gajo.short_url(link)}  ->  {link['originalUrl']}  ({status})")
print(f"{count} links")
