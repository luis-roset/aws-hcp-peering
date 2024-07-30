provider "aws" {
  region = "us-west-2"
}

/*provider "tfe" {
  token = var.tfe_token
}*/

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

# HCP VPC Creation: Creates an HCP VPC using the hcp_hvn resource
resource "hcp_hvn" "example" {
  hvn_id         = "dynamic-hvn"
  project_id = var.hcp_project_id
  cloud_provider = "aws"
  region     = "us-west-2"
  cidr_block = "172.25.16.0/20"
}


# VPC Peering Connection in HCP
resource "hcp_aws_network_peering" "example" {
  hvn_id          = hcp_hvn.example.hvn_id
  peering_id      = "dev"
  peer_vpc_id     = aws_vpc.main.id
  peer_account_id = aws_vpc.main.owner_id
  peer_vpc_region = "us-west-2"
}


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
data "aws_arn" "main" {
  arn = aws_vpc.main.arn
}

# AWS VPC Creation: Creates an AWS VPC and a subnet.
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "hcp_hvn_route" "main-to-dev" {
  hvn_link         = hcp_hvn.example.self_link
  hvn_route_id     = "main-to-dev"
  destination_cidr = "172.31.0.0/16"
  target_link      = hcp_aws_network_peering.example.self_link
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.example.provider_peering_id
  auto_accept               = true
}