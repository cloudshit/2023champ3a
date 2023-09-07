solution with following limits:
```
no cross-region
no git-ops
```

```
kubectl label namespace dev elbv2.k8s.aws/pod-readiness-gate-inject=enabled

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
