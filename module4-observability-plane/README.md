Steps for demo of OTel
1- create cluster from module2
2- install an ingress: 
kubectl apply -n ingress -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
3- install demo app
kubectl apply --namespace otel-demo -f https://raw.githubusercontent.com/open-telemetry/opentelemetry-demo/main/kubernetes/opentelemetry-demo.yaml
4- Create an ingress
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


Pick back up with this article:
It has a good explaination of testing the failure scenerios with the demo app
https://aws.plainenglish.io/a-deep-dive-into-opentelemetry-running-the-opentelemetry-demo-7ec4fd436136