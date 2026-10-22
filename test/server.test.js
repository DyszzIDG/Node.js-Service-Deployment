const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const app = require('../src/server');

test('GET / debe responder 200 y "Hello, world!"', async (t) => {
  const server = http.createServer(app);
  await new Promise((resolve) => server.listen(0, resolve));
  const port = server.address().port;

  t.after(() => server.close());

  const response = await fetch(`http://localhost:${port}/`);
  const body = await response.text();

  assert.strictEqual(response.status, 200);
  assert.strictEqual(body, 'Hello, world!');
});

test('GET /health debe responder 200 con status ok', async (t) => {
  const server = http.createServer(app);
  await new Promise((resolve) => server.listen(0, resolve));
  const port = server.address().port;

  t.after(() => server.close());

  const response = await fetch(`http://localhost:${port}/health`);
  const data = await response.json();

  assert.strictEqual(response.status, 200);
  assert.strictEqual(data.status, 'ok');
});
