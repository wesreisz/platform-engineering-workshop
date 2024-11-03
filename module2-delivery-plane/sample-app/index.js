const { createServer } = require('node:http');

const port = 8080;

const server = createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.write('Hello World \n\n');
  res.end(JSON.stringify(process.env));
});

server.listen(port, () => {
  console.log(`Server running on port: ${port}`);
});
