# EKS Cluster Terraform Configuration

This Terraform configuration creates a complete EKS cluster with VPC, networking, and node groups.

## Prerequisites

1. **AWS CLI** installed and configured
2. **Terraform** (version >= 1.0)
3. **kubectl** installed
4. **AWS credentials** configured with appropriate permissions

## Required AWS Permissions

Your AWS user/role needs the following permissions:
- EKS Full Access
- VPC Full Access
- IAM Full Access
- EC2 Full Access

## Quick Start

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Review the plan
```bash
terraform plan
```

### 3. Apply the configuration
```bash
terraform apply
```

### 4. Configure kubectl to access the cluster

After the cluster is created, run these commands to access it:

```bash
# Get the cluster name
export CLUSTER_NAME=$(terraform output -raw eks_cluster_name)

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name $CLUSTER_NAME

# Verify access
kubectl get nodes
kubectl get pods --all-namespaces
```

## Cluster Details

- **Cluster Name**: `dev-demo` (configurable in terraform.tfvars)
- **Kubernetes Version**: 1.29
- **Region**: us-east-1
- **Node Group**: t3.medium instances (2-4 nodes)

## Network Configuration

- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24
- **Private Subnets**: 10.0.3.0/24, 10.0.4.0/24
- **Availability Zones**: us-east-1a, us-east-1b

## Useful Commands

### Check cluster status
```bash
aws eks describe-cluster --region us-east-1 --name dev-demo
```

### List node groups
```bash
aws eks list-nodegroups --region us-east-1 --cluster-name dev-demo
```

### Get cluster credentials
```bash
aws eks get-token --cluster-name dev-demo --region us-east-1
```

### View cluster logs
```bash
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/dev-demo"
```

## Troubleshooting

### If kubectl can't connect:
1. Verify AWS credentials: `aws sts get-caller-identity`
2. Check cluster status: `aws eks describe-cluster --name dev-demo --region us-east-1`
3. Update kubeconfig: `aws eks update-kubeconfig --name dev-demo --region us-east-1`

### If nodes are not ready:
1. Check node group status: `aws eks describe-nodegroup --cluster-name dev-demo --nodegroup-name general --region us-east-1`
2. Check EC2 instances in the private subnets
3. Verify security groups allow necessary traffic

## Setting Up Ingress, Metrics, and Monitoring

### Prerequisites for Advanced Setup

1. **Install Helm** (if not already installed):
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

2. **Install kubectl** (if not already installed):
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### 1. Setting Up NGINX Ingress Controller

```bash
# Add NGINX Ingress Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install NGINX Ingress Controller
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer

# Get the external IP
kubectl get svc -n ingress-nginx nginx-ingress-ingress-nginx-controller
```

### 2. Setting Up Metrics Stack

```bash
# Install Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify installation
kubectl get deployment metrics-server -n kube-system

# Test metrics
kubectl top nodes
kubectl top pods --all-namespaces
```
### 6. Monitoring and Troubleshooting

#### Check Ingress Status
```bash
# Check ingress resources
kubectl get ingress --all-namespaces

# Check ingress controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

#### Check Metrics Stack
```bash
# Check metrics server status
kubectl get pods -n kube-system | grep metrics-server

# Test metrics functionality
kubectl top nodes
kubectl top pods --all-namespaces
```

#### Common Issues and Solutions

1. **Ingress not working**:
   ```bash
   # Check if NGINX ingress controller is running
   kubectl get pods -n ingress-nginx
   
   # Check NGINX ingress controller logs
   kubectl logs -n ingress-nginx deployment/nginx-ingress-ingress-nginx-controller
   ```

2. **Metrics not showing**:
   ```bash
   # Check metrics server
   kubectl get pods -n kube-system | grep metrics-server
   
   # Check if nodes are ready
   kubectl get nodes
   ```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will delete the entire EKS cluster and all associated resources.

