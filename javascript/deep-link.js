// Pro: a link that opens your app, falling back to the App Store, Google Play, or your site
// when the app isn't installed.
// Usage: node deep-link.js <appUrl> <fallbackUrl>
// Example: node deep-link.js myapp://product/42 https://apps.apple.com/app/id123456789
import { Gajo } from './gajo.js';

const [appUrl, fallbackUrl] = process.argv.slice(2);
if (!appUrl || !fallbackUrl) {
  console.error('Usage: node deep-link.js <appUrl> <fallbackUrl>');
  process.exit(1);
}

const gajo = new Gajo();
const link = await gajo.shorten(appUrl, { fallbackUrl });
console.log(`${gajo.shortUrl(link)} opens ${link.originalUrl}, or ${link.fallbackUrl} without the app`);
