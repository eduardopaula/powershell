
# QUEST SOFTWARE PROPRIETARY INFORMATION
# 
# This software is confidential.  Quest Software Inc., or one of its
# subsidiaries, has supplied this software to you under terms of a
# license agreement, nondisclosure agreement or both.
# 
# You may not copy, disclose, or use this software except in accordance with
# those terms.
# 
# 
# Copyright 2023 Quest Software Inc.
# ALL RIGHTS RESERVED.
# 
# QUEST SOFTWARE INC. MAKES NO REPRESENTATIONS OR
# WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE IMPLIED WARRANTIES OF MERCHANTABILITY
# FITNESS FOR A PARTICULAR PURPOSE, OR
# NON-INFRINGEMENT.  QUEST SOFTWARE SHALL NOT BE
# LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE
# AS A RESULT OF USING, MODIFYING OR DISTRIBUTING
# THIS SOFTWARE OR ITS DERIVATIVES.

# Prompt for Hyper-V server name OR IP Adress
$HVserverName = Read-Host 'Specify the Hyper-V hostname or IP address'

# Prompt for Hyper-V server username
$HVserverUser = Read-Host 'Specify the Hyper-V administrator'

# Prompt for Hyper-V server password
$HVserverPass = Read-Host -AsSecureString 'Specify the Hyper-V password'

# Prepare Hyper-V credentials in PSCredential format
$HVcred= New-Object System.Management.Automation.PSCredential ($HVserverUser, $HVserverPass)

# Create PSSession remote session query
$HVPSSession = New-PSSession -ComputerName $HVserverName -Credential $HVcred

# Start remote PSSession 
Invoke-Command -Session $HVPSSession -Scriptblock{

# Import required PowerShell classes
Add-Type -AssemblyName System.IO.Compression.FileSystem


# Prompt and validation  for Hyper-V template file 
$TemplateInput="notok"
do{

    $TemplateType="notok"
    do{
        # Prompt for Hyper-V template file location
        $HVserverTemplateLocation = Read-Host 'Specify the ThreatDetection Hyper-V template location relative to the Hyper-V server'
        # Validate template file type
        if ($HVserverTemplateLocation.EndsWith(".zip"))
        {
            $TemplateType="ok"
        }
        else
        {
            Write-Host "You have chosen a file that is not supported" -ForegroundColor Red
        }
    }while($TemplateType -ne "ok")


    # Read and validate .zip template before extract
    $zip= [IO.Compression.ZipFile]::OpenRead($HVserverTemplateLocation)
    foreach ($file in $zip.Entries) 
    {    
        if ($file -like "*/Virtual Machines/*.VMCX") 
        {
             $TemplateInput="ok"
            Break       
        }
    }

    if ($TemplateInput -ne "ok")
    {
        Write-Host "You have chosen a file that is not supported" -ForegroundColor Red
    }

}while($TemplateInput -ne "ok")

# Run resources validation
Write-Host "Checking resources..."
# Host Ram free space
$ramRequired=64
$ramValidation="notok"
do
{
    $ramFree =gwmi Win32_OperatingSystem | select FreePhysicalMemory
    [int]$ramFree=$ramFree.FreePhysicalMemory/1MB
    if($ramFree -lt $ramRequired)
    {
        Write-Host "There is not enough RAM memory available on the Hyper-V host for the Threat Detection server" -ForegroundColor Red
        Write-Host "Please ensure that at least" $ramRequired "GB of memory is available, then press Enter to continue. Current available memory is" $ramFree "GB." -ForegroundColor Yellow -NoNewline
        Read-Host 
    }
    else
    {
        $ramValidation="ok"
        Write-Host "The Hyper-V host meets the RAM requirements for the Threat Detection server" -ForegroundColor Green
    }

    Remove-Variable ramFree 
}while($ramValidation -ne "ok")

do{

	do{
        # Prompt for Hyper-V VHD deployment path
	    $HVVHDLocation = Read-Host "Specify the folder for the virtual machine HD files (.VHDX) "
        if(!(Test-Path -Path $HVVHDLocation -IsValid))
        {
            Write-Host "The specified folder is invalid" -ForegroundColor Red
        }
    }while(!(Test-Path -Path $HVVHDLocation -IsValid))
    $HVVHDLocation += "\CATDVHDX_"+(Get-Random -Minimum 10000 -Maximum 100000)

    do{
	    # Prompt for Hyper-V configuration files path
	    $HVConfLocation = Read-Host "Specify the folder for the virtual machine configuration file (.VMCX)"
        if(!(Test-Path -Path $HVConfLocation -IsValid))
        {
            Write-Host "The specified folder is invalid" -ForegroundColor Red
        }
    }while(!(Test-Path -Path $HVConfLocation -IsValid))

	do{
		# Prompt for Hyper-V VM name
		$HVVMName = Read-Host "Specify the name for the virtual machine. The value must be between 1 and 259 characters"
		if(($HVVMName.Length -lt 1) -or ($HVVMName.Length -gt 259)) #Hyper-V official length limits
		{
			Write-Host "You have entered a value that is not supported" -ForegroundColor Red
		}
	}while(($HVVMName.Length -lt 1) -or ($HVVMName.Length -gt 259))

	# Properties section
	$PropertiesInputs="notok" 

    # Define properties array which is goind to collect the all properties 
    $PropertiesArray= @()

    # Machine properties section
    # Machine number of cores
    $input="notok"
    do
    {
    $CoresNumberProperty= Read-Host 'Enter the number of virtual machine cores. The value must be greater than 8 and in multiples of four. For example 8, 12, or 16'

    if($CoresNumberProperty -eq "****")
    {
        $input="ok"
        $CoresNumberProperty=4
        Write-Host "Deploying a 4 core computer in Developer Mode" -ForegroundColor Green
    }
    elseif ([int]$CoresNumberProperty -lt 8 -Or [int]$CoresNumberProperty%4 -ne 0)
    {
        Write-Host "You have entered a value that is not supported" -ForegroundColor Red
        $input="notok"
    }
    else
    {
        $input="ok"
    }

    }while($input -ne "ok")

    # Add to properties array
    [hashtable]$Property = @{}
    $Property.Add('name','CORES')
    $Property.Add('value',$CoresNumberProperty)
    $PropertyObject= New-Object -TypeName psobject -Property $Property
    $PropertiesArray+=$PropertyObject

    # Network Adapter
    Write-Host "Available network connections for the virtual machine:"
    $NetworkAdapters = Get-VMSwitch
    foreach($Adapter in $NetworkAdapters)
    {
        Write-Host "Adapter Name:"$Adapter.Name
    }
    $CorrectAdapter="no"
    while($CorrectAdapter -ne "yes")
    {
        $NetworkAdapter= Read-Host "Enter the network connection to use for the virtual machine"
        foreach($Adapter in $NetworkAdapters)
        {
            If ( $Adapter.Name -eq $NetworkAdapter)
            {
                $CorrectAdapter="yes"
            }
        }
        
        If ($CorrectAdapter -ne "yes")
        {
            Write-Host "The specified network connection is unavailable" -ForegroundColor Red
        }
    }

    # Vlan ID
    $NetworkAdapterVlanID= Read-Host "If your network is a virtual local area network (VLAN) enter the VLAN identifier; otherwise, leave this field blank"
    while (($NetworkAdapterVlanID.ToString().Length -gt 0) -and ([int]$NetworkAdapterVlanID -lt 1 -or [int]$NetworkAdapterVlanID -gt 4094)  )
    {
        Write-Host "This is not a valid VLAN identifier. Enter a number between 1 and 4094" -ForegroundColor Red
        Write-Host "Re-enter the VLAN identifier"
        $NetworkAdapterVlanID= Read-Host "If your network is a virtual local area network (VLAN) enter the VLAN identifier; otherwise, leave this field blank"
    }

    # VM properties section
    # VM Hostname
    $HostnameProperty= Read-Host 'Enter the hostname including the virtual machine fully qualified name. For example: hostname.companyname.com'
    while ($HostnameProperty.ToString().Length -lt 2)
    {
        Write-Host "Hostname must contain at least 2 characters" -ForegroundColor Red
        Write-Host "Re-enter the hostname for the virtual machine"
        $HostnameProperty= Read-Host 'Enter the hostname including the virtual machine fully qualified name. For example: hostname.companyname.com'
    }

    # Add to properties array
    [hashtable]$Property = @{}
    $Property.Add('name','HOSTNAME')
    $Property.Add('value',$HostnameProperty)
    $PropertyObject= New-Object -TypeName psobject -Property $Property
    $PropertiesArray+=$PropertyObject


    # VM IP Address
    $IpProperty = Read-Host 'Enter the static IPV4 address for the virtual machine'
    $regip=[regex]"^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
    While (!($regip.IsMatch($IpProperty)))
    {
        Write-Host "This is not a valid IP address" -ForegroundColor Red
        Write-Host "Re-enter the IP address for the virtual machine"
        $IpProperty = Read-Host 'Enter the static IPV4 address for the virtual machine'
    }

    # Add to properties array
    [hashtable]$Property = @{}
    $Property.Add('name','IPADDRESS')
    $Property.Add('value',$IpProperty)
    $PropertyObject= New-Object -TypeName psobject -Property $Property
    $PropertiesArray+=$PropertyObject


    # VM Subnet Mask
    $SubnetProperty = Read-Host 'Enter the subnet mask address for the virtual machine. For example, 255.255.255.0'
    While (!($regip.IsMatch($SubnetProperty)))
    {
        Write-Host "This is not a valid subnet mask" -ForegroundColor Red
        Write-Host "Re-enter the subnet mask for the virtual machine"
        $SubnetProperty = Read-Host 'Enter the subnet mask address for the virtual machine. For example, 255.255.255.0'
    }

    # Add to properties array
    [hashtable]$Property = @{}
    $Property.Add('name','SUBNETMASK')
    $Property.Add('value',$SubnetProperty)
    $PropertyObject= New-Object -TypeName psobject -Property $Property
    $PropertiesArray+=$PropertyObject


    # VM Default Gateway
    $DefaultGatewayProperty = Read-Host 'Enter the default gateway address for the virtual machine'
    While (!($regip.IsMatch($DefaultGatewayProperty)))
    {
        Write-Host "This is not a valid default gateway" -ForegroundColor Red
        Write-Host "Re-enter the default gateway for the virtual machine"
        $DefaultGatewayProperty = Read-Host 'Enter the default gateway address for the virtual machine'
    }

    # Add to properties array
    [hashtable]$Property = @{}
    $Property.Add('name','DEFAULTGATEWAY')
    $Property.Add('value',$DefaultGatewayProperty)
    $PropertyObject= New-Object -TypeName psobject -Property $Property
    $PropertiesArray+=$PropertyObject

    # VM DNS
    $DNSProperty = Read-Host 'Enter the DNS server address for the virtual machine'
    While (!($regip.IsMatch($DNSProperty)))
    {
        Write-Host "This is not a valid DNS server address" -ForegroundColor Red
        Write-Host "Re-enter the DNS server address for the virtual machine"
        $DNSProperty = Read-Host 'Enter the DNS server address for the virtual machine'
    }

    # Add to properties array
    [hashtable]$Property = @{}
    $Property.Add('name','DNS')
    $Property.Add('value',$DNSProperty)
    $PropertyObject= New-Object -TypeName psobject -Property $Property
    $PropertiesArray+=$PropertyObject


    # PASSWORDS SECTION
    # Integration password
    do 
    {
        $input="notok"
        $IntegrationPwd1 = Read-Host "Enter the integration password for the virtual machine. The password must be 8-24 characters and can only include the following supported values: a-z, A-Z, 1-0, @,$." -AsSecureString
        $IntegrationPwd2 = Read-Host "Re- enter the integration password for the virtual machine" -AsSecureString
        $IntegrationPwd1_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($IntegrationPwd1))
        $IntegrationPwd2_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($IntegrationPwd2))

        if ((!($IntegrationPwd1_text -ceq $IntegrationPwd2_text)) -Or ($IntegrationPwd1_text -notmatch "^[a-z0-9$@]*$") -Or ($IntegrationPwd1_text.Length -lt 8) -or ($IntegrationPwd1_text.Length -gt 24))
        {
            Write-Host "The specified password does not meet the requirements. Enter the password again" -ForegroundColor Red
            $input="notok"
        }
        else
        {
            $input="ok"
        }

     }while ($input -ne "ok")  

    # Add to properties array
    [hashtable]$Property = @{}
    $Property.Add('name','INTEGRATIONPASSWORD')
    $Property.Add('value',$IntegrationPwd1_text)
    $PropertyObject= New-Object -TypeName psobject -Property $Property
    $PropertiesArray+=$PropertyObject

    # Root password
    do 
    {
        $input="notok"
        $RootPwd1 = Read-Host "Enter the root password for the virtual machine. The password must be 8-24 characters and can only include the following supported values: a-z, A-Z, 1-0, @,$." -AsSecureString
        $RootPwd2 = Read-Host "Re- enter the root password for the virtual machine" -AsSecureString
        $RootPwd1_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($RootPwd1))
        $RootPwd2_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($RootPwd2))

        if ((!($RootPwd1_text -ceq $RootPwd2_text)) -Or ($RootPwd1_text -notmatch "^[a-z0-9$@]*$") -Or ($RootPwd1_text.Length -lt 8) -or ($RootPwd1_text.Length -gt 24))
        {
            Write-Host "The specified password does not meet the requirements. Enter the password again" -ForegroundColor Red
            $input="notok"
        }
        else
        {
            $input="ok"
        }

    }while ($input -ne "ok")  

    # Add to properties array
    [hashtable]$Property = @{}
    $Property.Add('name','ROOTPASSWORD')
    $Property.Add('value',$RootPwd1_text)
    $PropertyObject= New-Object -TypeName psobject -Property $Property
    $PropertiesArray+=$PropertyObject

    


    #Properties user confirmation
    Write-Host "Review and confirm the settings before deploying the virtual machine:"
    Write-Host "Property Name: VHDXLOCATION, Value: " $HVVHDLocation -ForegroundColor Green
    Write-Host "Property Name: VMCXLOCATION, Value: " $HVConfLocation -ForegroundColor Green
    Write-Host "Property Name: VMNAME, Value: " $HVVMName -ForegroundColor Green
    Write-Host "Property Name: NETWORKADAPTER, Value: " $NetworkAdapter -ForegroundColor Green
    
    foreach ($VMProperty in $PropertiesArray)
    {
        if (($VMProperty.name -eq "ROOTPASSWORD") -or ($VMProperty.name -eq "INTEGRATIONPASSWORD"))
        {
            Write-Host "Property Name:"$VMProperty.name", Value: ********" -ForegroundColor Green
        }
        else
        {
        Write-Host "Property Name:"$VMProperty.name", Value:"$VMProperty.value -ForegroundColor Green
        }
    }
    
    
    $PropertiesInputs= Read-Host "To continue enter Yes. To change the properties, enter No"
    while ($PropertiesInputs -ne "Yes" -And $PropertiesInputs -ne "No")
    {
        Write-Host "Incorrect value"
        $PropertiesInputs= Read-Host "To continue enter Yes. To change the properties, enter No"
    }
       
}While ($PropertiesInputs -ne "Yes");

# Expand-template file section
# locate the target folder- same location as the zipped template
$TemplateFolder=$HVserverTemplateLocation.Substring(0, $HVserverTemplateLocation.lastIndexOf('\')+1)

#Extract template to the target folder
Write-Host "Please wait while the Hyper-V template is expanded. This may take several minutes" 
Expand-Archive -Path $HVserverTemplateLocation -DestinationPath $TemplateFolder -Force
$extractedTemplateFolder=$TemplateFolder + $zip.Entries[0].FullName

# Find template configuration file
$HVserverTemplateLocation = $extractedTemplateFolder + "\Virtual Machines\"
$HVserverTemplateLocation += (Get-Childitem –Path $HVserverTemplateLocation -Include *.VMCX -Recurse).Name

# Compatibility report
$report = Compare-VM -Path $HVserverTemplateLocation
while( $report.Incompatibilities.Length -gt 0)
{
    Write-Host "The following compatibility issues were found between the Threat Detection server and the virtual machine host:"
    $report.Incompatibilities | Format-Table -AutoSize
    Read-Host "Resolve the compatibility issues, and press Enter to continue"
    $report = Compare-VM -Path $HVserverTemplateLocation
}

# Deploy section
# Use the avalible virtualization name space
$Virtualiztion_NameSpace="root\virtualization"
if (get-wmiobject -namespace root\virtualization -class __NAMESPACE -filter "name='v2'")
{
    $Virtualiztion_NameSpace="root\virtualization\v2" 
}

# Deploy Hyper-v vm from template
Write-Host "Please wait while the Hyper-V virtual machine is deployed. This may take several minutes"
$ImportedVM= Import-VM -Path $HVserverTemplateLocation  -Copy -GenerateNewId -VhdDestinationPath $HVVHDLocation -VirtualMachinePath $HVConfLocation

#Inject properties to VM
# Use WMI objects
[string]$VMnamefilter= "ElementName='"+$ImportedVM.Name+"'"
$vm = Get-WmiObject -Namespace $Virtualiztion_NameSpace -class "Msvm_ComputerSystem" -Filter $VMnamefilter  
$VmMgmt = Get-WmiObject -Namespace $Virtualiztion_NameSpace -class “Msvm_VirtualSystemManagementService”


# Create KVP data instance 
$kvpDataItem = ([WMIClass][String]::Format("\\{0}\{1}:{2}", ` 
$VmMgmt.ClassPath.Server, ` 
$VmMgmt.ClassPath.NamespacePath, ` 
"Msvm_KvpExchangeDataItem")).CreateInstance()

# Properties injection loop
foreach ($VMProperty in $PropertiesArray)
{
    $kvpDataItem.Name = $VMProperty.name
    $kvpDataItem.Data = $VMProperty.value 
    $kvpDataItem.Source = 0
    $VmMgmt.AddKvpItems($vm, $kvpDataItem.PSBase.GetText(1)) | Out-Null
}

# Set number of cores
Set-VMProcessor $ImportedVM -Count $CoresNumberProperty

# Set Vlan ID
if ($NetworkAdapterVlanID.ToString().Length -gt 0)
{
    #Get Imported VM network adapter
    $ImportedVMNetworkAdapter = Get-VMNetworkAdapter -VMName $ImportedVM.Name

    # Set Vlan ID
    Set-VMNetworkAdapterVlan -VMNetworkAdapter $ImportedVMNetworkAdapter -Access -VlanId $NetworkAdapterVlanID
}

# Attach network Adapter
Get-VMSwitch $NetworkAdapter | Connect-VMNetworkAdapter -VMName $ImportedVM.Name


# Power-on machine
Write-Host "Please wait while the ThreatDetection server is configured. This may take several minutes"
Start-VM -Name $ImportedVM.Name

# Getting internal configuration status
# status filter
filter Import-CimXml 
{ 
    $CimXml = [Xml]$_ 
    $CimObj = New-Object -TypeName System.Object 
    foreach ($CimProperty in $CimXml.SelectNodes("/INSTANCE/PROPERTY")) 
    { 
        $CimObj | Add-Member -MemberType NoteProperty -Name $CimProperty.NAME -Value $CimProperty.VALUE
    } 
    $CimObj 
}

# Wait for configuration status and print
do{
    $Kvp = Get-WmiObject -Namespace root\virtualization\v2 -Query "Associators of {$Vm} Where AssocClass=Msvm_SystemDevice ResultClass=Msvm_KvpExchangeComponent"
    $status= $Kvp.GuestExchangeItems | Import-CimXml
    if($save -ne $status.Data)
    {
        if ($status.Data -ne "DONE")
        {
            $status.Data
        }
        $save=$status.Data
    }
}while($status.Data -ne "DONE")


# Remove properties from VM after getting status Done
foreach ($VMProperty in $PropertiesArray)
{
    $kvpDataItem.Name = $VMProperty.name
    $kvpDataItem.Data = "" 
    $kvpDataItem.Source = 0
    $VmMgmt.RemoveKvpItems($vm, $kvpDataItem.PSBase.GetText(1)) | Out-Null
}

# Remove temporary files
Remove-Item -Recurse -Force $extractedTemplateFolder


# Set VM name 
Rename-VM $vm.ElementName -NewName $HVVMName

# Wait for user action to exit
read-host “Press ENTER to exit...”

}






# SIG # Begin signature block
# MIImWgYJKoZIhvcNAQcCoIImSzCCJkcCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDWUJBzEE7gHz/+
# BQzQk7ta54JFWzwAyPay6sHqStA8VKCCDB0wggXzMIIE26ADAgECAhAJvF2jX0kc
# y4NSLmHIglSvMA0GCSqGSIb3DQEBCwUAMIGRMQswCQYDVQQGEwJHQjEbMBkGA1UE
# CBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQK
# ExFDT01PRE8gQ0EgTGltaXRlZDE3MDUGA1UEAxMuQ09NT0RPIFJTQSBFeHRlbmRl
# ZCBWYWxpZGF0aW9uIENvZGUgU2lnbmluZyBDQTAeFw0yMTAzMjkwMDAwMDBaFw0y
# NDAzMjgyMzU5NTlaMIHXMRAwDgYDVQQFEwc0NjQ1MzM2MRMwEQYLKwYBBAGCNzwC
# AQMTAlVTMRkwFwYLKwYBBAGCNzwCAQITCERlbGF3YXJlMR0wGwYDVQQPExRQcml2
# YXRlIE9yZ2FuaXphdGlvbjELMAkGA1UEBhMCVVMxEzARBgNVBAgMCkNhbGlmb3Ju
# aWExFDASBgNVBAcMC0FMSVNPIFZJRUpPMR0wGwYDVQQKDBRRVUVTVCBTT0ZUV0FS
# RSwgSU5DLjEdMBsGA1UEAwwUUVVFU1QgU09GVFdBUkUsIElOQy4wggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC3H9P30Qr2B+UarsSVlAT+PSlGV6yVTnWQ
# x43sZ+a8+z9eK+NIfHQ+mxfbaGDj/mIY22lrU2VMF4M2nVQ6svNbCj28wF7zIUML
# gP+MkaO8G0tWIPIs/EpDfVK3Z0jpAzExuB0XpM8WtaddIOFX2ZHpFaSGiBiaH4CZ
# NJwtLLtutd+baK9vSfEYQN6Cf7j+ebt/4g4Sp05MN8rcF2zlooeNlEGVJR4TcaBJ
# Oxn4LhxL6vVczoCZDeQb4b9LvIUfoxziIHd3Vllyn5GvSf00G10LyuL7TcxJ7ngG
# AeUJuak3gUdVG6mPkrcV1L/c3v6haCo/IX5KaDWt7BJ1SwZVxll9AgMBAAGjggH9
# MIIB+TAfBgNVHSMEGDAWgBTfj/MgDOnKpgTYW1g3Kj2rRtyDSTAdBgNVHQ4EFgQU
# akRqNJE+fmRC6eGnfmxII+TxRY8wDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQC
# MAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEkGA1Ud
# IARCMEAwNQYMKwYBBAGyMQECAQYBMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2Vj
# dGlnby5jb20vQ1BTMAcGBWeBDAEDMFUGA1UdHwROMEwwSqBIoEaGRGh0dHA6Ly9j
# cmwuY29tb2RvY2EuY29tL0NPTU9ET1JTQUV4dGVuZGVkVmFsaWRhdGlvbkNvZGVT
# aWduaW5nQ0EuY3JsMIGGBggrBgEFBQcBAQR6MHgwUAYIKwYBBQUHMAKGRGh0dHA6
# Ly9jcnQuY29tb2RvY2EuY29tL0NPTU9ET1JTQUV4dGVuZGVkVmFsaWRhdGlvbkNv
# ZGVTaWduaW5nQ0EuY3J0MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9j
# YS5jb20wRgYDVR0RBD8wPaAjBggrBgEFBQcIA6AXMBUME1VTLURFTEFXQVJFLTQ2
# NDUzMzaBFmRhdmlkLnJvYnNvbkBxdWVzdC5jb20wDQYJKoZIhvcNAQELBQADggEB
# AA8qzX1RKnES/YURDtwx8/M4CEv0xTF/ub137B8zeZu8wJO0Q7S3FWjRbMvMdX5V
# z3sCqn9XZS+6bkEcgh7wH0JphQxYerPnaKkdREUKAzugQDTJcMDpeOnJ4BbyCJFw
# ycFiufJbWZP3uDJUfZ1UStoAB9bwHDd0xf7EKtWe6LU/S530QkP2gxG6NFc7FtKd
# N6Y3f9Kih/z7X/NFADpIAJjr0vsPp9rwH5RqLViiFMwkAfDIGn+hON7pMnvrwaBU
# WCgrrUpiy5E8oYGHD0XWdCdrmoh7cvAj/x4DdpteVlBCH6ZA4dwTHa+v7rZhUPhF
# d3RHbc3+SFbAK4q3/lOVaIkwggYiMIIECqADAgECAhBt1HLrAq4EBuPdhD9f4UXh
# MA0GCSqGSIb3DQEBDAUAMIGFMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRl
# ciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8g
# Q0EgTGltaXRlZDErMCkGA1UEAxMiQ09NT0RPIFJTQSBDZXJ0aWZpY2F0aW9uIEF1
# dGhvcml0eTAeFw0xNDEyMDMwMDAwMDBaFw0yOTEyMDIyMzU5NTlaMIGRMQswCQYD
# VQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdT
# YWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDE3MDUGA1UEAxMuQ09N
# T0RPIFJTQSBFeHRlbmRlZCBWYWxpZGF0aW9uIENvZGUgU2lnbmluZyBDQTCCASIw
# DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAIr9vUPwPchVH/NZivBatNyT0WQV
# SoqEpS3LJvjgRTijuQHFTxMIWdAxVMrNkGGjPizyTRVc1O7DaiKXSNEGQzQJmcnP
# MMSfRP1WnO7M54O5gc3I2gscEkj/b6LsxHXLCXDPUeW7i5+qvXgGfZXWYYH22lPH
# rJ2zALoe1L5AYgmZgz1F3U1llQTM/PrHW3riLgw9VTVXNUiJifK5VqVLUBsc3piQ
# vfMu3Iip8XWbqD6iBdlBte93rRfAWvWj202f0cSxe4O17hCUKy5yrr7vlSmcUmLF
# LG0i931EehBfY5NpTdl9spqxTrVZv/+F+72s7OErpuMsLOjZbttfTRd4y1MCAwEA
# AaOCAX4wggF6MB8GA1UdIwQYMBaAFLuvfgI9+qbxPISOre44mOzZMjLUMB0GA1Ud
# DgQWBBTfj/MgDOnKpgTYW1g3Kj2rRtyDSTAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0T
# AQH/BAgwBgEB/wIBADATBgNVHSUEDDAKBggrBgEFBQcDAzA+BgNVHSAENzA1MDMG
# BFUdIAAwKzApBggrBgEFBQcCARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLmNvbS9D
# UFMwTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL2NybC5jb21vZG9jYS5jb20vQ09N
# T0RPUlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwcQYIKwYBBQUHAQEEZTBj
# MDsGCCsGAQUFBzAChi9odHRwOi8vY3J0LmNvbW9kb2NhLmNvbS9DT01PRE9SU0FB
# ZGRUcnVzdENBLmNydDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2Eu
# Y29tMA0GCSqGSIb3DQEBDAUAA4ICAQBmTuy3FndvEegbXWpO2fKLbLFWKECLwDHE
# mUgjPfgO6ICX720gCx8TxIb7FzQV4Y5U98K4AHMV4CjZ2rr6glTC9+u/wzbQMJ/l
# oRyU3+986PYseKKszyZqFaEVMdYxNJi9U0/EhIOjxJZcPdj+1vlU/2eTbfg+K2ss
# ogh8VkiBMhiybqyQwdvk3jmLhuXHGEBZpN+WR7qyf7H4Vw+FgHQ4DjpYYh7+UuPm
# rlMJhv6Pm9tWVswHsInBBPFTC2xvd+yyH+z2W0BDYA8bqxhUtBAEjvgO6cuDsXry
# NE5qVEzpgyrpsDAlHM5ijg7rheYp/rFK4/KuPJH1TKG+yBcOXLtCTeMaipLNPiB+
# 3el1seofdFyeVMKUN7Jh3QcWWX+WgBbgmbXSbrDJIwYVrNEj9DOLznXwwYbT/+Eu
# +pBP/kb5u9tPu7f+0Q0rBPHS0ZWFLIouuIVW8sOEUqHpM7HrUMihsJ/jw4s6h57n
# VdPTbTQXMA1oIgvVue1zNXLD7ac3zeNDrkXNNL8oyodi7UOkr/rLMcshWGFGXrbG
# eqYeUyqo+FxRHzpaEA8owOR0i3TGBKr4SyYoCjKJ250qYHFqw5ZOFrljv2GVZ4xL
# LruwToPpTTHljici9Twme0SR09Ra8NN89Di+FJqZDouxW+rkiw8RnXdCghxcOtTa
# q4gvjVcwVDGCGZMwghmPAgEBMIGmMIGRMQswCQYDVQQGEwJHQjEbMBkGA1UECBMS
# R3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFD
# T01PRE8gQ0EgTGltaXRlZDE3MDUGA1UEAxMuQ09NT0RPIFJTQSBFeHRlbmRlZCBW
# YWxpZGF0aW9uIENvZGUgU2lnbmluZyBDQQIQCbxdo19JHMuDUi5hyIJUrzANBglg
# hkgBZQMEAgEFAKB8MBAGCisGAQQBgjcCAQwxAjAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqGSIb3
# DQEJBDEiBCCeCinUw0pIM7G/9SdBcYGU7Tt+Bue6q7jHIyLn5xFXwTANBgkqhkiG
# 9w0BAQEFAASCAQBugu8XD/OyS6bzG2yChcsbpIMXi4rRmwumtNUzMHfJyg4YwFxy
# QKxSJ9u5roA/xsWh63eopBM59riv98gbEUSqO3GULb7MpMfGQxsCxP22RhxNQi6+
# Ym3mblewaB8QceV9beis/juJhAOnfhaNoE3E4IofV86SJCRHfRwlT9efHGRKEP6d
# Va9GP26/rNw3ie8slkWNnw+eV52cS8xZPrLyOjPcszOzgvjMs8WzYlrtq/0cpwsH
# 8OUnqTOGD0aYlrR1jrIQC6du50of6Dvmp2cNlFI5sxhNoMZOveiaRdZ//MACp77e
# 2u/ZsmPn6FARjzIZLHRJJJ8hqb52leup6vumoYIXPzCCFzsGCisGAQQBgjcDAwEx
# ghcrMIIXJwYJKoZIhvcNAQcCoIIXGDCCFxQCAQMxDzANBglghkgBZQMEAgEFADB3
# BgsqhkiG9w0BCRABBKBoBGYwZAIBAQYJYIZIAYb9bAcBMDEwDQYJYIZIAWUDBAIB
# BQAEIKwV1x3xJ5hvP9xT/O6s/3+r9e30rSoRq08nvL6tnQUIAhAC1JH8NLj8b6Ik
# EGL4iNcJGA8yMDIzMTExMzE1MzQwMlqgghMJMIIGwjCCBKqgAwIBAgIQBUSv85Sd
# CDmmv9s/X+VhFjANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQg
# UlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTIzMDcxNDAwMDAwMFoX
# DTM0MTAxMzIzNTk1OVowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0
# LCBJbmMuMSAwHgYDVQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMzCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAKNTRYcdg45brD5UsyPgz5/X5dLnXaEO
# CdwvSKOXejsqnGfcYhVYwamTEafNqrJq3RApih5iY2nTWJw1cb86l+uUUI8cIOrH
# mjsvlmbjaedp/lvD1isgHMGXlLSlUIHyz8sHpjBoyoNC2vx/CSSUpIIa2mq62DvK
# Xd4ZGIX7ReoNYWyd/nFexAaaPPDFLnkPG2ZS48jWPl/aQ9OE9dDH9kgtXkV1lnX+
# 3RChG4PBuOZSlbVH13gpOWvgeFmX40QrStWVzu8IF+qCZE3/I+PKhu60pCFkcOvV
# 5aDaY7Mu6QXuqvYk9R28mxyyt1/f8O52fTGZZUdVnUokL6wrl76f5P17cz4y7lI0
# +9S769SgLDSb495uZBkHNwGRDxy1Uc2qTGaDiGhiu7xBG3gZbeTZD+BYQfvYsSzh
# Ua+0rRUGFOpiCBPTaR58ZE2dD9/O0V6MqqtQFcmzyrzXxDtoRKOlO0L9c33u3Qr/
# eTQQfqZcClhMAD6FaXXHg2TWdc2PEnZWpST618RrIbroHzSYLzrqawGw9/sqhux7
# UjipmAmhcbJsca8+uG+W1eEQE/5hRwqM/vC2x9XH3mwk8L9CgsqgcT2ckpMEtGlw
# Jw1Pt7U20clfCKRwo+wK8REuZODLIivK8SgTIUlRfgZm0zu++uuRONhRB8qUt+JQ
# ofM604qDy0B7AgMBAAGjggGLMIIBhzAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/
# BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAgBgNVHSAEGTAXMAgGBmeBDAEE
# AjALBglghkgBhv1sBwEwHwYDVR0jBBgwFoAUuhbZbU2FL3MpdpovdYxqII+eyG8w
# HQYDVR0OBBYEFKW27xPn783QZKHVVqllMaPe1eNJMFoGA1UdHwRTMFEwT6BNoEuG
# SWh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJTQTQw
# OTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcmwwgZAGCCsGAQUFBwEBBIGDMIGAMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wWAYIKwYBBQUHMAKG
# TGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRHNFJT
# QTQwOTZTSEEyNTZUaW1lU3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggIB
# AIEa1t6gqbWYF7xwjU+KPGic2CX/yyzkzepdIpLsjCICqbjPgKjZ5+PF7SaCinEv
# GN1Ott5s1+FgnCvt7T1IjrhrunxdvcJhN2hJd6PrkKoS1yeF844ektrCQDifXcig
# LiV4JZ0qBXqEKZi2V3mP2yZWK7Dzp703DNiYdk9WuVLCtp04qYHnbUFcjGnRuSvE
# xnvPnPp44pMadqJpddNQ5EQSviANnqlE0PjlSXcIWiHFtM+YlRpUurm8wWkZus8W
# 8oM3NG6wQSbd3lqXTzON1I13fXVFoaVYJmoDRd7ZULVQjK9WvUzF4UbFKNOt50MA
# cN7MmJ4ZiQPq1JE3701S88lgIcRWR+3aEUuMMsOI5ljitts++V+wQtaP4xeR0arA
# VeOGv6wnLEHQmjNKqDbUuXKWfpd5OEhfysLcPTLfddY2Z1qJ+Panx+VPNTwAvb6c
# Kmx5AdzaROY63jg7B145WPR8czFVoIARyxQMfq68/qTreWWqaNYiyjvrmoI1VygW
# y2nyMpqy0tg6uLFGhmu6F/3Ed2wVbK6rr3M66ElGt9V/zLY4wNjsHPW2obhDLN9O
# TH0eaHDAdwrUAuBcYLso/zjlUlrWrBciI0707NMX+1Br/wd3H3GXREHJuEbTbDJ8
# WC9nR2XlG3O2mflrLAZG70Ee8PBf4NvZrZCARK+AEEGKMIIGrjCCBJagAwIBAgIQ
# BzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIwMzIzMDAw
# MDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UEChMORGln
# aUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQgUlNBNDA5
# NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCwzIP5WvYR
# oUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZzlm34V6gCff1DtITaEfFzsbPuK4CE
# iiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ7Gnf2ZCH
# RgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7QKxfst5K
# fc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/tePc5OsLDni
# pUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCYOjgRs/b2
# nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9KoRxrOMUp
# 88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6dSgkQe1C
# vwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM1+mYSlg+
# 0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbCdLI/Hgl2
# 7KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbECAwEAAaOC
# AV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1NhS9zKXaa
# L3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9PMA4GA1Ud
# DwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcBAQRrMGkw
# JAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcw
# AoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJv
# b3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAIBgZngQwB
# BAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7ZvmKlEIgF+
# ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI2AvlXFvX
# bYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/tydBTX/6tP
# iix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVPulr3qRCy
# Xen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScbqyQeJsG33irr9p6xeZmBo1aGqwpF
# yd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc6UsCUqc3
# fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3cHXg65J6t
# 5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0dKNPH+ejx
# mF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZPJ/tgZxah
# ZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLeMt8EifAA
# zV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDyDivl1vup
# L0QVSucTDh3bNzgaoSv27dZ8/DCCBY0wggR1oAMCAQICEA6bGI750C3n79tQ4ghA
# GFowDQYJKoZIhvcNAQEMBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGln
# aUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTIyMDgwMTAwMDAwMFoXDTMxMTEw
# OTIzNTk1OVowYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZ
# MBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1
# c3RlZCBSb290IEc0MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAv+aQ
# c2jeu+RdSjwwIjBpM+zCpyUuySE98orYWcLhKac9WKt2ms2uexuEDcQwH/MbpDgW
# 61bGl20dq7J58soR0uRf1gU8Ug9SH8aeFaV+vp+pVxZZVXKvaJNwwrK6dZlqczKU
# 0RBEEC7fgvMHhOZ0O21x4i0MG+4g1ckgHWMpLc7sXk7Ik/ghYZs06wXGXuxbGrzr
# yc/NrDRAX7F6Zu53yEioZldXn1RYjgwrt0+nMNlW7sp7XeOtyU9e5TXnMcvak17c
# jo+A2raRmECQecN4x7axxLVqGDgDEI3Y1DekLgV9iPWCPhCRcKtVgkEy19sEcypu
# kQF8IUzUvK4bA3VdeGbZOjFEmjNAvwjXWkmkwuapoGfdpCe8oU85tRFYF/ckXEaP
# ZPfBaYh2mHY9WV1CdoeJl2l6SPDgohIbZpp0yt5LHucOY67m1O+SkjqePdwA5EUl
# ibaaRBkrfsCUtNJhbesz2cXfSwQAzH0clcOP9yGyshG3u3/y1YxwLEFgqrFjGESV
# GnZifvaAsPvoZKYz0YkH4b235kOkGLimdwHhD5QMIR2yVCkliWzlDlJRR3S+Jqy2
# QXXeeqxfjT/JvNNBERJb5RBQ6zHFynIWIgnffEx1P2PsIV/EIFFrb7GrhotPwtZF
# X50g/KEexcCPorF+CiaZ9eRpL5gdLfXZqbId5RsCAwEAAaOCATowggE2MA8GA1Ud
# EwEB/wQFMAMBAf8wHQYDVR0OBBYEFOzX44LScV1kTN8uZz/nupiuHA9PMB8GA1Ud
# IwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA4GA1UdDwEB/wQEAwIBhjB5Bggr
# BgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
# bTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0QXNzdXJlZElEUm9vdENBLmNydDBFBgNVHR8EPjA8MDqgOKA2hjRodHRwOi8v
# Y3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMBEG
# A1UdIAQKMAgwBgYEVR0gADANBgkqhkiG9w0BAQwFAAOCAQEAcKC/Q1xV5zhfoKN0
# Gz22Ftf3v1cHvZqsoYcs7IVeqRq7IviHGmlUIu2kiHdtvRoU9BNKei8ttzjv9P+A
# ufih9/Jy3iS8UgPITtAq3votVs/59PesMHqai7Je1M/RQ0SbQyHrlnKhSLSZy51P
# pwYDE3cnRNTnf+hZqPC/Lwum6fI0POz3A8eHqNJMQBk1RmppVLC4oVaO7KTVPeix
# 3P0c2PR3WlxUjG/voVA9/HYJaISfb8rbII01YBwCA8sgsKxYoA5AY8WYIsGyWfVV
# a88nq2x2zm8jLfR+cWojayL/ErhULSd+2DrZ8LaHlv1b0VysGMNNn3O3AamfV6pe
# KOK5lDGCA3YwggNyAgEBMHcwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lD
# ZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYg
# U0hBMjU2IFRpbWVTdGFtcGluZyBDQQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgB
# ZQMEAgEFAKCB0TAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwHAYJKoZIhvcN
# AQkFMQ8XDTIzMTExMzE1MzQwMlowKwYLKoZIhvcNAQkQAgwxHDAaMBgwFgQUZvAr
# MsLCyQ+CXc6qisnGTxmcz0AwLwYJKoZIhvcNAQkEMSIEIHcDgF3qMtpYUQRuhqeK
# tppBjJy4l4wq62ajaRcxZaYTMDcGCyqGSIb3DQEJEAIvMSgwJjAkMCIEINL25G3t
# dCLM0dRAV2hBNm+CitpVmq4zFq9NGprUDHgoMA0GCSqGSIb3DQEBAQUABIICAHKU
# X6DucLfxaRFNq+pHG515jmnmi1xcmSvZEhtJBjDnKtW2RLaSNZCFf+bg+V+SvIbl
# udmoV6UN9MtfGbhQYsmuZOeSxUtJXiFpw4Ut5UFK7ha6keE/3IkghFNUh+RmGbPj
# xfGH52jaetTP7keHuhqpLKTIgqBUU+KGOqlnGeYP6aOq0pHp9iXg3Iy2cwg7KNni
# HSdzf31vrOk+ebcivSrcy+3dAffAhzjmGntRVhgAmbDup9agmf1tX9Z7C1EEX3E7
# 2wlK/pTGwCro8A+fkFwzZAuh3/zxSbRUndtLnqe5bBouMHo03FScvoPVVLKsxeDd
# qADNZgeH+BxX0bjYB/KnYFQh1MONYZAEk7n2h/2unC3U0RZxbxW02DS/0s5Qr1Vw
# ToVbEvxuMdqEnrdI9laanlUgVThTgAri3/fHTb7qG93n2Se9fI1s9OuBZSG4hLEG
# ZxiISMFsFRQFHc8RdryQoy/wxAW4Gl1+/fafR0o+hfbmMj2qRkNVXfEBRoRBFOoL
# KlqtitY3O7EShDq0BBVBF20tMZtnwvNlxbJ0Iqj0WurYgvwqIfBPVIQtmrma3Vum
# nHukV1mlgGQQ/F7/uRx0ETw+3Xq+CstPFoCe/w6rNQHftbPONpGSP+QAOWj42hr9
# BxDli5+bJVf+L7xHe1PFEnE0ZAacA2GpPGmA56hB
# SIG # End signature block
