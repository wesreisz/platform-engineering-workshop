- Getting started guide: https://fluxcd.io/flux/get-started
- Tutorial: https://anaisurl.com/full-tutorial-getting-started-with-flux-cd/
- Flux End to End: https://fluxcd.io/flux/flux-e2e/?ref=anaisurl.com
- flux completion:
	-
	  ```
	  . <(flux completion zsh)
	  ```
	- https://github.com/settings/tokens. - get your tokens
- I definitely need to add helm back into the kubernetes component... flux uses it
	- if I use the operator with starboard I'll need to also introduce operators before
- Starboard integrates oss security tools into a common interface #security
	- First part of this tutorial talks about starboard: https://anaisurl.com/full-tutorial-getting-started-with-flux-cd/
	- https://aquasecurity.github.io/starboard/v0.15.8/
	-
- To get the source: 
  ```
  flux get sources git
  ```
-
  ```
  flux bootstrap github 
    --owner=$GITHUB_USER 
    --repository=flux-example
    --branch=main 
    --path=./clusters/my-cluster 
    --personal
  
  
    flux bootstrap github \\
    --owner=$GITHUB_USER \\
    --repository=flux-example \\
    --branch=main \\
    --path=./clusters/my-cluster \\
    --personal
  
  
   flux create helmrelease starboard-operator \
     --chart starboard-operator \
    --source HelmRepository/starboard-operator \
    --chart-version 0.15.8 \
    --namespace starboard-system
  
  
    flux create source git react \\
      --url=https://github.com/AnaisUrlichs/react-article-display \\
      --branch=main
  
  
    kubectl create ns app
  
    flux create kustomization react-app \
    --target-namespace=app \
    --source=react \
    --path="./deploy/manifests" \
    --prune=true \
    --interval=5m 
  ```
- Need to dive into tooling for security
	- starboard looks like a great potential, but it sits on cluster is separate from the pipeline. Perhaps we need both #todo
		-
