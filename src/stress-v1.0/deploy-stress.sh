#!/bin/bash
kubectl rollout restart -n dev deploy/stress
