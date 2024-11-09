1 - Create a cluster
`k3d cluster create mycluster --agents 2 --registry-create registry.localhost:5000`

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

5 - Create a user
* Open the Gitea web interface at http://localhost:3000
* Click on "Register" to create a new user account
* Fill out the registration form to create the new user. This user will have administrative privileges by default if it is the first user created.

6 - Create a repo
This is a convenience script that clones repo and adds it to your
local gitea server.
`bash create-repo.sh <gitea-username> <gitea-password>`

7 - Install an Actions Runner for GITEA

Your pipeline needs a runner to do the building, l  ets make one in our cluster.

First we'll need to apply a configmap that associates our local registry with the runner we're about to create. Run the following:

``` bash
kubectl apply -f docker-config.yaml
```
Now save and run:

``` bash
kubectl apply -f deploy-runner-container.yaml
```

Your runner should create in the cluster and once completed, be visible in gitea when clicking on the 'Runners' menu item


8 - Review your Action and build