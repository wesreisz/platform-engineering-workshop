NOTE: If you already have cluster from the previous section, skip to step 2

1 - Create a cluster. We're also setting up a registry inside the cluster that we'll use for images. Note: There isn't a UI on this registry.
```bash
k3d cluster create mycluster --agents 3 --registry-create registry.localhost:5000 -p "80:80@loadbalancer"
```

2 - Ensure helm is installed. It should already be installed on the VDI in the classroom.
```bash
brew install helm
helm repo add gitea-charts https://dl.gitea.io/charts/
helm repo update
```

3 - Install Gitea - Wait for the Gitea pods to be ready (this may take about a minute). Make sure you're in the 2-pipelines folder. Also note the default install, includes redis and postgres in HA mode, so it will take a second to spin up. Things will show red while that happens.
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
For this next piece, we're creating a docker runner to be able to build images for us. In order to create the runner, we will need 
to get a key from the UI. In the upper right corner of the Gitea UI, click on the dropdown for profile and settings. Select settings 
from the dropdown. Look for Action in the leftside menu, and click on runners. When it loads, back on the right you will see "Create 
a Runner". Click on that and copy the registration token into your buffer. Open the file deploy-runner-container in th3 pipelines folder
of the git project you checked out and update the token in the yaml file (it's at the end). Once you've done that, apply the yaml below

``` bash
kubectl apply -f deploy-runner-container.yaml
```

Your runner should create in the cluster and once completed, be visible in gitea when clicking on the 'Runners' menu item

6 - Create a repo This script checksout the tilt-avatar code and changes the origin to point to your new gitea instance.
`bash create-repo.sh <gitea-username> <gitea-password>`

7 - Review your Action and build
# your pipeline file is under .github/workflows
You will see that a container was built and pushed until the actions tab in the ui