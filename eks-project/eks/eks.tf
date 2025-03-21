data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "../../networking/terraform.tfstate"
  }
}


module "eks_al2" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.cluster_name}"
  cluster_version = "${var.cluster_version}"

  enable_cluster_creator_admin_permissions = true #create user root access to cluster

  cluster_enabled_log_types = ["audit", "api", "authenticator","controllerManager","scheduler"] #enables logging to CW

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
    amazon-cloudwatch-observability = {}
  }

  vpc_id     = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids

  eks_managed_node_groups = {
    "${var.managed_node_groups_name}" = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #ami_type       = "AL2_x86_64"
      instance_types = "${var.instance_types}"

      min_size = "${var.node_min_size}"
      max_size = "${var.node_max_size}"
      desired_size = "${var.node_desired_size}"
    }
  }

  tags = {
    Project     = var.cluster_name
  }
}




resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = module.eks_al2.eks_managed_node_groups["${var.managed_node_groups_name}"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


variable "service_port" {
  default = 443
}

variable "target_port" {
  default = 443
}
resource "local_file" "k8s_service" {
  content  = templatefile("${path.module}/loadbalancer.yml", { #file to be changed
    service_port = var.service_port
    target_port  = var.target_port
    sg_name      = data.terraform_remote_state.networking.outputs.instance_sg
  })
  filename = "${path.module}/loadbalancer-variables.yaml" #file that will be created
}

