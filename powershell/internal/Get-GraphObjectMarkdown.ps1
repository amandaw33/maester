﻿<#
 .Synopsis
    Creates a markdown of Graph results to be used in test results.

 .Description
    Generates a list of markdown items with support for deeplinks to the Entra portal for known Graph object types.

 .Example

    Get-GraphResultMarkdown -GraphObjects $policies -GraphObjectType ConditionalAccess

    Returns a markdown list of Conditional Access policies with deeplinks to the relevant CA blade in Entra portal.
#>

function Get-GraphObjectMarkdown {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # Collection of Graph objects to display as markdown.
        [Parameter(Mandatory = $true)]
        [Object[]] $GraphObjects,

        # The type of graph object, this will be used to show the right deeplink to the test results report.
        # If not specified, the function will try to determine the type based on the object.
        [Parameter(Mandatory = $false)]
        [ValidateSet('AuthenticationMethod', 'AuthorizationPolicy', 'ConditionalAccess', 'ConsentPolicy',
            'Devices', 'Domains', 'Groups', 'IdentityProtection', 'Users', 'UserRole'
            )]
        [string] $GraphObjectType,

        [Parameter(Mandatory = $false)]
        [switch] $AsPlainTextLink
    )

    $markdownLinkTemplate = @{
        AuthenticationMethod = "$($__MtSession.AdminPortalUrl.Entra)#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/AdminAuthMethods"
        AuthorizationPolicy  = "$($__MtSession.AdminPortalUrl.Entra)#view/Microsoft_AAD_UsersAndTenants/UserManagementMenuBlade/~/UserSettings/menuId/UserSettings"
        ConditionalAccess    = "$($__MtSession.AdminPortalUrl.Entra)#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}"
        ConsentPolicy        = "$($__MtSession.AdminPortalUrl.Entra)#view/Microsoft_AAD_IAM/ConsentPoliciesMenuBlade/~/UserSettings"
        Devices              = "$($__MtSession.AdminPortalUrl.Entra)#view/Microsoft_AAD_Devices/DeviceDetailsMenuBlade/~/Properties/objectId/{0}"
        Domains              = "$($__MtSession.AdminPortalUrl.Entra)#view/Microsoft_AAD_IAM/DomainsManagementMenuBlade/~/CustomDomainNames"
        Groups               = "$($__MtSession.AdminPortalUrl.Entra)#view/Microsoft_AAD_IAM/GroupDetailsMenuBlade/~/Overview/groupId/{0}"
        IdentityProtection   = "$($__MtSession.AdminPortalUrl.Entra)#view/Microsoft_AAD_IAM/IdentityProtectionMenuBlade/~/UsersAtRiskAlerts/fromNav/Identity"
        Users                = "$($__MtSession.AdminPortalUrl.Entra)#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/{0}"
        UserRole             = "$($__MtSession.AdminPortalUrl.Entra)#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/AdministrativeRole/userId/{0}"
    }

    $graphObjectTypeMapping = @{
        '#microsoft.graph.user' = 'Users'
        '#microsoft.graph.group' = 'Groups'
        '#microsoft.graph.device' = 'Devices'
    }

    # This will work for now, will need to add switch as we add support for complex urls like Applications blade, etc..
    $result = ""
    foreach ($item in $GraphObjects) {
        $displayName = Get-ObjectProperty $item 'displayName'
        $currentGraphObjectType = $GraphObjectType
        if (-not $currentGraphObjectType) {
            $dataType = Get-ObjectProperty $item '@odata.type'
            if ($graphObjectTypeMapping.ContainsKey($dataType)) {
                $currentGraphObjectType = $graphObjectTypeMapping[$dataType]
            } else {
                # Unknown type
                $displayName = "$displayName ($dataType - $($item.id))"
            }
        }

        if($currentGraphObjectType) {
            $link = $markdownLinkTemplate[$currentGraphObjectType] -f $item.id
        }
        else {
            $link = "#"
        }

        if ($AsPlainTextLink) {
            $result += "[$displayName]($link)"
        } else {
            $result += "  - [$displayName]($link)`n"
        }
    }

    return $result
}