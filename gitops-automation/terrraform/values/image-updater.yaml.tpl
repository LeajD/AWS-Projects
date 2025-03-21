# file to specify variables for image-updater and get token for its tasks
---
serviceAccount:
  name: argocd-image-updater

authScripts:
  enabled: true
  scripts:
    auth.sh: |
      #!/bin/sh
      aws ecr --region ${region} get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d

config:
  registries:
  - name: ECR
    api_url: https://${account_id}.dkr.ecr.${region}.amazonaws.com
    prefix: ${account_id}.dkr.ecr.${region}.amazonaws.com
    ping: yes
    insecure: no
    credentials: ext:/scripts/auth.sh
    credsexpire: 10h