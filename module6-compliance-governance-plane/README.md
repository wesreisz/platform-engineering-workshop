NOTE: If you're continuing on from a previous module, jump to step 2

1 - Create a cluster
`k3d cluster create mycluster --agents 2`

2 - Create a deployment and expose it Note: Test it before using gatekeeper to block
`kubectl create deployment my-nginx --image nginx`
`kubectl expose deployment my-nginx --type=NodePort --port 80`


3 - Install gatekeeper
`kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.17.1/deploy/gatekeeper.yaml`

or
```bash
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm install gatekeeper/gatekeeper --name-template=gatekeeper --namespace gatekeeper-system --create-namespace
```

4 - Delete the nodeport service
`kubectl delete svc/my-nginx`

5 - Install constrainttemplate & constraint
`kubectl apply -f ./block-nodeport-template.yaml`
`kubectl apply -f ./block-nodeport-constraint.yaml`

4 - Test it
`kubectl expose deployment my-nginx-svc --type=NodePort --port 80`


----------------
fluxKustomizations: {
      infra: {
        path: './infrastructure'
        syncIntervalInSeconds: 120
        prune: true
      }
      opaconstraints: {
        path: './opa-constraints'
        syncIntervalInSeconds: 120
        prune: true
        dependsOn: [
          'opatemplates'
        ]
      }
      opatemplates: {
        path: './opa-templates'
        syncIntervalInSeconds: 120
        prune: true
        dependsOn: [
          'infra'
        ]
      }
      apps: {
        path: './apps'
        syncIntervalInSeconds: 120
        prune: false //Not to accidentally delete something what belongs to user
      }
    }
