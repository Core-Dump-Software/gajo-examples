// Your plan and remaining monthly links. Usage: node usage.js
import { Gajo } from './gajo.js';

const usage = await new Gajo().usage();
console.log(`${usage.plan} plan: ${usage.urlsCreatedThisMonth} of ${usage.urlsMonthlyLimit} links used this month, ${usage.urlsRemaining} left`);
console.log(`${usage.requestsPerMinute} API requests per minute`);
