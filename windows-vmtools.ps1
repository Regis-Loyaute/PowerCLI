# Set PowerCLI to ignore invalid certificates
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Set the name of the vCenter Server
$vcenter = "10.100.1.4"

# Get credentials for logging into vCenter
$credential = Get-Credential
$Username = $credential.GetNetworkCredential().username
$Password = $credential.GetNetworkCredential().password

# Connect to the vCenter Server
Connect-VIServer $vcenter -User $Username -Password $Password
Connect-VIServer $vcenter -User $Username -Password $Password

#Get a list of the virtual machines that are Powered On
$virtualmachines = Get-VM | Where-Object PowerState -eq "PoweredOn"

#Get Only the Windows VMs
ForEach ($vm in $virtualmachines) {
    #If the VM is a Windows VM...
    If ((Get-VMGuest -VM $vm).OSFullName -like "Microsoft*") {
        #Update VMware Tools but don't reboot the machine - Reboot may still occur depending on ESXi/vCenter version
        Write-Host "Updating VMware tools on $($vm.Name)"
        Update-Tools -VM $vm -NoReboot
    }

    #If there is no OSFullName detected
    elseif((Get-VMGuest -VM $vm).OSFullName -Like " *") {
        Write-Host "VMware Tools doesn't appear to be installed on $($vm.Name)"
    }

    #If it's not a Windows VM then automatic update is not supported
    else {
        Write-Host "$($vm.Name) is not a Windows VM and automatic Update is not supported"
    }
}
