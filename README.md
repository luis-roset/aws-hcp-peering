# aws-hcp-peering

This is a module to create a HashicCorp Virtual Network and accept the peering connection on AWS.

## Prerequisites

### The following variables must be defined before the use of the module.

1. hcp_client_id -> Client id to connect to hcp provider.
2. hcp_client_secret -> Client secret to connect to hcp provider.
3. hcp_project_id -> HCP project id connect to.
4. aws_account_id -> AWS account id to connect to.

**Also the export of the AWS credentials is needed**

### It creates the following resources

-  hcp_hvn 
-  hcp_aws_network_peering 
-  aws_vpc 
-  aws_subnet 
-  hcp_hvn_route 
-  aws_vpc_peering_connection_accepter 