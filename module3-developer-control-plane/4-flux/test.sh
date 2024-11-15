flux create source git tilt-avatars \
  --url=https://github.com/wesreisz/tilt-avatars.git \
  --branch=main \
  --interval=1m \
  --export > ./clusters/mycluster/tilt-avatars.yaml

  flux bootstrap git \
  --owner=$GITHUB_USER \
  --repository=podinfo-app \
  --branch=master \
  --path=clusters/my-cluster
  --personal


  flux create kustomization tilt-avatars \
  --target-namespace=default \
  --source=tilt-avatars \
  --path="./deploy" \
  --prune=true \
  --wait=true \
  --interval=30m \
  --retry-interval=2m \
  --health-check-timeout=3m \
  --export > ./clusters/mycluster/tilt-avatar.yaml


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