function New-CrmSolutionPatch {

<#
.SYNOPSIS
    Creates an empty patch

.DESCRIPTION
    Creates a new empty patch by splitting on the period in the patch 
    name to find the parent patch. It finds all versions of the parent and
    increments the highest build number x (1.2.x.0) by 1 and sets 0 as the
    revision. 

.PARAMETER PatchName
    The display name of the patch to split and return the parent patch name.

.EXAMPLE
     New-CrmSolutionPatch -PatchName Customizations.123.PatchDescription

.INPUTS
    String

.OUTPUTS
    None

.NOTES
    Author:  Greg McMurray
 
#>

  param (
    [CmdletBinding()]
    [parameter(Mandatory=$false)]
    [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]$conn,
    [Parameter(Mandatory,ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [string]$PatchName
    )

    BEGIN {

      $XrmModule = Get-Module Microsoft.Xrm.Data.PowerShell
      if ($XrmModule) {
        Write-Verbose 'Microsoft.Xrm.Data.PowerShell module already installed'
      } else {
        Write-Verbose 'Installing Microsoft.Xrm.Data.PowerShell module'
        # Enable TLS 1.2 for PowerShell Gallery Support to install necessary modules
        # https://learn.microsoft.com/en-us/powershell/gallery/powershellget/install-powershellget?view=powershellget-2.x&viewFallbackFrom=powershell-7
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        Install-Module Microsoft.Xrm.Data.PowerShell -Scope CurrentUser -AllowClobber
      }
      
    }

    PROCESS {

      #$PatchName = 'Customizations.123.TestPatch'

      $parentSolution = $PatchName -split '\.' | Select-Object -First 1
      Write-Verbose "Detected parent solution as: $parentSolution"

      $solutions = Get-CrmRecords -EntityLogicalName solution -FilterAttribute friendlyname -FilterOperator "like" -FilterValue "$parentSolution%" -Fields solutionid,uniquename,friendlyname,version
      Write-Verbose "Found $($solutions.CrmRecords.Count) solutions/patches for $parentSolution"

      $minMax = $solutions.CrmRecords | % { [Version]$_.version } | Measure-Object -max -min
      $v = [Version]$minMax.Maximum
      $newVersion = [Version]::new($v.Major, $v.Minor, $v.Build+1, 0)
      Write-Verbose "Current max version: $($minMax.Maximum)"
      Write-Verbose "Using $newVersion for $PatchName"

      $patchDetails = @{
        ParentSolutionUniqueName = $parentSolution
        DisplayName = $PatchName
        VersionNumber = $newVersion.ToString()
      }
      Write-Verbose 'Creating patch ...'
      $result = Invoke-CrmAction -Name CloneAsPatch -Parameters $patchDetails

    }

    END { }
}
