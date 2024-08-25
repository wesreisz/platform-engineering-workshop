kind create cluster --name dev --config ./create-cluster.yaml
 2164* k9s
 2165  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
 2166  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.2/cert-manager.yaml
 2167  pwd
 2168  cd..
 2169  cd ..
 2170  mkdir sample-app
 2171  cd sample-app
 2172  ls
 2173  cat <<EOF > Dockerfile\nFROM node:12-stretch\nCOPY index.js index.js\nCMD ["node", "index.js"]\nEOF
 2174  ls
 2175  cat Dockerfile
 2176  cat <<EOF > index.js\nconst http = require("http");\n  http\n   .createServer(function(request, response){\n       console.log("request received");\n       response.end("Hello World", "utf-8")\n   })\n   .listen(3000)\n  console.log("server running: localhost:3000");\nEOF
 2177  ls
 2178  docker build -t wesreisz/hello-node:v1 .
 2179  docker image ls
 2180  docker run -p 3000:3000 hello-node:v1
 2181  docker run -p 3000:3000 wesreisz/hello-node:v1
 2182* docker ps
 2183* docker kill 2006635bd0ee
 2186  docker login
 2189  kubectl create deployment hello-node --image wesreisz/hello-node:v1

```
cat <<EOF > hello-node-service.yaml
# Save to 'hello-node-service.yaml'
apiVersion: v1
kind: Service
metadata:
  name: hello-node
spec:
  ports:
  - port: 80
    targetPort: 3000
  selector:
    app: hello-node
 EOF
```   
 
 ```
cat <<EOF > hello-node-ingress.yaml
# Save to 'hello-node-ingress.yaml'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-node-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /hello(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: hello-node
            port:
              number: 80
EOF
```

kubectl apply -f hello-node-ingress.yaml

edit the yaml to move the image tag to v2 (it displays pod name and then you can cycle through the lb)


 2220  kubectl drain --ignore-daemonsets dev-worker2  
 2222  kubectl uncordon dev-worker2  
 2225  kubectl drain --ignore-daemonsets dev-worker
 2226  kubectl uncordon dev-worker


You've built and install a cluster with a load balancer in it. Then deployed an application into it


if we want to deploy an app and expose it, we can install an ingress then
`kubectl apply  -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml`
install an app 
`kubectl create deployment hello-node -n otel-demo --image wesreisz/hello-node:v1`

you can test this first with port-forwarding or through k9s
`kubectl port-forward -n otel-demo hello-node 3000:3000`

expose the deployment
`kubectl expose -n otel-demo  deployment/hello-node --port 3000`
create the ingress file
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: otel-demo-ingress
  namespace: otel-demo
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: opentelemetry-demo-frontendproxy  
            port:
              number: 8080
      - path: /wesreisz
        pathType: Prefix
        backend:
          service:
            name: hello-node  
            port:
              number: 3000 
```





