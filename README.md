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

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will delete the entire EKS cluster and all associated resources.
