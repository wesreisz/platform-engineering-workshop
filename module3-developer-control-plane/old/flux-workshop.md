# Flux Workshop: CI/CD with a Simple Website

### Step 1: Create the cluster with a local registry

Delete the existing kind cluster:

```bash
k3d cluster delete mycluster
```
Create a new kind cluster:
```bash
k3d cluster create mycluster --agents 2 --registry-create registry.localhost:5000
```

**Note: when I do this, my cluster hangs in creating. It's unable to talk to registry where
the images are stored. Adding `K3D_FIX_DNS=0 k3d` to the create cluster command (at the beginning)
fixed it. This was the issue: https://github.com/k3d-io/k3d/issues/1449**


### Step 2: Install Gitea for Git Server Functionality
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

### Step 3: Expose Gitea Using kubectl port-forward

Forward port 3000 to access Gitea:

``` bash
kubectl port-forward svc/gitea-http -n gitea 3000:3000
```

* Note: Open a new terminal tab to continue executing further commands.

Access Gitea in your browser at:

http://localhost:3000

### Step 4: Register a User in Gitea
Open the Gitea web interface at http://localhost:3000.

Click on "Register" to create a new user account.

Fill out the registration form to create the new user. This user will have administrative privileges by default if it is the first user created.


### Step 5: Initialize a Local Git Repository and Push to Gitea
We're going to clone a GitHub repository, remove the original remote, and automatically create a new repository in Gitea using your newly created credentials. This allows you to have a local copy of the project in Gitea.

To run the script, participants need to execute it with their Gitea username and password as arguments, like this: 

``` bash 
bash create-repo.sh <gitea-username> <gitea-password>
``` 

You can run the script anywhere but i find it helpful to run this in same directory I'm reading this so I can flick between the two

### Step 6: Install an Actions Runner for GITEA

Your pipeline needs a runner to do the building, l  ets make one in our cluster.

First we'll need to apply a configmap that associates our local registry with the runner we're about to create. Run the following:

``` bash
kubectl apply -f docker-config.yaml
```

Next you'll need a registration token from gitea. Go into Gitea => Settings => Actions => Runners and click 'create new runner'. Copy the token and place it in the deploy-runner-container.yaml file under the value of GITEA_RUNNER_REGISTRATION_TOKEN.

Now save and run:

``` bash
kubectl apply -f deploy-runner-container.yaml
```

Your runner should create in the cluster and once completed, be visible in gitea when clicking on the 'Runners' menu item

### Step 7: Install flux for CICD:

Now that we have gitea set up with a potential runner, let's install our CI/CD to allow us to actually deploy something.

We're going to use flux-cd

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

Check your k8 cluster meets flux requirements:

```bash
flux check --pre
```

### Step 8: Bootstrap in flux the infra repo you'll be using:



Bootstrap the infra repo

```bash
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=react-app \
  --branch=main \
  --path=./clusters/my-cluster \
  --personal
```

Clone the infra git repo:
```bash
git clone https://github.com/$GITHUB_USER/react-app
cd react-app
```
<!-- Use the below if we decide to share all the infra as code -->
<!-- ```bash
flux create source git react \
    --url=http://gitea-http.gitea.svc.cluster.local:3000/matt/react-article-display-workshop \
    --branch=main \
    --username=matt \
    --password=12345678 \
    --export > ./clusters/my-cluster/react-article-display-source-workshop.yaml
``` -->

<!-- Commit and push the podinfo-source.yaml file to the infra repository:

```bash
git add -A && git commit -m "Add source GitRepository"
git push
``` -->

Create a GitRepository manifest pointing to repository’s main branch:

``` bash
  flux create source git react \
    --url=http://gitea-http.gitea.svc.cluster.local:3000/matt/react-article-display-workshop \
    --branch=main \
    --username=matt \
    --password=12345678
```

Create a flux image repository and tie it to our existing k3 registry

```bash
kubectl apply -f flux-image-repository.yaml 
```

Create an image update automation that writes the new version of a docker image to a repository's manifest

``` bash
kubectl apply -f flux-image-update-automation.yaml
```

Create an image policy to decide which versions of our app will be deployed

```bash
kubectl apply -f flux-image-policy.yaml
```

Use the flux create command to create a Kustomization that applies the react app deployment:

``` bash
flux create kustomization react-article-display-workshop \
  --target-namespace=default \
  --source=react \
  --path="./deploy/manifests" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/my-cluster/react-article-display-workshop-kustomization.yaml
```
*Gotcha: Make sure it doesn't append latest into the kustomize anywhere. That had me reeling for hours!

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

Make a *code* change (e.g. change a string in app.js). 

Next change the .github/workflows/build-and-push.yaml to be a version above 1.0.1 (e.g. 1.0.2) commit, push then watch everything build and deploy!

Optional: If you want to make a change and see it reflected in the app you can access it this way:

```bash
kubectl port-forward svc/react-application 8080:8080 -n default
```

### Step 9: Embedding Security in a Flux Pipeline

Create the namespace for Trivy:

``` bash
kubectl create ns trivy-system
```
Use flux cli to source trivy artifact:

``` bash
flux create source helm trivy-operator --url https://aquasecurity.github.io/helm-charts --namespace trivy-system
  ```

``` bash
flux create helmrelease trivy-operator --chart trivy-operator \
  --source HelmRepository/trivy-operator \
  --chart-version 0.24.1 \
  --namespace trivy-system
```

Type ': vuln' and watch all the vulnerability reports for the cluster arrive.

We're interested in the react-article-display report. I have intentionally used an older version of ngninx to throw up lots of vulnerabilities nginx:1.21-alpine. The flow I'm thinking is to set the dependency to ngninx:alpine, build, push and that should sort most of the problems out.

Run the below to get more detail on a report:

``` bash
kubectl describe vulnerabilityreports <YOUR-VULN-REPORT-ID>
```

(* I think I'm making an assumption that the trivy cli is installed here. Maybe add a step)
