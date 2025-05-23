<#
.SYNOPSIS
    Checks if Default Authorization Settings - User consent policy assigned for applications is set to 'ManagePermissionGrantsForSelf.microsoft-user-default-low'

.DESCRIPTION

    Defines if user consent to apps is allowed, and if it is, which app consent policy (permissionGrantPolicy) governs the permissions.

    Queries policies/authorizationPolicy
    and returns the result of
     graph/policies/authorizationPolicy.permissionGrantPolicyIdsAssignedToDefaultUserRole -clike 'ManagePermissionGrantsForSelf*' -eq 'ManagePermissionGrantsForSelf.microsoft-user-default-low'

.EXAMPLE
    Test-MtEidscaAP08

    Returns the result of graph.microsoft.com/beta/policies/authorizationPolicy.permissionGrantPolicyIdsAssignedToDefaultUserRole -clike 'ManagePermissionGrantsForSelf*' -eq 'ManagePermissionGrantsForSelf.microsoft-user-default-low'
#>

function Test-MtEidscaAP08 {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if ( ($AuthorizationPolicyAvailable | where-object permissionGrantPolicyIdsAssignedToDefaultUserRole -Match 'ManagePermissionGrantsForSelf.microsoft-').Count -eq 0 ) {
            Add-MtTestResultDetail -SkippedBecause 'Custom' -SkippedCustomReason 'User Consent has been disabled or customized using Microsoft Graph or Microsoft Graph PowerShell without any assignment to custom policy.'
            return $null
    }
    $result = Invoke-MtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion beta

    [string]$tenantValue = $result.permissionGrantPolicyIdsAssignedToDefaultUserRole -clike 'ManagePermissionGrantsForSelf*'
    $testResult = $tenantValue -eq 'ManagePermissionGrantsForSelf.microsoft-user-default-low'
    $tenantValueNotSet = ($null -eq $tenantValue -or $tenantValue -eq "") -and 'ManagePermissionGrantsForSelf.microsoft-user-default-low' -notlike '*$null*'

    if($testResult){
        $testResultMarkdown = "Well done. The configuration in your tenant and recommended value is **'ManagePermissionGrantsForSelf.microsoft-user-default-low'** for **policies/authorizationPolicy**"
    } elseif ($tenantValueNotSet) {
        $testResultMarkdown = "Your tenant is **not configured explicitly**.`n`nThe recommended value is **'ManagePermissionGrantsForSelf.microsoft-user-default-low'** for **policies/authorizationPolicy**. It seems that you are using a default value by Microsoft. We recommend to set the setting value explicitly since non set values could change depending on what Microsoft decides the current default should be."
    } else {
        $testResultMarkdown = "Your tenant is configured as **$($tenantValue)**.`n`nThe recommended value is **'ManagePermissionGrantsForSelf.microsoft-user-default-low'** for **policies/authorizationPolicy**"
    }
    Add-MtTestResultDetail -Result $testResultMarkdown -Severity 'High'

    return $tenantValue
}
