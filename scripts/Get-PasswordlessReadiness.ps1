# =============================================================================
# Get-PasswordlessReadiness.ps1
# NorthBridge Financial Group — IAM Architecture Team
# Version: 1.0 | Date: June 2026
# =============================================================================
#
# DESCRIPTION:
#   Audits all licensed Entra ID users for passwordless and phishing-resistant
#   authentication method registration status. Identifies gaps in coverage
#   across Windows Hello for Business, FIDO2 security keys, and Microsoft
#   Authenticator passwordless phone sign-in.
#
#   Designed for use during Phase 0 baseline assessment and ongoing program
#   tracking throughout the Passwordless Authentication Modernization program.
#
# OUTPUT:
#   - Console summary with coverage percentages
#   - CSV export: PasswordlessReadiness_[timestamp].csv
#   - Gap report: accounts with no phishing-resistant method registered
#
# PREREQUISITES:
#   - Microsoft Graph PowerShell SDK
#   - Permissions required:
#       UserAuthenticationMethod.Read.All
#       User.Read.All
#       Reports.Read.All
#
# USAGE:
#   .\Get-PasswordlessReadiness.ps1
#   .\Get-PasswordlessReadiness.ps1 -ExportPath "C:\Reports"
#   .\Get-PasswordlessReadiness.ps1 -DepartmentFilter "Branch Operations"
#
# =============================================================================

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

$ScriptVersion  = "1.0"
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
        "User.Read.All",
        "Reports.Read.All"
    )

    try {
        Connect-MgGraph -Scopes $RequiredScopes -NoWelcome -ErrorAction Stop
        $Context = Get-MgContext
        Write-Host "[+] Connected to tenant: $($Context.TenantId)" -ForegroundColor Green
        Write-Host "[+] Signed in as: $($Context.Account)" -ForegroundColor Green
    }
    catch {
        Write-Host "[-] Failed to connect to Microsoft Graph." -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
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
        Write-Host "[-] Failed to retrieve users." -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

function Get-AuthMethodsForUser {
    param([string]$UserId)

    $Methods = @{
        HasWindowsHelloForBusiness  = $false
        HasFIDO2SecurityKey         = $false
        HasAuthenticatorPasswordless = $false
        HasPasswordlessMFA          = $false
        HasPushMFA                  = $false
        HasSoftwareOTP              = $false
        HasSMSOTP                   = $false
        HasPassword                 = $false
        PhishingResistantCount      = 0
        MethodList                  = @()
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
                    $AuthenticatorMethod = Get-MgUserAuthenticationMicrosoftAuthenticatorMethod `
                        -UserId $UserId -MicrosoftAuthenticatorAuthenticationMethodId $Method.Id `
                        -ErrorAction SilentlyContinue

                    if ($AuthenticatorMethod.AuthenticatorAppVersion -and
                        $AuthenticatorMethod.AdditionalProperties["phoneAppVersion"]) {
                        $Methods.HasAuthenticatorPasswordless = $true
                        $Methods.PhishingResistantCount++
                        $Methods.MethodList += "AuthenticatorPasswordless"
                    } else {
                        $Methods.HasPushMFA = $true
                        $Methods.MethodList += "AuthenticatorPush"
                    }
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

        $Methods.HasPasswordlessMFA = (
            $Methods.HasWindowsHelloForBusiness -or
            $Methods.HasFIDO2SecurityKey -or
            $Methods.HasAuthenticatorPasswordless
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
        DisplayName                  = $User.DisplayName
        UserPrincipalName            = $User.UserPrincipalName
        Department                   = $User.Department
        JobTitle                     = $User.JobTitle
        AccountEnabled               = $User.AccountEnabled
        HasPassword                  = $Methods.HasPassword
        HasWindowsHelloForBusiness   = $Methods.HasWindowsHelloForBusiness
        HasFIDO2SecurityKey          = $Methods.HasFIDO2SecurityKey
        HasAuthenticatorPasswordless = $Methods.HasAuthenticatorPasswordless
        HasAnyPasswordlessMethod     = $Methods.HasPasswordlessMFA
        HasPushMFA                   = $Methods.HasPushMFA
        HasSoftwareOTP               = $Methods.HasSoftwareOTP
        HasSMSOTP                    = $Methods.HasSMSOTP
        PhishingResistantCount       = $Methods.PhishingResistantCount
        AuthMethodList               = ($Methods.MethodList -join " | ")
        RiskLevel                    = if ($Methods.HasPasswordlessMFA) { "Low" }
                                       elseif ($Methods.HasPushMFA) { "Medium" }
                                       elseif ($Methods.HasSMSOTP -or $Methods.HasSoftwareOTP) { "High" }
                                       else { "Critical" }
        RecommendedAction            = if ($Methods.HasPasswordlessMFA) { "None — phishing-resistant method registered" }
                                       elseif (-not $Methods.HasPushMFA -and -not $Methods.HasSMSOTP) { "URGENT: Enroll in MFA immediately" }
                                       elseif ($Methods.HasWindowsHelloForBusiness -eq $false -and $Methods.HasFIDO2SecurityKey -eq $false) { "Register WHfB or FIDO2 key" }
                                       else { "Upgrade to phishing-resistant method" }
    }
}

function Write-ConsoleSummary {
    param([array]$Results)

    $Total                  = $Results.Count
    $PasswordlessCount      = ($Results | Where-Object { $_.HasAnyPasswordlessMethod }).Count
    $WHfBCount              = ($Results | Where-Object { $_.HasWindowsHelloForBusiness }).Count
    $FIDO2Count             = ($Results | Where-Object { $_.HasFIDO2SecurityKey }).Count
    $AuthenticatorPLCount   = ($Results | Where-Object { $_.HasAuthenticatorPasswordless }).Count
    $PushMFAOnly            = ($Results | Where-Object { -not $_.HasAnyPasswordlessMethod -and $_.HasPushMFA }).Count
    $SMSOTPOnly             = ($Results | Where-Object { -not $_.HasAnyPasswordlessMethod -and -not $_.HasPushMFA -and ($_.HasSMSOTP -or $_.HasSoftwareOTP) }).Count
    $NoMFA                  = ($Results | Where-Object { $_.RiskLevel -eq "Critical" }).Count

    $PasswordlessPct        = [math]::Round(($PasswordlessCount / $Total) * 100, 1)
    $NoMFAPct               = [math]::Round(($NoMFA / $Total) * 100, 1)

    Write-SectionHeader "READINESS SUMMARY"

    Write-Host "  Total accounts assessed:          $Total" -ForegroundColor White
    Write-Host ""
    Write-Host "  PHISHING-RESISTANT COVERAGE" -ForegroundColor Cyan
    Write-Host "  Any passwordless method:          $PasswordlessCount ($PasswordlessPct%)" -ForegroundColor $(if ($PasswordlessPct -ge 80) { "Green" } elseif ($PasswordlessPct -ge 40) { "Yellow" } else { "Red" })
    Write-Host "    Windows Hello for Business:     $WHfBCount" -ForegroundColor White
    Write-Host "    FIDO2 Security Key:             $FIDO2Count" -ForegroundColor White
    Write-Host "    Authenticator Passwordless:     $AuthenticatorPLCount" -ForegroundColor White
    Write-Host ""
    Write-Host "  RISK BREAKDOWN" -ForegroundColor Cyan
    Write-Host "  Push MFA only (no passwordless):  $PushMFAOnly" -ForegroundColor Yellow
    Write-Host "  SMS/TOTP only:                    $SMSOTPOnly" -ForegroundColor DarkYellow
    Write-Host "  No MFA at all (CRITICAL):         $NoMFA ($NoMFAPct%)" -ForegroundColor Red
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

Write-Banner
Connect-ToGraph

Write-SectionHeader "USER RETRIEVAL"
$Users = Get-AllUsers -Department $DepartmentFilter

$Results    = [System.Collections.Generic.List[PSCustomObject]]::new()
$Counter    = 0
$TotalUsers = $Users.Count

Write-SectionHeader "AUTHENTICATION METHOD AUDIT"
Write-Host "[*] Auditing authentication methods for $TotalUsers accounts..." -ForegroundColor Cyan
Write-Host "[*] This may take several minutes for large tenants." -ForegroundColor Cyan
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

Disconnect-MgGraph -ErrorAction SilentlyContinue
