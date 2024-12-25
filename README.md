# msa-petclinic

[Spring Petclinic](https://github.com/spring-petclinic/spring-petclinic-microservices) 을 EKS 상에 배포하고 CICD 환경을 구성


## Apply 순서 
1. 한명이 backend 디렉토리 에서 terraform apply 실행
2. eks 디렉토리에서 vpc 모듈과 eks 모듈 배포 ``` terraform apply  -target=module.vpc -target=module.eks  ```
3. 배포 되면 ```terraform apply``` 통해 전체 배포
4. ArgoCD Password   
    ```
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ``` 


## Destroy 순서
1. 바로 ```terraform destroy ``` 해도 상관없으나  ```terraform destroy -target=module.eks_blueprints_addons ``` 실행 후 권장


## 생성 리소스

### Terraform Backend

1. S3 Bucket 
2. DynamoDB

### VPC

1. VPC
2. Public 3, Private 6 Subnet
3. NAT Gateway
4. Internet Gateway
5. Routing Table

### EKS

1. Auto Mode EKS

### Kubernetes Addons

1. ArgoCD
2. Metrics server
3. External DNS
4. Cert Manager

