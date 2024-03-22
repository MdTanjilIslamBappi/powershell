### Usage ############################################################################
### Line07: Replace vcenter.fqdn to desired value of vCenter fqdn ####################
### Line11: Replace quoted value for datastore names #################################
### Line28: Replace output filename ##################################################

# connect to the vCenter #
Connect-VIServer -Server vcenter.fqdn
# Get datastores from vCenter #
$Datastores = Get-Datastore
# Specific Datastore name start with Power #
$storage = $Datastores | Where-Object {$_.Name -like "Power*" }

foreach($datastore in $storage){
# Store Extended data to the variable #
$ds = Get-Datastore -Name $datastore | %{Get-View $_.Id}
#$ds= $Datastores.extensionData #
# Changing view type of $ds #
$dsBrowser = Get-View $ds.browser
# Get the datastore names #
$datastorePath ="["+ $ds.Summary.Name +"]"
# Prepare the search #
$SearchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
$SearchSpec.MatchPattern = "*.vmx"
# Find all VMX file Path in Datastore and filters out .snapshot #
$SearchResult = $dsBrowser.SearchDatastoreSubFolders($datastorePath, $SearchSpec) | where {$_.FolderPath -notmatch ".snapshot"} | %{$_.FolderPath + ($_.File | select Path).Path}
# Export-VMX #
foreach($VMXfile in $SearchResult) {
$VMXfile | Out-File "D:\exportvmx.txt" -Append
}
}

####################################################################################################################################################
##### With help of this https://www.virtuallyboring.com/add-virtual-machines-vmx-to-inventory-using-powershell/ ####################################
##### The same output can be extracted using the RVTools, but this result can be combined with some other commands as well as per the blog #########
####################################################################################################################################################
