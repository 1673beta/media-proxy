import { readFileSync } from 'node:fs';

const repo = JSON.parse(readFileSync('./package.json', 'utf-8'));

export default {
    userAgent: `MisskeyMediaProxy/${repo.version}`,
    allowedPrivateNetworks: [],
    maxSize: 262144000,
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': '*',
    'Content-Security-Policy': `default-src 'none'; img-src 'self'; media-src 'self'; style-src 'unsafe-inline';`
}
