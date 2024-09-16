# Flux Workshop: CI/CD with a Simple Website



Delete the existing kind cluster:

```bash
k3d cluster delete mycluster
```
Create a new kind cluster:
```bash
k3d cluster create mycluster --agents 2 --registry-create mycluster-registry:0.0.0.0:5000

```
Configure Docker to Push Images to k3d Registry
Once your cluster is up, you'll need to configure Docker to push images to this local registry. You can test the connection with:

```bash
docker pull alpine
docker tag alpine localhost:5000/alpine
docker push localhost:5000/alpine
```

### Step 5: Install Gitea for Git Server Functionality
Add the Gitea Helm chart repository:


```bash
brew install helm
helm repo add gitea-charts https://dl.gitea.io/charts/
helm repo update
```

Create the gitea namespace:

```bash
kubectl create namespace gitea
```

Install Gitea using Helm:

```bash
helm install gitea gitea-charts/gitea -n gitea
```

* Wait for the Gitea pods to be ready (this may take about a minute).

## Step 6: Expose Gitea Using kubectl port-forward

Forward port 3000 to access Gitea:

``` bash
kubectl port-forward svc/gitea-http -n gitea 3000:3000
```

* Note: Open a new terminal tab to continue executing further commands.

Access Gitea in your browser at:

http://localhost:3000

## Step 7: Register a User in Gitea
Open the Gitea web interface at http://localhost:3000.

Click on "Register" to create a new user account.

Fill out the registration form to create the new user. This user will have administrative privileges by default if it is the first user created.


### Step 8: Initialize a Local Git Repository and Push to Gitea
We're going to clone a GitHub repository, remove the original remote, and automatically create a new repository in Gitea using your newly created credentials. This allows you to have a local copy of the project in Gitea.

To run the script, participants need to execute it with their Gitea username and password as arguments, like this: 
```bash 
bash create-repo.sh <gitea-username> <gitea-password>
``` 

### Next Step is to setup githooks to create a new docker image on code push

@Wes Feel free to have a go at this
Configure githooks to recognise when a new image needs to be created.

``` bash
code goes here
```

# BELOW NEEDS REWORKING

### Step 10: Install flux for CICD:

```bash
brew install fluxcd/tap/flux
```

Make sure to create and store your PAT Token (we use it in the next step):

https://github.com/settings/tokens

Export Git Credentials:
```bash
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>
```

### Step 11: Check your k8 cluster meets flux requirements:

```bash
flux check --pre
```


### Step 12: Bootstrap in flux the repo you'll be using:

```bash
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=react-app \
  --branch=main \
  --path=./clusters/my-cluster \
  --personal
```


Clone the git repo:
```bash
git clone https://github.com/$GITHUB_USER/react-app
cd react-app
```


Create a GitRepository manifest pointing to podinfo repository’s master branch:

```bash
flux create source git react \
    --url=https://github.com/AnaisUrlichs/react-article-display \
    --branch=main \
    --export > ./clusters/my-cluster/react-article-display-source.yaml
```

Commit and push the podinfo-source.yaml file to the fleet-infra repository:

```bash
git add -A && git commit -m "Add podinfo GitRepository"
git push
```

Use the flux create command to create a Kustomization that applies the podinfo deployment:

``` bash
flux create kustomization react-app \
  --target-namespace=default \
  --source=react \
  --path="./deploy/manifests" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/my-cluster/react-app-kustomization.yaml
```


Commit and push the Kustomization manifest to the repository:

```bash
git add -A && git commit -m "Add podinfo Kustomization"
git push
```

Use the flux get command to watch the podinfo app:

```bash
flux get kustomizations --watch
```

Check podinfo has been deployed on your cluster:

```bash
kubectl -n default get deployments,services
```

Forward a port for now until I figure out a better way:

```bash
kubectl port-forward svc/react-application 8080:8080 -n default
```

## Embedding Security in a Flux Pipeline

Create the namespace for Starboard:

``` bash
kubectl create ns trivy-system
```
Use flux cli to source starboard artifact:

``` bash
flux create source helm trivy-operator --url https://aquasecurity.github.io/helm-charts --namespace trivy-system
  ```

``` bash
flux create helmrelease trivy-operator --chart trivy-operator \
  --source HelmRepository/trivy-operator \
  --chart-version 0.24.1 \
  --namespace trivy-system
```

  Deploy the app:
``` bash
flux create kustomization react-app \\
  --target-namespace=app \\
  --source=react \\
  --path="./manifests" \\
  --prune=true \\
  --interval=5m \\
  ```

  

## Trivy command that works (CLI)
trivy k8s kind-dev --scanners vuln --report summary

## create cluster k3d

k3d cluster create MyCluster --servers 1 -p "8081:80@loadbalancer" -p "443:443@loadbalancer" --registry-create registry:0.0.0.0:80


use the inbuilt registry