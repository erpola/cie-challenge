/* 
* Set the subscription_id variable before running terraform plan or apply
* Ensure that you have Key Vault Administrator access to the subscription
*/

project_name    = "cf-challenge"
environment     = "dev"
location        = "eastus"

virtual_network_config = {
  base_cidr    = "10.0.0.0/16"
  subnet_count = 4
}
