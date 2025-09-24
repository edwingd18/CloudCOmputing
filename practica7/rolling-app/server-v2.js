const http = require('http');
const os = require('os');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    version: 'v2.0',
    message: 'Hello from UPDATED version 2! 🚀',
    hostname: os.hostname(),
    timestamp: new Date().toISOString(),
    features: ['New UI', 'Better Performance', 'Bug Fixes']
  }));
});

const port = process.env.PORT || 8080;
server.listen(port, () => {
  console.log(`Server v2 running on port ${port}`);
});