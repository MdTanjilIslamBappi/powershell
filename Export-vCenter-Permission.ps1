Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
#Get vCenter information:
$vCenterHost = Read-Host "Enter vCenter Name:"
#Get vCenter SSO Creds
$cred = Get-Credential
$VIServerShortName = $VIServer.Split(".")[0]
$FileDate = Get-Date -Format FileDate  
$ExportFileName = $VIServerShortName + "-permissions-" + $FileDate + ".csv"
Connect-VIServer -Server $vCenterHost -Credential $cred
$vms = Get-VM
$output = New-Object System.Collections.ArrayList($null)
$vmpermission = @()
foreach ($vm in $vms)
{
    $permissions = $vm | Get-VIPermission | Get-Unique
    Foreach ($permission in $permissions)
    {
        $formatpermission = $permission.Principal + " (" + $permission.Role + ")"
        $permission | Add-Member -NotePropertyName FormatPermission -NotePropertyValue $formatpermission
    }
    $vmpermission = [pscustomobject]@{VMName=$vm.Name;Role=$permissions.FormatPermission  -join ', '}
    [void]($output.Add($vmpermission))
}
$output | Export-csv $ExportFileName -NoTypeInformation
