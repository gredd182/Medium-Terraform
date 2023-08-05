#---cluster/main.tf---
resource "random_string" "random" {
  length  = 5
  special = false
}

resource "aws_eks_cluster" "krypt0-week22" {
    encryption_config {
         resources = [ "secrets" ]
         provider {
             key_arn = var.kms_arn
         }
     }
enabled_cluster_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]
  name     = "krypt0-week22-${random_string.random.result}"
  role_arn = aws_iam_role.krypt0-week22.arn

  vpc_config {
    endpoint_public_access = false
    public_access_cidrs = ["10.2.0.0/8"]
    subnet_ids              = var.public_subnets
    endpoint_private_access = var.endpoint_private_access
    security_group_ids      = [aws_security_group.krypt0-week22-node-group.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.krypt0-week22-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.krypt0-week22-AmazonEKSVPCResourceController,
  ]
}



resource "aws_eks_node_group" "krypt0-week22" {
  cluster_name   = aws_eks_cluster.krypt0-week22.name
  node_role_arn  = aws_iam_role.krypt0-week22-cluster.arn
  subnet_ids     = var.public_subnets[*]
  instance_types = var.instance_types

  remote_access {
    source_security_group_ids = [aws_security_group.krypt0-week22-node-group.id]
    ec2_ssh_key               = var.key_pair
  }

  scaling_config {
    min_size     = 1
    max_size     = 3
    desired_size = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.krypt0-week22-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.krypt0-week22-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.krypt0-week22-AmazonEC2ContainerRegistryReadOnly,
  ]
}

#tfsec:ignore:aws-vpc-no-public-ingress-sgr[from_port=443]
resource "aws_security_group" "krypt0-week22-node-group" {
  name        = "http"
  description = "Allow inbound HTTP traffic"
  vpc_id      = var.vpc_id
  ingress {
    description = "Allow incoming HTTP traffic"
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  }
  egress {
    description = "Allow out going HTTP traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  }
}


resource "aws_iam_role" "krypt0-week22" {
  name = "krypt0-week22-eks-cluster"

  assume_role_policy = jsonencode({

    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        "Service" : "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role" "krypt0-week22-cluster" {
  name = "krypt0-week22-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "krypt0-week22-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.krypt0-week22.name
}

resource "aws_iam_role_policy_attachment" "krypt0-week22-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.krypt0-week22-cluster.name
}

resource "aws_iam_role_policy_attachment" "krypt0-week22-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.krypt0-week22-cluster.name
}

resource "aws_iam_role_policy_attachment" "krypt0-week22-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.krypt0-week22-cluster.name
}

resource "aws_iam_role_policy_attachment" "krypt0-week22-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.krypt0-week22.name
}
