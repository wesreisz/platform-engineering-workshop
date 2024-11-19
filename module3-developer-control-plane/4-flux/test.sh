flux create source git tilt-avatars \
  --url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/tilt-avatars.git \
  --branch=main \
  --interval=1m \
  --export > ./clusters/mycluster/tilt-avatars-source.yaml

  flux bootstrap git \
  --owner=$GITHUB_USER \
  --repository=podinfo-app \
  --branch=master \
  --path=clusters/my-cluster
  --personal

flux bootstrap git \
--url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/fleet-infra.git \
--branch=main \
--path=clusters/mycluster \
--password=gitea \
--allow-insecure-http=true \
--username=gitea \
--token-auth=true \
--interval=30m 


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


  flux create source git podinfo \
  --url=https://github.com/stefanprodan/podinfo \
  --branch=master \
  --interval=1m \
  --export > ./clusters/my-cluster/podinfo-source.yaml

  flux create kustomization podinfo \
  --target-namespace=default \
  --source=podinfo \
  --path="./kustomize" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/my-cluster/podinfo-kustomization.yaml


  flux bootstrap git 
  --url=http://gitea-http.gitea.svc.cluster.local:3000/gitea/fleet-infra.git 
  --branch=main 
  --path=clusters/mycluster 
  --password=gitea 
  --allow-insecure-http=true 
  --username=gitea 
  --token-auth=true 
  --interval=30m 
  --components-extra=image-reflector-controller,image-automation-controller

