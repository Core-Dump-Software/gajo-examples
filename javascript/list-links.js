// Print every link on the account, newest first. Usage: node list-links.js
import { Gajo } from './gajo.js';

const gajo = new Gajo();
let count = 0;
for await (const link of gajo.allLinks()) {
  count++;
  const status = link.active ? `${link.clickCount} clicks` : 'inactive';
  console.log(`${gajo.shortUrl(link)}  ->  ${link.originalUrl}  (${status})`);
}
console.log(`${count} links`);
