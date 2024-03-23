function Push-CrmSolutionPatch {

<#
.SYNOPSIS
    Extracts managed patch from source environment and imports to destinations

.DESCRIPTION
    Provides an automated way to increment the version of a solution patch,
    extract it as a managed solution, and then import that zip file to the
    provided destination environment(s).

.PARAMETER PatchName
    The display name of the patch to extract and push

.PARAMETER SourceConnection
    The CRM connection to the source environment with the solution patch

.PARAMETER DestConnections
    The CRM connection(s) where the patch should be imported

.PARAMETER Synchronous
    Import defaults to Asynchronous. The sync switch is used for synchronous imports

.PARAMETER KeepCurrentVersion
    Skips incrementing patch version prior to extraction. Useful for pushing empty patches.

.EXAMPLE
    Push-CrmSolutionPatch -PatchName Customization.123.NewFields -SourceConnection $dev -DestConnections $test,$prod

.INPUTS
    String,Microsoft.Xrm.Tooling.Connector.CrmServiceClient

.OUTPUTS
    None

.NOTES
    Author:  Greg McMurray
 
#>

  param (
    [CmdletBinding()]
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$PatchName,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [alias("conn")]
    [Microsoft.Xrm.Tooling.Connector.CrmServiceClient]$SourceConnection,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [alias("dest")]
    [Microsoft.Xrm.Tooling.Connector.CrmServiceClient[]]$DestConnections,
    [alias("sync")]
    [switch]$Synchronous,
    [alias("keep")]
    [switch]$KeepCurrentVersion
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

      $solutions = Get-CrmRecords -conn $dev -EntityLogicalName solution -FilterAttribute friendlyname -FilterOperator "like" -FilterValue  "$PatchName"  -Fields solutionid,uniquename,friendlyname,version
      if ($solutions.CrmRecords.Count -gt 0) {
        $sol = $solutions.CrmRecords[0]
        Write-Verbose "Found $PatchName patch as $($sol.uniquename)"

        # increment patch version
        $v = [version]$sol.version
        $ver = [version]::new($v.Major, $v.Minor, $v.Build, $v.Revision+1)
        if ($KeepCurrentVersion) {
            Write-Verbose "Skipping version increment and staying at $ver"
        } else {
            Write-Verbose "Incrementing patch version from $v to $ver"
            $versionUpdate = Set-CrmSolutionVersionNumber -conn $dev -SolutionName $sol.uniquename -VersionNumber $ver
        }
        
        # export patch as managed solution
        $patchExportParams = @{
          conn = $SourceConnection
          Managed = $true
          SolutionName = $sol.uniquename
          SolutionZipFileName = "$($sol.friendlyname)_$ver.zip"
          SolutionFilePath = $env:TEMP
        }
        $fullPath = Join-Path -Path $patchExportParams.SolutionFilePath -ChildPath $patchExportParams.SolutionZipFileName

        Write-Verbose "Extracting patch to $fullPath"
        if (Test-Path $fullPath) {
          Write-Verbose "Removing existing zip file before extraction..."
          Remove-Item $fullPath
        }
        $exported = Export-CrmSolution @patchExportParams
        
        # import patch to given environments
        if (Test-Path $fullPath) {
          foreach ($dest in $DestConnections) {
            Write-Verbose "Uploading patch to $($dest.ConnectedOrgFriendlyName)"
            if ($Synchronous) {
                $testImport = Import-CrmSolution -conn $dest -SolutionFilePath $fullPath
            } else {
                $testImport = Import-CrmSolutionAsync -conn $dest -SolutionFilePath $fullPath
            }
          }
          Remove-Item $fullPath
          Write-Verbose 'Removed temporary zip file'
        } else {
          Write-Error "Patch zip file missing from file system - unable to apply to test and prod environments"
        }
      } else {
        Write-Error "No matching patches found for $PatchName"
      }
    }

    END { }
}
