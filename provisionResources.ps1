# TODO: set variables
$studentName = "andyy"
$rgName = "andy-studio9-pt2-rg"
$vmName = "andy-studio9-pt2-vm"
$vmSize = "Standard_B2s"
$vmImage = "Canonical:UbuntuServer:18.04-LTS:latest"
$vmAdminUsername = "student"
$kvName = "${studentName}-lc0820-ps-kv"
$kvSecretName = "ConnectionStrings--Default"
$kvSecretValue = "server=localhost;port=3306;database=coding_events;user=coding_events;password=launchcode"

# TODO: provision RG
az configure --defaults location=eastus
az configure --list-defaults
az group create -n $rgName
az configure --default group=$rgName

# TODO: provision VM
az vm create -n $vmName --size $vmSize --image $vmImage --admin-username $vmAdminUsername --admin-password "LaunchCode-@zure1" --assign-identity --generate-ssh-keys
az configure --default vm=$vmName
###$vm = Get-Content .\vm.json |ConvertFrom=Json

# TODO: capture the VM systemAssignedIdentity
###$vmID= 
$vmObjectId="$(az vm show --query "identity.principalId")"

# TODO: open vm port 443
az vm open-port --port 443

# provision KV
az keyvault create -n $kvName --enable-soft-delete false --enabled-for-deployment true

# TODO: create KV secret (database connection string)
az keyvault secret set --vault-name andyy-lc0820-ps-kv --description 'connection string' --name $kvSecretName --value $kvSecretValue

# TODO: set KV access-policy (using the vm ``systemAssignedIdentity``)
az keyvault set-policy --name $kvName --object-id $vmObjectId --secret-permissions list get

az vm run-command invoke --command-id RunShellScript --scripts @vm-configuration-scripts/1configure-vm.sh

az vm run-command invoke --command-id RunShellScript --scripts @vm-configuration-scripts/2configure-ssl.sh

az vm run-command invoke --command-id RunShellScript --scripts @deliver-deploy.sh


# TODO: print VM public IP address to STDOUT or save it as a file
az network public-ip list > C:\Users\Andy\source\repos\powershell-az-cli-scripting-deployment\output.txt 
