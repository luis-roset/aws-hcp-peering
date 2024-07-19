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

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# AWS VPC Creation: Creates an AWS VPC and a subnet.
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

# VPC Peering Connection: Establishes a peering connection between the AWS VPC and the HCP VPC.
resource "aws_vpc_peering_connection" "example" {
  vpc_id        = aws_vpc.main.id
  peer_vpc_id   = hcp_hvn.example.aws_peering_vpc_id
  peer_owner_id = hcp_hvn.example.aws_account_id
  peer_region   = "us-west-2"

  auto_accept = false
}

# Peering Connection Accepter: Accepts the peering connection on the AWS side.
resource "aws_vpc_peering_connection_accepter" "example" {
  vpc_peering_connection_id = aws_vpc_peering_connection.example.id
  auto_accept               = true
  vpc_id                    = hcp_hvn.example.aws_peering_vpc_id
}

# Route Tables Update: Adds routes to the route tables in both VPCs to allow traffic flow.

resource "aws_route" "to_hcp" {
  route_table_id            = aws_vpc.main.main_route_table_id
  destination_cidr_block    = hcp_hvn.example.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.example.id
}

resource "hcp_aws_network_peering_route" "example" {
  hvn_id      = hcp_hvn.example.id
  destination = aws_vpc.main.cidr_block
}
