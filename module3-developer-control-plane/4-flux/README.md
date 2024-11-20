Note: we're picking up from pipelines. You will need to complete pipelines before continuing here.
This requires a git instance.


1- Install flux
`brew install fluxcd/tap/flux`

2 - Check your k8 cluster meets flux requirements:
```bash
flux check --pre
```

3 - Before we start with flux, go back to your tilt app for a second and update the images to use your internal repo in your deployment descriptors.

NOTE: Make sure your deployment files are configured to use the internal registry in the tilt-avatar projects (/deploy). 
To switch to the internal registry, swap these the comment on these two lines in your deployment descriptions (`/deploy/web.yaml` and `/deploy/api.yaml`):
```yaml api.yaml
#image: tilt-avatar-api
image: registry.localhost:5000/tilt-avatar-api:v2
```
```bash web.yaml
#image: tilt-avatar-web
image: registry.localhost:5000/tilt-avatar-web:v2
```

4 - Create a new repository in Gitea using the API
```bash
export GITEA_URL="http://gitea-http.gitea.svc.cluster.local:3000"
export GITEA_REPO_NAME="fleet-infra"
curl -u "gitea:gitea" \
     -X POST "$GITEA_URL/api/v1/user/repos" \
     -H "Content-Type: application/json" \
     -d "{\"name\":\"$GITEA_REPO_NAME\",\"private\":false}"
```

5 - bootstrap your cluster fleet
```bash
flux bootstrap git \
--url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/fleet-infra.git \
--branch=main \
--path=clusters/mycluster \
--password=gitea \
--allow-insecure-http=true \
--username=gitea \
--token-auth=true \
--interval=30m 
```

6 - Clone the repo to your home directory (or whereever you like)
`git clone http://gitea-http.gitea.svc.cluster.local:3000/gitea/fleet-infra.git`


7 - Register your app repository as a Flux source. We're using the tilt-avatars project we had before. Also this command will generate the file to register the source in your mycluster folder. It would be greated until it's commited and deployed 
```bash
flux create source git tilt-avatars \
  --url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/tilt-avatars.git \
  --branch=main \
  --interval=1m \
  --export > ./clusters/mycluster/tilt-avatars-source.yaml
```

8 - Create your Kustomization. 
```bash
flux create kustomization tilt-avatars \
  --target-namespace=default \
  --source=tilt-avatars \
  --path="./deploy" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/mycluster/tilt-avatar-kustomization.yaml
  ```

NOTE: It may fails if you didn't move the image to the internal registry. 

9 - Commit and push your code to the infra repo
```bash
git add .
git commit -m "adding flux source/kustomization for tilt avatars"
```

10 - List sources. You will see the kustomization kick off the deployment and then if you're still running k8s, you can see the pods deploy. 
```bash
watch flux get kustomizations
```

11 - Flux has two additional components that you can add to your bootstrap command: 
`--components-extra=image-reflector-controller,image-automation-controller` These additional components will allow you to track and update versions to automatically deploy. Take a look at this post. As a next step (on your own), can you add the version tracking to tilt-avatar? Here's a doc on how to do it: 
https://fluxcd.io/flux/guides/image-update/


------
useful commands for flux:
`flux reconcile kustomization flux-system --with-source` : forces the reconcilation to happen
`flux delete kustomization  tilt-avatars` : delete the kustomization
Remove flux
`flux uninstall --namespace=flux-system`

