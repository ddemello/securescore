#Marcos Negrao and Denis Mello - Microsoft
# Read the Tenant IDs from an external file (tenantid.txt)
$TenantIDs = Get-Content -Path "c:\temp\TenantID.txt"

# Set the CSV file to be created in the Downloads folder
$MyCSVPath = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path + "\" + "Mission65-" + $(Get-Date -Format "yyyy-MM-dd_HH-mm") + ".csv"

foreach ($TenantID in $TenantIDs)
{
    # Connect to the Azure account with the specified Tenant ID
    Connect-AzAccount -Tenant $TenantID -WarningAction SilentlyContinue

    # Get the subscriptions associated with the Tenant ID
    $MyAzSubscriptions = Get-AzSubscription -TenantId $TenantID -WarningAction SilentlyContinue

    foreach ($MyAzSubscription in $MyAzSubscriptions)
    {
        Set-AzContext -Subscription $MyAzSubscription -Tenant $TenantID

        # Get the Secure Score & all controls for each subscription
        $MyAzSecureScore = Get-AzSecuritySecureScore
        $MyAzSecureScoreControls = Get-AzSecuritySecureScoreControl

        foreach ($MyAzSecureScoreControl in $MyAzSecureScoreControls)
        {
            # Create an object containing the Secure Score data
            $MyCSVRow = [PSCustomObject]@{
                Date = (Get-Date).Date
                SubscriptionID = $MyAzSubscription.Id
                SubscriptionName = $MyAzSubscription.Name
                SubscriptionCurrentScore = $MyAzSecureScore.CurrentScore
                SubscriptionMaxScore = $MyAzSecureScore.MaxScore
                SubscriptionSecureScorePercentage = [math]::Round(($MyAzSecureScore.Percentage * 100))
                SubscriptionWeight = $MyAzSecureScore.Weight

                ControlName = $MyAzSecureScoreControl.Name
                ControlDisplayName = $MyAzSecureScoreControl.DisplayName
                ControlCurrentScore = $MyAzSecureScoreControl.CurrentScore
                ControlMaxScore = $MyAzSecureScoreControl.MaxScore
                ControlPercentage = [math]::Round(($MyAzSecureScoreControl.Percentage * 100))
                ControlWeight = $MyAzSecureScoreControl.Weight
                ControlHealthyResourceCount = $MyAzSecureScoreControl.HealthyResourceCount
                ControlUnhealthyResourceCount = $MyAzSecureScoreControl.UnhealthyResourceCount
                ControlNotApplicableResourceCount = $MyAzSecureScoreControl.NotApplicableResourceCount
            }

            # Append the Secure Score to the CSV file
            $MyCSVRow | Export-Csv $MyCSVPath -Append
        }
    }
}