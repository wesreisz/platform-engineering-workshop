**Lab 1 (Guided)** 
1 - Install k9s & k3d
`brew install k9s`
`brew install k3d`

2 - Create a cluster
```bash
K3D_FIX_DNS=0 
k3d cluster create mycluster --agents 3 --registry-create registry.localhost:5000 -p "80:80@loadbalancer"
```

NOTE: There may be a DNS issue that requires the env variable to be set to disable (K3D_FIX_DNS=0).

**imperative**
3 - Create an app
`kubectl create deployment hello-world --image wesreisz/hello-world:v2`
4 - Expose the service
`kubectl expose deployment hello-world --port 8080`
5 - Create an ingress
`kubectl create ingress hello-world --rule="/=hello-world:8080"`
6 - Scale the deployment
`kubectl scale deployment/hello-world --replicas=10`

**imperative**
7 - Create the same in a declarative way
`kubectl apply -f hello-world.yaml`