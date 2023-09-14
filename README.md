```
kubectl label namespace dev elbv2.k8s.aws/pod-readiness-gate-inject=enabled
kubectl set env daemonset aws-node -n kube-system ENABLE_POD_ENI=true
kubectl set env daemonset aws-node -n kube-system POD_SECURITY_GROUP_ENFORCING_MODE=standard

SET aurora_replica_read_consistency = 'session';

eksctl create iamserviceaccount \
  --cluster=us-unicorn-cluster \
  --namespace=dev \
  --name=unicorn \
  --role-name us-unicorn-role \
  --attach-policy-arn=arn:aws:iam::790946953677:policy/us-unicorn-policy-unicorn \
  --approve --region us-east-1

eksctl create iamserviceaccount \
  --cluster=us-unicorn-cluster \
  --namespace=dev \
  --name=location \
  --role-name us-location-role \
  --attach-policy-arn=arn:aws:iam::790946953677:policy/unicorn-policy-location \
  --approve --region us-east-1
  
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
