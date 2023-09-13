```
kubectl label namespace dev elbv2.k8s.aws/pod-readiness-gate-inject=enabled
kubectl set env daemonset aws-node -n kube-system ENABLE_POD_ENI=true
kubectl set env daemonset aws-node -n kube-system POD_SECURITY_GROUP_ENFORCING_MODE=standard

eksctl create iamserviceaccount \
  --cluster=us-unicorn-cluster \
  --namespace=dev \
  --name=unicorn \
  --role-name us-unicorn-role \
  --attach-policy-arn=arn:aws:iam::790946953677:policy/us-unicorn-policy-unicorn \
  --approve

eksctl create iamserviceaccount \
  --cluster=us-unicorn-cluster \
  --namespace=dev \
  --name=location \
  --role-name us-location-role \
  --attach-policy-arn=arn:aws:iam::790946953677:policy/unicorn-policy-location \
  --approve
  
tolerations:
- effect: NoSchedule
key: dedicated
operator: Equal
value: tool

affinity:
nodeAffinity:
requiredDuringSchedulingIgnoredDuringExecution:
nodeSelectorTerms:
- matchExpressions:
- key: unicorn/dedicated
operator: In
values:
- tool
```
