Clear-Host
write-host "Starting script at $(Get-Date)"

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Handle cases where the user has multiple subscriptions
$subs = Get-AzSubscription | Select-Object
if($subs.GetType().IsArray -and $subs.length -gt 1){
        Write-Host "You have multiple Azure subscriptions - please select the one you want to use:"
        for($i = 0; $i -lt $subs.length; $i++)
        {
                Write-Host "[$($i)]: $($subs[$i].Name) (ID = $($subs[$i].Id))"
        }
        $selectedIndex = -1
        $selectedValidIndex = 0
        while ($selectedValidIndex -ne 1)
        {
                $enteredValue = Read-Host("Enter 0 to $($subs.Length - 1)")
                if (-not ([string]::IsNullOrEmpty($enteredValue)))
                {
                    if ([int]$enteredValue -in (0..$($subs.Length - 1)))
                    {
                        $selectedIndex = [int]$enteredValue
                        $selectedValidIndex = 1
                    }
                    else
                    {
                        Write-Output "Please enter a valid subscription number."
                    }
                }
                else
                {
                    Write-Output "Please enter a valid subscription number."
                }
        }
        $selectedSub = $subs[$selectedIndex].Id
        Select-AzSubscription -SubscriptionId $selectedSub
        az account set --subscription $selectedSub
}

# Register resource providers
Write-Host "Registering resource providers...";
$provider_list = "Microsoft.EventHub", "Microsoft.StreamAnalytics"
foreach ($provider in $provider_list){
    $result = Register-AzResourceProvider -ProviderNamespace $provider
    $status = $result.RegistrationState
    Write-Host "$provider : $status"
}

# Generate unique random suffix
[string]$suffix =  -join ((48..57) + (97..122) | Get-Random -Count 7 | % {[char]$_})
Write-Host "Your randomly-generated suffix for Azure resources is $suffix"
$resourceGroupName = "dp203-$suffix"

# Choose a random region
$locations = Get-AzLocation | Where-Object {
    $_.Providers -contains "Microsoft.EventHub" -and
    $_.Providers -contains "Microsoft.StreamAnalytics"
}
$max_index = $locations.Count - 1
# Start with preferred region if specified, otherwise choose one at random
if ($args.count -gt 0 -And $args[0] -in $locations.Location)
{
    $Region = $args[0]
}
else {
    $rand = (0..$max_index) | Get-Random
    $Region = $locations.Get($rand).Location
}

Write-Host "Creating $resourceGroupName resource group in $Region ..."
New-AzResourceGroup -Name $resourceGroupName -Location $Region | Out-Null

# Create Azure resources
$eventNsName = "events$suffix"
$eventHubName = "eventhub$suffix"

write-host "Creating Azure resources in $resourceGroupName resource group..."
write-host "(This may take some time!)"
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
  -TemplateFile "setup.json" `
  -Mode Complete `
  -uniqueSuffix $suffix `
  -eventNsName $eventNsName `
  -eventHubName $eventHubName `
  -Force

# Prepare JavaScript EventHub client app
write-host "Creating Event Hub client app..."
npm install @azure/event-hubs@5.9.0 -s
Update-AzConfig -DisplayBreakingChangeWarning $false | Out-Null
$conStrings = Get-AzEventHubKey -ResourceGroupName $resourceGroupName -NamespaceName $eventNsName -AuthorizationRuleName "RootManageSharedAccessKey"
$conString = $conStrings.PrimaryConnectionString
$javascript = Get-Content -Path "setup.txt" -Raw
$javascript = $javascript.Replace("EVENTHUBCONNECTIONSTRING", $conString)
$javascript = $javascript.Replace("EVENTHUBNAME",$eventHubName)
Set-Content -Path "orderclient.js" -Value $javascript

write-host "Script completed at $(Get-Date)"