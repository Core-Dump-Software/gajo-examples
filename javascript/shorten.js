// Shorten a link. Usage: node shorten.js <url> [lifetimeDays]
import { Gajo, GajoError } from './gajo.js';

const [url, lifetimeDays] = process.argv.slice(2);
if (!url) {
  console.error('Usage: node shorten.js <url> [lifetimeDays]');
  process.exit(1);
}

const gajo = new Gajo();
try {
  const link = await gajo.shorten(url, lifetimeDays ? { lifetimeDays: Number(lifetimeDays) } : {});
  console.log(gajo.shortUrl(link));
  console.log(`expires: ${link.expiresDate ?? 'never'}`);
} catch (error) {
  if (!(error instanceof GajoError)) throw error;
  console.error(`Gajo error ${error.status}: ${error.message}`);
  process.exit(1);
}
