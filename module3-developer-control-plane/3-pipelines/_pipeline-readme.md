1 - Create a cluster. We're also setting up a registry inside the cluster that we'll use for images. Note: There isn't a UI on this registry.
```bash
export K3D_FIX_DNS=0
k3d cluster create mycluster --agents 2 --registry-create registry.localhost:5000
```

2 - Ensure helm is installed
```bash
brew install helm
helm repo add gitea-charts https://dl.gitea.io/charts/
helm repo update
```

3 - Install Gitea - Wait for the Gitea pods to be ready (this may take about a minute).
`helm install gitea gitea-charts/gitea --namespace gitea  --values ./values.yaml --create-namespace`

4 - Forward port 3000 to access Gitea
`kubectl port-forward svc/gitea-http -n gitea 3000:3000`

5 - Use the cluster alias in your host file so you can 
resolve inside and outside your cluster
`127.0.0.1	localhost  gitea-http.gitea.svc.cluster.local`

6 - Install an Actions Runner for GITEA

Your pipeline needs a runner to do the building, lets make one in our cluster.

First we'll need to apply a configmap that associates our local registry with the runner we're about to create. Run the following:

``` bash
kubectl apply -f docker-config.yaml
```
Now save and run:

``` bash
kubectl apply -f deploy-runner-container.yaml
```

Your runner should create in the cluster and once completed, be visible in gitea when clicking on the 'Runners' menu item

6 - Create a repo
Rewrite this script
`bash create-repo.sh <gitea-username> <gitea-password>`


7 - Review your Action and build
# your pipeline file is under .github/workflows