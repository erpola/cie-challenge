from diagrams.azure.network import LoadBalancers, VirtualNetworks, NetworkInterfaces, Subnets, PublicIpAddresses, NetworkSecurityGroupsClassic
from diagrams.azure.compute import VM, AvailabilitySets, AppServices
from diagrams.azure.storage import StorageAccounts 
from diagrams.azure.web import AppServiceDomains
from diagrams.azure.security import KeyVaults
from diagrams import Diagram, Cluster, Edge

attr = {
  "splines": "line",
}


with Diagram("Resource Diagram", direction="TB", show=False, graph_attr=attr):
    internet = AppServiceDomains("Internet")
    with Cluster("Azure Subscription"):
        with Cluster("Resource Group"):
            
            load_balancer = LoadBalancers("Load Balancer")
            load_balancer_pip = PublicIpAddresses("Load Balancer Public IP")
            azure_bastion_pip = PublicIpAddresses("Azure Bastion Public IP")
            key_vault = KeyVaults("Key Vault")
            storage_account = StorageAccounts("Storage Account")
            nsg = NetworkSecurityGroupsClassic("Network Security Group")
            
            with Cluster("Virtual Network (10.0.0.0/16)"):
                virtual_network = VirtualNetworks("Virtual Network")
                subnet2 = Subnets("Sub2 10.0.1.0/24")
                subnet4 = Subnets("Sub4 10.0.3.0/24")
                
                with Cluster("Sub1 Connections"):
                    subnet1 = Subnets("Sub1 10.0.0.0/24")
                    availablity_set = AvailabilitySets("Availability Set") 
                    nic1 = NetworkInterfaces("VM 1 NIC")
                    nic2 = NetworkInterfaces("VM 2 NIC")
                    
                    with Cluster("Availability Set"):
                        vm1 = VM("VM 1")
                        vm2 = VM("VM 2")
                        avset_vms = [vm1, vm2]
                        
                    subnet1_resources = [availablity_set, nic1, nic2]
                    
                
                with Cluster("Sub3 Connections"):
                    subnet3 = Subnets("Sub3 10.0.2.0/24")
                    apache_vm_nic = NetworkInterfaces("Apache Web Server NIC")
                    apache_vm = VM("Apache Web Server")
                    subnet3_resources = [apache_vm_nic, apache_vm]
                     
                with Cluster("AzureBastionSubnet Connections"):
                    bastion_subnet = Subnets("AzureBastionSubnet")
                    bastion_host = AppServices("Bastion Host")
            
                subnets = [subnet1, subnet2, subnet3, subnet4, bastion_subnet]
                
    nsg \
    - Edge(color="purple") \
    - [subnet1, subnet3]
    
    virtual_network >> Edge(style="dotted") >> subnets   
        
    load_balancer - Edge(style="dotted") - load_balancer_pip
    nic1 - Edge(style="dotted") - vm1
    nic2 - Edge(style="dotted") - vm2
    apache_vm_nic - Edge(style="dotted") - apache_vm
    availablity_set >> Edge(style="dotted") >> avset_vms

    subnet1 >>  Edge(style="dotted") >> subnet1_resources
    subnet3 >> Edge(style="dotted") >> subnet3_resources
    bastion_subnet >> Edge(style="dotted") >> bastion_host
    
    internet \
        >> Edge(color="blue") \
        >> load_balancer \
        >> Edge(color="blue") \
        >> apache_vm_nic \
        >> Edge(color="blue") \
        >> apache_vm

    subnets \
    - Edge(color="teal") \
    - storage_account
    
    azure_bastion_pip - Edge(color="firebrick") \
    - bastion_host \
    - Edge(color="firebrick") \
    - [vm1, vm2, apache_vm]
    
    bastion_host - Edge(color="firebrick") - key_vault       