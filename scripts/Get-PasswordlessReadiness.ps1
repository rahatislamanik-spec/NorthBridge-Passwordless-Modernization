<#
.SYNOPSIS
    Get-PasswordlessReadiness.ps1 — NorthBridge Financial Group IAM Architecture Team
.DESCRIPTION
    Audits all licensed Entra ID users for passwordless and phishing-resistant
    authentication method registration status. Identifies gaps in coverage
    across Windows Hello for Business and FIDO2 security keys.

    Microsoft Authenticator is counted as MFA (not phishing-resistant): the
    Graph authentication-methods API does not reliably expose whether a given
    Authenticator registration is enabled for passwordless phone sign-in, so
    this audit does not classify it as passwordless. This keeps the reported
    phishing-resistant coverage number conservative and never overstated.

    Designed for use during Phase 0 baseline assessment and ongoing program
    tracking throughout the Passwordless Authentication Modernization program.
.PARAMETER ExportPath
    Directory to write the CSV export to. Defaults to the current directory.
.PARAMETER DepartmentFilter
    Optional department name to scope the audit to a single department.
.PARAMETER GapReportOnly
    Switch. When set, outputs only the gap report (accounts with no
    phishing-resistant method registered) rather than the full coverage summary.
.OUTPUTS
    - Console summary with coverage percentages
    - CSV export: PasswordlessReadiness_[timestamp].csv
    - Gap report: accounts with no phishing-resistant method registered
.EXAMPLE
    .\Get-PasswordlessReadiness.ps1
.EXAMPLE
    .\Get-PasswordlessReadiness.ps1 -ExportPath "C:\Reports"
.EXAMPLE
    .\Get-PasswordlessReadiness.ps1 -DepartmentFilter "Branch Operations"
.NOTES
    Version: 1.1 | Date: June 2026
    Prerequisites: Microsoft Graph PowerShell SDK
    Permissions required:
        UserAuthenticationMethod.Read.All
        User.Read.All
#>

#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Identity.SignIns

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ExportPath = ".",

    [Parameter(Mandatory = $false)]
    [string]$DepartmentFilter = "",

    [Parameter(Mandatory = $false)]
    [switch]$GapReportOnly
)

# =============================================================================
# CONFIGURATION
# =============================================================================

$ScriptVersion  = "1.1"
$ScriptName     = "Get-PasswordlessReadiness"
$Organization   = "NorthBridge Financial Group"
$Timestamp      = Get-Date -Format "yyyyMMdd_HHmmss"
$ExportFile     = Join-Path $ExportPath "PasswordlessReadiness_$Timestamp.csv"
$GapReportFile  = Join-Path $ExportPath "PasswordlessGapReport_$Timestamp.csv"

# =============================================================================
# FUNCTIONS
# =============================================================================

function Write-Banner {
    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "  $Organization" -ForegroundColor Cyan
    Write-Host "  Passwordless Authentication Readiness Audit" -ForegroundColor Cyan
    Write-Host "  Script: $ScriptName v$ScriptVersion" -ForegroundColor Cyan
    Write-Host "  Run time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "--- $Title ---" -ForegroundColor Yellow
    Write-Host ""
}

function Connect-ToGraph {
    Write-Host "[*] Connecting to Microsoft Graph..." -ForegroundColor Cyan

    $RequiredScopes = @(
        "UserAuthenticationMethod.Read.All",
        "User.Read.All"
    )

    try {
        Connect-MgGraph -Scopes $RequiredScopes -NoWelcome -ErrorAction Stop
        $Context = Get-MgContext
        Write-Host "[+] Connected to tenant: $($Context.TenantId)" -ForegroundColor Green
        Write-Host "[+] Signed in as: $($Context.Account)" -ForegroundColor Green
    }
    catch {
        # Surface the failure to the caller instead of killing the host session.
        throw "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
    }
}

function Get-AllUsers {
    param([string]$Department)

    Write-Host "[*] Retrieving user accounts..." -ForegroundColor Cyan

    $UserFilter = "accountEnabled eq true and assignedLicenses/`$count ne 0"

    if ($Department -ne "") {
        $UserFilter += " and department eq '$Department'"
        Write-Host "[*] Filtering by department: $Department" -ForegroundColor Cyan
    }

    try {
        $Users = Get-MgUser -Filter $UserFilter `
            -Property "Id,DisplayName,UserPrincipalName,Department,JobTitle,AccountEnabled" `
            -CountVariable UserCount `
            -ConsistencyLevel eventual `
            -All `
            -ErrorAction Stop

        Write-Host "[+] Retrieved $($Users.Count) licensed user accounts" -ForegroundColor Green
        return $Users
    }
    catch {
        throw "Failed to retrieve users: $($_.Exception.Message)"
    }
}

function Get-AuthMethodsForUser {
    param([string]$UserId)

    $Methods = @{
        HasWindowsHelloForBusiness = $false
        HasFIDO2SecurityKey        = $false
        HasAuthenticator           = $false
        HasPasswordlessMFA         = $false
        HasSoftwareOTP             = $false
        HasSMSOTP                  = $false
        HasPassword                = $false
        PhishingResistantCount     = 0
        MethodList                 = @()
    }

    try {
        $AuthMethods = Get-MgUserAuthenticationMethod -UserId $UserId -ErrorAction Stop

        foreach ($Method in $AuthMethods) {
            $ODataType = $Method.AdditionalProperties["@odata.type"]

            switch ($ODataType) {
                "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod" {
                    $Methods.HasWindowsHelloForBusiness = $true
                    $Methods.PhishingResistantCount++
                    $Methods.MethodList += "WindowsHelloForBusiness"
                }
                "#microsoft.graph.fido2AuthenticationMethod" {
                    $Methods.HasFIDO2SecurityKey = $true
                    $Methods.PhishingResistantCount++
                    $Methods.MethodList += "FIDO2SecurityKey"
                }
                "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod" {
                    # NOTE: The Graph authentication-methods API does not reliably
                    # expose whether a given Authenticator registration is enabled
                    # for passwordless phone sign-in vs. push-only. Rather than
                    # infer it from properties Graph does not populate, this audit
                    # counts Authenticator as MFA (not phishing-resistant) so the
                    # coverage number is never overstated. Per-user passwordless
                    # capability for Authenticator would require the Entra
                    # authentication-method registration report (Reports.Read.All).
                    $Methods.HasAuthenticator = $true
                    $Methods.MethodList += "Authenticator"
                }
                "#microsoft.graph.softwareOathAuthenticationMethod" {
                    $Methods.HasSoftwareOTP = $true
                    $Methods.MethodList += "SoftwareOTP"
                }
                "#microsoft.graph.phoneAuthenticationMethod" {
                    $Methods.HasSMSOTP = $true
                    $Methods.MethodList += "SMSOTP"
                }
                "#microsoft.graph.passwordAuthenticationMethod" {
                    $Methods.HasPassword = $true
                    $Methods.MethodList += "Password"
                }
            }
        }

        # Phishing-resistant coverage counts only methods that can be verified
        # reliably per-user via the authentication-methods API.
        $Methods.HasPasswordlessMFA = (
            $Methods.HasWindowsHelloForBusiness -or
            $Methods.HasFIDO2SecurityKey
        )
    }
    catch {
        $Methods.MethodList += "ERROR:$($_.Exception.Message)"
    }

    return $Methods
}

function Build-UserRecord {
    param($User, $Methods)

    return [PSCustomObject]@{
        DisplayName                = $User.DisplayName
        UserPrincipalName          = $User.UserPrincipalName
        Department                 = $User.Department
        JobTitle                   = $User.JobTitle
        AccountEnabled             = $User.AccountEnabled
        HasPassword                = $Methods.HasPassword
        HasWindowsHelloForBusiness = $Methods.HasWindowsHelloForBusiness
        HasFIDO2SecurityKey        = $Methods.HasFIDO2SecurityKey
        HasAuthenticator           = $Methods.HasAuthenticator
        HasAnyPasswordlessMethod   = $Methods.HasPasswordlessMFA
        HasSoftwareOTP             = $Methods.HasSoftwareOTP
        HasSMSOTP                  = $Methods.HasSMSOTP
        PhishingResistantCount     = $Methods.PhishingResistantCount
        AuthMethodList             = ($Methods.MethodList -join " | ")
        RiskLevel                  = if ($Methods.HasPasswordlessMFA) { "Low" }
                                     elseif ($Methods.HasAuthenticator) { "Medium" }
                                     elseif ($Methods.HasSMSOTP -or $Methods.HasSoftwareOTP) { "High" }
                                     else { "Critical" }
        RecommendedAction          = if ($Methods.HasPasswordlessMFA) { "None — phishing-resistant method registered" }
                                     elseif (-not $Methods.HasAuthenticator -and -not $Methods.HasSMSOTP -and -not $Methods.HasSoftwareOTP) { "URGENT: Enroll in MFA immediately" }
                                     elseif ($Methods.HasAuthenticator) { "Upgrade to phishing-resistant method (WHfB or FIDO2)" }
                                     else { "Register WHfB or FIDO2 key" }
    }
}

function Write-ConsoleSummary {
    param([array]$Results)

    $Total                = $Results.Count
    $PasswordlessCount    = ($Results | Where-Object { $_.HasAnyPasswordlessMethod }).Count
    $WHfBCount            = ($Results | Where-Object { $_.HasWindowsHelloForBusiness }).Count
    $FIDO2Count           = ($Results | Where-Object { $_.HasFIDO2SecurityKey }).Count
    $AuthenticatorCount   = ($Results | Where-Object { -not $_.HasAnyPasswordlessMethod -and $_.HasAuthenticator }).Count
    $SMSOTPOnly           = ($Results | Where-Object { -not $_.HasAnyPasswordlessMethod -and -not $_.HasAuthenticator -and ($_.HasSMSOTP -or $_.HasSoftwareOTP) }).Count
    $NoMFA                = ($Results | Where-Object { $_.RiskLevel -eq "Critical" }).Count

    $PasswordlessPct      = if ($Total -gt 0) { [math]::Round(($PasswordlessCount / $Total) * 100, 1) } else { 0 }
    $NoMFAPct             = if ($Total -gt 0) { [math]::Round(($NoMFA / $Total) * 100, 1) } else { 0 }

    Write-SectionHeader "READINESS SUMMARY"

    Write-Host "  Total accounts assessed:          $Total" -ForegroundColor White
    Write-Host ""
    Write-Host "  PHISHING-RESISTANT COVERAGE" -ForegroundColor Cyan
    Write-Host "  Any passwordless method:          $PasswordlessCount ($PasswordlessPct%)" -ForegroundColor $(if ($PasswordlessPct -ge 80) { "Green" } elseif ($PasswordlessPct -ge 40) { "Yellow" } else { "Red" })
    Write-Host "    Windows Hello for Business:     $WHfBCount" -ForegroundColor White
    Write-Host "    FIDO2 Security Key:             $FIDO2Count" -ForegroundColor White
    Write-Host ""
    Write-Host "  RISK BREAKDOWN" -ForegroundColor Cyan
    Write-Host "  Authenticator/MFA only:           $AuthenticatorCount" -ForegroundColor Yellow
    Write-Host "  SMS/TOTP only:                    $SMSOTPOnly" -ForegroundColor DarkYellow
    Write-Host "  No MFA at all (CRITICAL):         $NoMFA ($NoMFAPct%)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Note: Microsoft Authenticator is counted as MFA, not as a" -ForegroundColor DarkGray
    Write-Host "  phishing-resistant/passwordless method. See script header." -ForegroundColor DarkGray
    Write-Host ""

    if ($NoMFA -gt 0) {
        Write-Host "  [!] ALERT: $NoMFA accounts have NO MFA registered." -ForegroundColor Red
        Write-Host "      These accounts are at critical risk of credential compromise." -ForegroundColor Red
        Write-Host "      Immediate enrollment action required." -ForegroundColor Red
    }

    if ($PasswordlessPct -lt 95) {
        $Gap = $Total - $PasswordlessCount
        Write-Host ""
        Write-Host "  [!] GAP TO TARGET: $Gap accounts need a phishing-resistant method" -ForegroundColor Yellow
        Write-Host "      to reach the 95% program target." -ForegroundColor Yellow
    } else {
        Write-Host "  [+] Program target of 95% phishing-resistant coverage ACHIEVED." -ForegroundColor Green
    }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

try {
    Write-Banner
    Connect-ToGraph

    Write-SectionHeader "USER RETRIEVAL"
    $Users = Get-AllUsers -Department $DepartmentFilter

    if ($Users.Count -eq 0) {
        Write-Host "[!] No matching users found. Nothing to audit." -ForegroundColor Yellow
        Disconnect-MgGraph -ErrorAction SilentlyContinue
        return
    }

    $Results    = [System.Collections.Generic.List[PSCustomObject]]::new()
    $Counter    = 0
    $TotalUsers = $Users.Count

    Write-SectionHeader "AUTHENTICATION METHOD AUDIT"
    Write-Host "[*] Auditing authentication methods for $TotalUsers accounts..." -ForegroundColor Cyan
    Write-Host "[*] This may take several minutes for large tenants." -ForegroundColor Cyan
    Write-Host "[*] Note: this audit makes one Graph call per user; on very large" -ForegroundColor Cyan
    Write-Host "    tenants expect throttling. A registration-report approach would" -ForegroundColor Cyan
    Write-Host "    scale better and is noted as a future enhancement." -ForegroundColor Cyan
    Write-Host ""

    foreach ($User in $Users) {
        $Counter++

        if ($Counter % 50 -eq 0 -or $Counter -eq $TotalUsers) {
            $Percent = [math]::Round(($Counter / $TotalUsers) * 100)
            Write-Progress -Activity "Auditing authentication methods" `
                -Status "$Counter of $TotalUsers users ($Percent%)" `
                -PercentComplete $Percent
        }

        $Methods = Get-AuthMethodsForUser -UserId $User.Id
        $Record  = Build-UserRecord -User $User -Methods $Methods
        $Results.Add($Record)
    }

    Write-Progress -Activity "Auditing authentication methods" -Completed

    # Console summary
    Write-ConsoleSummary -Results $Results

    # Export full report
    Write-SectionHeader "EXPORT"

    if (-not $GapReportOnly) {
        $Results | Export-Csv -Path $ExportFile -NoTypeInformation -Encoding UTF8
        Write-Host "[+] Full report exported: $ExportFile" -ForegroundColor Green
    }

    # Export gap report — accounts with no phishing-resistant method
    $GapAccounts = $Results | Where-Object { -not $_.HasAnyPasswordlessMethod }
    if ($GapAccounts.Count -gt 0) {
        $GapAccounts | Export-Csv -Path $GapReportFile -NoTypeInformation -Encoding UTF8
        Write-Host "[+] Gap report exported:  $GapReportFile" -ForegroundColor Green
        Write-Host "    Accounts in gap report: $($GapAccounts.Count)" -ForegroundColor Yellow
    }

    Write-SectionHeader "AUDIT COMPLETE"
    Write-Host "[+] $ScriptName v$ScriptVersion completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
    Write-Host "[+] Tenant: $((Get-MgContext).TenantId)" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host "[-] Audit failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue
}
