#!/bin/bash
curl -X POST http://us-unicorn-alb-1705209872.us-east-1.elb.amazonaws.com/v1/stress -H "Content-Type: application/json" --data '{"cpu":"100000"}' &
