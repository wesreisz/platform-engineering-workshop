1 - Create a cluster
`k3d cluster create mycluster --agents 2`

2 - Create a deployment and expose it Note: Test it before using gatekeeper to block
`kubectl create deployment my-nginx --image nginx`
`kubectl expose deployment my-nginx-svc --type=NodePort --port 80`

3 - Install gatekeeper
`kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.17.1/deploy/gatekeeper.yaml`

4 - Delete the nodeport service
`kubectl delete svc/my-nginx-svc`

5 - Install constrainttemplate & constraint
`kubectl apply -f ./block-nodeport-template.yaml`
`kubectl apply -f ./block-nodeport-constraint.yaml`

4 - Test it
`kubectl expose deployment my-nginx-svc --type=NodePort --port 80`

