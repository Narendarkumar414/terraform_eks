resource "aws_eks_cluster" "eksProd" {
  name     = "eksProd"
  role_arn = aws_iam_role.eks-role.arn

  vpc_config {
  subnet_ids = ["subnet-3da5c546", "subnet-15d18f59", "subnet-25a0484e"]
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-role-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-role-AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eksProd.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eksProd.certificate_authority[0].data
}

variable "instancecount"{
    description = "number of nodes for kubernetes cluster"
}


resource "aws_eks_node_group" "enveu_eks_prod_ng1" {
  cluster_name    = aws_eks_cluster.eksProd.name
  node_group_name = "enveu_eks_prod_ng1"
  node_role_arn   = aws_iam_role.eks-node-group.arn
  subnet_ids = ["subnet-3da5c546", "subnet-15d18f59", "subnet-25a0484e"]

  instance_types = ["t2.medium"]
  capacity_type = "ON_DEMAND"
  disk_size = "30"
  scaling_config {
    desired_size = var.instancecount
    max_size     = var.instancecount+1
    min_size     = var.instancecount
  }


  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-node-group-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-group-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-group-AmazonEC2ContainerRegistryReadOnly,
  ]
}

