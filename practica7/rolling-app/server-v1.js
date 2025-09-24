const http = require('http');
const os = require('os');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    version: 'v1.0',
    message: 'Hello from version 1!',
    hostname: os.hostname(),
    timestamp: new Date().toISOString()
  }));
});

const port = process.env.PORT || 8080;
server.listen(port, () => {
  console.log(`Server v1 running on port ${port}`);
});