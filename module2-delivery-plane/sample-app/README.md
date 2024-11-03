## sample application
1. Run locally if you have node installed
`node index.js`

2. Make sure docker is installed
`docker --version`

3. Build the project
`docker build -t wesreisz/hello-world:v2 .`

4. Run in docker
`docker run -p 8080:8080 wesreisz/hello-world:v2 .`