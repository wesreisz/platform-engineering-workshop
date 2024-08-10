const http = require("http");
  http
   .createServer(function(request, response){
       console.log("request received");
       response.end("Hello World", "utf-8")
   })
   .listen(3000)
  console.log("server running: localhost:3000");
