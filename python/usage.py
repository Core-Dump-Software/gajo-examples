"""Your plan and remaining monthly links. Usage: python usage.py"""

from gajo import Gajo

usage = Gajo().usage()
print(
    f"{usage['plan']} plan: {usage['urlsCreatedThisMonth']} of {usage['urlsMonthlyLimit']} links used this month, "
    f"{usage['urlsRemaining']} left"
)
print(f"{usage['requestsPerMinute']} API requests per minute")
