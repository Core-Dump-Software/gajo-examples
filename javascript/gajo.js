// A small client for the Gajo URL shortener API (https://gajo.io/docs).
// Node 18+ (built-in fetch), no dependencies. Copy this file into your project.

const DEFAULT_API_URL = 'https://gajo.io/api/v1';

export class GajoError extends Error {
  constructor(status, message, retryAfterSeconds = null) {
    super(message);
    this.name = 'GajoError';
    this.status = status;
    this.retryAfterSeconds = retryAfterSeconds;
  }
}

export class Gajo {
  /**
   * @param {object} [options]
   * @param {string} [options.apiKey]  defaults to the GAJO_API_KEY environment variable
   * @param {string} [options.apiUrl]  defaults to GAJO_API_URL, then https://gajo.io/api/v1
   */
  constructor({ apiKey = process.env.GAJO_API_KEY, apiUrl = process.env.GAJO_API_URL || DEFAULT_API_URL } = {}) {
    if (!apiKey) {
      throw new Error('Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)');
    }
    this.apiKey = apiKey;
    this.apiUrl = apiUrl.replace(/\/+$/, '');
    // short links live on the site root: https://gajo.io/{code}
    this.siteUrl = this.apiUrl.replace(/\/api\/v1$/, '');
  }

  /** The shareable URL for a link returned by the API. */
  shortUrl(link) {
    return link.isCustomCode ? `${this.siteUrl}/c/${link.shortCode}` : `${this.siteUrl}/${link.shortCode}`;
  }

  /** Shorten a URL. Options: lifetimeDays, customCode (Pro), fallbackUrl (Pro, for app deep links). */
  async shorten(url, options = {}) {
    return (await this.request('POST', '/shorten', { url, ...options })).data;
  }

  /** Pro: shorten up to 100 URLs. Each item is a URL string or a { url, ...options } object. */
  async shortenBatch(items) {
    const urls = items.map((item) => (typeof item === 'string' ? { url: item } : item));
    return (await this.request('POST', '/shorten/batch', { urls })).data;
  }

  /** One page of your links, newest first, plus the total count. */
  async listLinks({ page = 1, limit = 100 } = {}) {
    const { body, headers } = await this.request('GET', `/urls?page=${page}&limit=${limit}`, undefined, { withHeaders: true });
    return { links: body.data, total: Number(headers.get('x-total-count') ?? body.data.length) };
  }

  /** Every link on the account, fetched a page at a time. */
  async *allLinks({ limit = 500 } = {}) {
    for (let page = 1; ; page++) {
      const { links, total } = await this.listLinks({ page, limit });
      yield* links;
      if (page * limit >= total || links.length === 0) return;
    }
  }

  async getLink(code) {
    return (await this.request('GET', `/urls/${encodeURIComponent(code)}`)).data;
  }

  /** Click stats with bots excluded. Free: totals and 7 days; Basic and Pro: full breakdowns. */
  async stats(code) {
    return (await this.request('GET', `/urls/${encodeURIComponent(code)}/stats`)).data;
  }

  /** Plan, links created this month, and how many are left. */
  async usage() {
    return (await this.request('GET', '/usage')).data;
  }

  /** Pro: point an existing link somewhere else. */
  async updateDestination(code, url) {
    return (await this.request('PUT', `/urls/${encodeURIComponent(code)}`, { originalUrl: url })).data;
  }

  async deactivate(code) {
    return this.request('DELETE', `/urls/${encodeURIComponent(code)}`);
  }

  /**
   * Sends one request. Errors become GajoError with the API's message; a 429 waits for
   * Retry-After and tries once more.
   */
  async request(method, path, body, { withHeaders = false, retried = false } = {}) {
    const response = await fetch(`${this.apiUrl}${path}`, {
      method,
      headers: {
        'x-api-key': this.apiKey,
        ...(body !== undefined && { 'Content-Type': 'application/json' }),
      },
      body: body === undefined ? undefined : JSON.stringify(body),
    });

    if (response.status === 429 && !retried) {
      const wait = Number(response.headers.get('retry-after') ?? 1);
      await new Promise((resolve) => setTimeout(resolve, wait * 1000));
      return this.request(method, path, body, { withHeaders, retried: true });
    }

    const json = await response.json().catch(() => ({}));
    if (!response.ok || json.success === false) {
      const retryAfter = response.headers.get('retry-after');
      throw new GajoError(response.status, json.message || `HTTP ${response.status}`, retryAfter ? Number(retryAfter) : null);
    }
    return withHeaders ? { body: json, headers: response.headers } : json;
  }
}
