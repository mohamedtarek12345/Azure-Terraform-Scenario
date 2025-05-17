# Azure Infrastructure Validation Script
# This script validates all components of the Azure infrastructure including:
# - Network Security Groups
# - Virtual Networks and Peering
# - Load Balancers (Public and Private)
# - Virtual Machines (Windows and Linux)
# - File Share Mounting and Persistence (fstab)
# - SQL Database Connectivity
# - Cross-VM File Share Access

# Parameters
$ResourceGroup = "Terraform-RG"
$Location = "centralindia"
$AdminUsername = "tt"

# Color coding for output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Test-Component {
    param (
        [string]$ComponentName,
        [scriptblock]$Test
    )
    Write-ColorOutput Yellow "`n=== Testing $ComponentName ===`n"
    try {
        & $Test
        Write-ColorOutput Green "[✓] $ComponentName test completed successfully"
    }
    catch {
        Write-ColorOutput Red "[×] $ComponentName test failed: $_"
    }
}

# 1. Network Security Groups Validation
Test-Component "Network Security Groups" {
    Write-Output "Checking NSG Rules..."
    $windowsNsg = az network nsg show -g $ResourceGroup -n "windows-nsg" | ConvertFrom-Json
    $linuxNsg = az network nsg show -g $ResourceGroup -n "linux-nsg" | ConvertFrom-Json
    
    if (-not $windowsNsg -or -not $linuxNsg) {
        throw "NSGs not found"
    }
    Write-Output "Windows NSG Rules: $($windowsNsg.securityRules.Count)"
    Write-Output "Linux NSG Rules: $($linuxNsg.securityRules.Count)"
}

# 2. Virtual Network Peering Validation
Test-Component "VNet Peering" {
    Write-Output "Checking VNet peering status..."
    $peering = az network vnet peering list --resource-group $ResourceGroup --vnet-name HubVNet | ConvertFrom-Json
    if ($peering.peeringState -ne "Connected") {
        throw "VNet peering is not in Connected state"
    }
    Write-Output "Peering Status: Connected"
}

# 3. Load Balancer Validation
Test-Component "Load Balancers" {
    Write-Output "Checking Load Balancers..."
    
    # Public Load Balancer
    $publicLbIp = az network public-ip show --resource-group $ResourceGroup --name windows-public-lb-pip --query ipAddress -o tsv
    Write-Output "Public LB IP: $publicLbIp"
    
    # Private Load Balancer
    $privateLb = az network lb show -g $ResourceGroup -n linux-private-lb | ConvertFrom-Json
    Write-Output "Private LB: $($privateLb.name)"
    
    # Check health probes
    $publicProbe = az network lb probe list -g $ResourceGroup --lb-name windows-public-lb | ConvertFrom-Json
    $privateProbe = az network lb probe list -g $ResourceGroup --lb-name linux-private-lb | ConvertFrom-Json
    
    Write-Output "Public LB Probe Protocol: $($publicProbe.protocol)"
    Write-Output "Private LB Probe Protocol: $($privateProbe.protocol)"
}

# 4. Virtual Machine Status
Test-Component "Virtual Machines" {
    Write-Output "Checking VM status..."
    $vms = az vm list -g $ResourceGroup --show-details | ConvertFrom-Json
    foreach ($vm in $vms) {
        Write-Output "VM: $($vm.name) - Status: $($vm.powerState)"
        if ($vm.powerState -ne "VM running") {
            throw "VM $($vm.name) is not running"
        }
    }
}

# 5. File Share Mounting and Persistence Test
Test-Component "File Share Mounting" {
    Write-Output "Testing file share mounting and persistence on Linux VMs..."
    
    # Test on linux-vm-1
    $testFile = "test_$(Get-Date -Format 'yyyyMMddHHmmss').txt"
    $vm1Ip = "4.213.162.158"
    $vm2Ip = "74.225.196.231"
    
    # Check fstab entry on both VMs
    Write-Output "Checking fstab entries..."
    $fstabVM1 = ssh -o StrictHostKeyChecking=no tt@$vm1Ip "cat /etc/fstab | grep fileshare"
    $fstabVM2 = ssh -o StrictHostKeyChecking=no tt@$vm2Ip "cat /etc/fstab | grep fileshare"
    
    if (-not $fstabVM1 -or -not $fstabVM2) {
        throw "File share not properly configured in fstab"
    }
    Write-Output "fstab entries verified on both VMs"
    
    # Test file share functionality
    Write-Output "Testing file share read/write..."
    ssh -o StrictHostKeyChecking=no tt@$vm1Ip "echo 'Hello everyone' > /mnt/fileshare/$testFile"
    Start-Sleep -Seconds 5  # Wait for file sync
    
    # Verify file on VM2
    $verifyContent = ssh -o StrictHostKeyChecking=no tt@$vm2Ip "cat /mnt/fileshare/$testFile"
    if ($verifyContent -ne "Hello everyone") {
        throw "File share verification failed"
    }
    Write-Output "File share test successful - Content verified across VMs"
    
    # Check mount persistence
    Write-Output "Checking mount persistence..."
    $mountCheckVM1 = ssh -o StrictHostKeyChecking=no tt@$vm1Ip "mountpoint /mnt/fileshare"
    $mountCheckVM2 = ssh -o StrictHostKeyChecking=no tt@$vm2Ip "mountpoint /mnt/fileshare"
    
    if ($mountCheckVM1.ExitCode -ne 0 -or $mountCheckVM2.ExitCode -ne 0) {
        throw "File share not properly mounted"
    }
    Write-Output "Mount persistence verified on both VMs"
}

# 6. Web Server Access Test
Test-Component "Web Servers" {
    Write-Output "Testing web server access..."
    
    # Test IIS on Windows VMs through public LB
    $publicLbIp = az network public-ip show --resource-group $ResourceGroup --name windows-public-lb-pip --query ipAddress -o tsv
    Write-Output "Testing IIS through public LB IP: $publicLbIp"
    $iisResponse = Invoke-WebRequest -Uri "http://$publicLbIp" -UseBasicParsing
    Write-Output "IIS Response Status: $($iisResponse.StatusCode)"
    
    # Test Apache through private LB
    Write-Output "`nTo test Apache through private LB:"
    Write-Output "1. RDP to Windows VM (74.225.203.183)"
    Write-Output "2. Open browser and navigate to http://10.0.2.4"
    Write-Output "3. You should see the Apache default page"
}

# 7. SQL Database Connectivity
Test-Component "SQL Database" {
    Write-Output "Checking SQL Database..."
    $sqlServer = az sql server show -g $ResourceGroup -n "myapp-sqlserver-sqlserver" | ConvertFrom-Json
    Write-Output "SQL Server: $($sqlServer.fullyQualifiedDomainName)"
    Write-Output "`nTo test SQL connectivity:"
    Write-Output "1. RDP to win-vm-1 (74.225.203.183)"
    Write-Output "2. Run the following PowerShell commands to download and install SSMS:"
    Write-Output "   Invoke-WebRequest -Uri 'https://aka.ms/ssmsfullsetup' -OutFile 'SSMS-Setup.exe'"
    Write-Output "   Start-Process -FilePath 'SSMS-Setup.exe' -ArgumentList '/install /quiet' -Wait"
    Write-Output "3. Launch SQL Server Management Studio"
    Write-Output "4. Connect using:"
    Write-Output "   Server: $($sqlServer.fullyQualifiedDomainName)"
    Write-Output "   Authentication: SQL Server Authentication"
    Write-Output "   Username: $AdminUsername"
}

Write-ColorOutput Yellow "`n=== Validation Complete ===`n"
Write-Output "Manual Verification Steps:"
Write-Output "1. IIS Website Test:"
Write-Output "   - Open browser and navigate to: http://4.213.5.70"
Write-Output "   - Should see IIS default page"
Write-Output "`n2. Apache Website Test (from Windows VM):"
Write-Output "   - RDP to Windows VM: 74.225.203.183"
Write-Output "   - Open browser and navigate to: http://10.0.2.4"
Write-Output "   - Should see Apache default page"
Write-Output "`n3. SQL Database Test:"
Write-Output "   - Follow the SQL Database test instructions above"
Write-Output "`n4. File Share Test:"
Write-Output "   - SSH to Linux VM1: ssh tt@4.213.162.158"
Write-Output "   - Create test file: echo 'Hello everyone' > /mnt/fileshare/test.txt"
Write-Output "   - SSH to Linux VM2: ssh tt@74.225.196.231"
Write-Output "   - Verify file: cat /mnt/fileshare/test.txt" 