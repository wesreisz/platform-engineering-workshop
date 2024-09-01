# Argo CD Workshop: CI/CD with a Simple Website

## Set Up the Environment

Delete the existing kind cluster:

```bash
kind delete cluster --name dev
Create a new kind cluster:
```

```bash
kind create cluster --name dev --config ./create-cluster.yaml
```

## Step 2: Install Argo CD
Create the argocd namespace:

```bash
kubectl create namespace argocd
```

Install Argo CD:
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Set the context to the argocd namespace:

```bash
kubectl config set-context --current --namespace=argocd
```

Install the Argo CD CLI using Homebrew:
```bash
brew install argocd
```

Expose the Argo CD server using port forwarding:
```
bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

* Note: Open a new terminal tab to continue executing further commands.

### Step 3: Log in to Argo CD
Retrieve the initial admin password:

```bash
argocd admin initial-password -n argocd
```

Log in to Argo CD using the CLI:

```bash
argocd login localhost:8080
```

Use the username admin and the password retrieved above.

### Step 4: Connect the Kubernetes Cluster to Argo CD
Add the kind cluster to Argo CD:

``` bash
argocd cluster add kind-dev --insecure --in-cluster -y
```

NOTE: In order for the argocd-server pod to use your kube config file it 
needs to be able to resolve the ip. Kind is set to local hosts. There is
are several options, but you can use an `in-cluster` command to also make
it work: https://github.com/argoproj/argo-cd/issues/4204

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

### Step 6: Expose Gitea Using kubectl port-forward

Forward port 3000 to access Gitea:

``` bash
kubectl port-forward svc/gitea-http -n gitea 3000:3000
```

* Note: Open a new terminal tab to continue executing further commands.

Access Gitea in your browser at:

http://localhost:3000

### Step 7: Register a User in Gitea
Open the Gitea web interface at http://localhost:3000.

Click on "Register" to create a new user account.

Fill out the registration form to create the new user. This user will have administrative privileges by default if it is the first user created.

### Step 8: Create a New Repository in Gitea
Log in with the new user account you just created.

Click on "New Repository" to create a new repository.

Name the repository module-3-website and create it. Note the URL for later use.

### Step 9: Initialize a Local Git Repository and Push to Gitea
Initialize a new Git repository locally and push it to Gitea:

``` bash
Copy code
mkdir module-3-website
cd module-3-website
git init
echo "# Module 3 Website" > README.md
git add README.md
git commit -m "Initial commit"
git branch -M main
git remote add origin http://localhost:3000/<username>/<repo_name>.git
git push -u origin main
```

Replace <username> with your Gitea username and <repo_name> with the name of the repo:
ex: `http://localhost:3000/wes/test.git`

### Step 10: Create an Argo CD Application to Deploy from the Gitea Repository

Create a new Argo CD application that points to the module-3-website repository:

```bash
Copy code
argocd app create module-3-website --repo http://localhost:3000/<username>/module-3-website.git --path . --dest-server https://kubernetes.default.svc --dest-namespace default
```
//@WES - THIS DOESNT WORK - Figure out why

Replace <username> with your Gitea username.

### Step 11: Sync the Argo CD Application
Go to the Argo CD UI at http://localhost:8080/ and log in with the credentials.

Find your newly created application (module-3-website) and click on "Sync" to deploy it to your Kubernetes cluster.

Alternatively, you can sync it via the CLI:

```bash
argocd app sync module-3-website
```


### Step 12: Make a Change in the Git Repository and Watch It Auto-Deploy

//@WES - This step could be better. Modifying a readme is not very visual.

Edit the README.md or add a new file, commit the changes, and push them to Gitea:

```bash
echo "Another change" >> README.md
git add README.md
git commit -m "Updated README"
git push origin main
```

Observe the changes in the Argo CD UI.

