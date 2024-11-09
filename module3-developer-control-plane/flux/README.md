# Setup an Infra server
1 - Create cluser
`export K3D_FIX_DNS=0`
`k3d cluster create mycluster --agents 2 --registry-create registry.localhost:5000`

2 - Install gitea
`helm install gitea gitea-charts/gitea --namespace gitea  --values values.yaml --create-namespace` 

3 - port forward
`kubectl --namespace gitea port-forward svc/gitea-http 3000:3000`

4 - Use the cluster alias in your host file so you can 
resolve inside and outside your cluster
`127.0.0.1	localhost  repo.wesleyreisz.com dev.wesleyreisz.com gitea-http.gitea.svc.cluster.local`

5 - Check your k8 cluster meets flux requirements:
```bash
flux check --pre
```

6 - bootstrap your cluster fleet
```bash
flux bootstrap git \                                                                              
--url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/fleet-infra \
--branch=main \
--path=clusters/mycluster \
--password=gitea \     
--allow-insecure-http=true \
--username=gitea \
--token-auth=true \
--interval=30m \
--components-extra image-reflector-controller,image-automation-controller
```

7 - Create an app repo
```bash
git init
git checkout -b main
git remote add origin http://gitea-http.gitea.svc.cluster.local:3000/gitea/nginix-app.git
```

8 - Add yaml
Next, create your app’s Git repository. Clone the repository to your machine, then copy the following Kubernetes manifests, save them to your repo, and commit and push them:

``` bash manifests/deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demo-app
  template:
    metadata:
      labels:
        app: demo-app
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
```

```bash manifests/service.yml
apiVersion: v1
kind: Service
metadata:
  name: demo-app
spec:
  selector:
    app: demo-app
  ports:
    - name: nginx
      port: 80
Commit and Push
```
```bash
$ git add .
$ git commit -m "Added initial Kubernetes manifests"
$ git push
```

9 - Register your app repository as a Flux source 
```bash
flux create source git demo-app \
--url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/nginix-app \
--branch=main \
--interval=1m
```

10 - Deploy your application 
```bash
flux create kustomization demo-app \
  --target-namespace=default \
  --source=demo-app \
  --prune=true \
  --wait=true \
  --interval=5m
```


-------------working above this line-----------

11 - Add
`flux install --components-extra=image-reflector-controller,image-automation-controller`