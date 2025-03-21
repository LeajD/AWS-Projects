# Inter-VPC/Account Network Traffic 

![Inter-VPC/Account Network Traffic:](https://docs.aws.amazon.com/images/prescriptive-guidance/latest/integrate-third-party-services/images/p3-2_transit-gateway.png)
image: https://docs.aws.amazon.com/images/prescriptive-guidance/latest/integrate-third-party-services/images/p3-2_transit-gateway.png


1. Go to the VPC console and create a new Transit Gateway
2. Create "transit gateway attachments" (of type "VPC") resource for EACH of the two VPCs (VPC-A, VPC-B) to link Transit Gateway with corresponding VPC.
3. Make sure "transit gateway route table" routes correct IP CIDRs for corresponsing VPC.
4. In both subnets (private-subnet1 for VPC-A and private-subnet2 for VPC-B) in their "route tables" put CIDR of another subnet and choose created "transit gateway" as "target" for this traffic.
5. In Security Groups for resources that need access make sure to allow network inbound/outbound traffic from corresponding CIDRs.

You can achieve Network Traffic between different accounts in the same way, but during "transit gateway attachemen" creation choose "attachment type" of  "Peering connection" and put proper AccountID and "Transit gateway accepter" (transit gateway in another account that will have to "approve" such connection)

