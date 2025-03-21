
# Open VPN AWS
Tutorial based on:
https://www.youtube.com/watch?v=f8UlTNoGJUg&t=1076s

To provide VPN access to an internal private-IPs resources on AWS, you can use OpenVPN. Here’s how:

there are multiple terraform modules:
https://github.com/terraform-community-modules/tf_aws_openvpn
https://github.com/hadenlabs/terraform-aws-openvpn
^but they are outdated, containing wrong config files

To deploy manually:

1. create EC2 with AMI of OpenVPN (while deploying ec2 choose 'ami' and search for 'openvpn' in Marketplace)
  - enable public IP 
  - leave 'security group' as default (this AMI comes with declared security group rules) -> change IP CIDR to users who will be using (not 0.0.0.0/0 CIDR)
2. connect via AWS Console into deployed EC2 and go throguh init process (all default settings are fine for demo purpose)
3. download "openVPN Connect" 
4. put PublicIP and passwod generated during "init process" on EC2 and download profile
5. you can now connect via OpenVPN Connect to your dedicated OpenVPN EC2 on AWS and reach resources by their "private IP"