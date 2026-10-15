// Click stats for one link, bots excluded. Usage: node link-stats.js <shortCode>
import { Gajo } from './gajo.js';

const code = process.argv[2];
if (!code) {
  console.error('Usage: node link-stats.js <shortCode>');
  process.exit(1);
}

const stats = await new Gajo().stats(code);
console.log(`${stats.totalClicks} clicks in total`);
for (const day of stats.clicksByDay ?? []) {
  console.log(`  ${day.date}  ${day.clicks}`);
}
// referrers, devices, countries, and regions are filled in on Basic and Pro
for (const referrer of stats.topReferrers ?? []) {
  console.log(`  from ${referrer.source}: ${referrer.count}`);
}
