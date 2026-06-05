# =============================================================================
# New-TAPForUser.ps1
# NorthBridge Financial Group - IAM Architecture Team
# Version: 1.0 | Date: June 2026
# =============================================================================
#
# DESCRIPTION:
#   Generates a compliant Temporary Access Pass (TAP) for a specified user
#   in Microsoft Entra ID. Enforces NorthBridge TAP policy controls:
#     - Single-use only
#     - Maximum 4-hour lifetime
#     - Requires valid ServiceNow ticket number for audit trail
#     - Logs all issuance events to local audit log
#     - Blocks issuance if user already has an active TAP
#
# AUTHORIZED USERS: Help Desk Tier 2 and above only
#
# PREREQUISITES:
#   - Microsoft Graph PowerShell SDK
#   - Permissions: UserAuthenticationMethod.ReadWrite.All, User.Read.All
#
# USAGE:
#   .\New-TAPForUser.ps1 -UserPrincipalName "jane.smith@northbridge.ca" -TicketNumber "INC0042891"
#   .\New-TAPForUser.ps1 -UserPrincipalName "john.doe@northbridge.ca" -TicketNumber "INC0042901" -LifetimeMinutes 120
#
# POLICY REFERENCE: NorthBridge TAP Policy - target-state-architecture.md Section 7
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^INC\d{7}$')]
    [string]$TicketNumber,

    [Parameter(Mandatory = $false)]
    [ValidateRange(60, 240)]
    [int]$LifetimeMinutes = 240,

    [Parameter(Mandatory = $false)]
    [string]$AuditLogPath = "."
)

# =============================================================================
# CONFIGURATION
# =============================================================================

$ScriptVersion   = "1.0"
$ScriptName      = "New-TAPForUser"
$Organization    = "NorthBridge Financial Group"
$MaxLifetime     = 240
$SingleUse       = $true
$AuditFile       = Join-Path $AuditLogPath ("TAP_AuditLog_" + (Get-Date -Format 'yyyyMMdd') + ".csv")

# =============================================================================
# FUNCTIONS
# =============================================================================

function Write-Banner {
    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host "  $Organization" -ForegroundColor Cyan
    Write-Host "  Temporary Access Pass Issuance Tool" -ForegroundColor Cyan
    Write-Host "  $ScriptName v$ScriptVersion" -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [!] AUTHORIZED USERS ONLY - Tier 2 Help Desk and above" -ForegroundColor Yellow
    Write-Host "  [!] TAP credentials are single-use and expire in $LifetimeMinutes minutes" -ForegroundColor Yellow
    Write-Host "  [!] All issuance events are logged and audited" -ForegroundColor Yellow
    Write-Host ""
}

function Connect-ToGraph {
    Write-Host "[*] Connecting to Microsoft Graph..." -ForegroundColor Cyan
    try {
        Connect-MgGraph -Scopes @(
            "UserAuthenticationMethod.ReadWrite.All",
            "User.Read.All"
        ) -NoWelcome -ErrorAction Stop
        $Context = Get-MgContext
        Write-Host "[+] Connected successfully" -ForegroundColor Green
        Write-Host "[+] Operator: $($Context.Account)" -ForegroundColor Green
        return $Context.Account
    }
    catch {
        Write-Host "[-] Graph connection failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

function Get-TargetUser {
    param([string]$UPN)
    Write-Host "[*] Looking up user: $UPN" -ForegroundColor Cyan
    try {
        $User = Get-MgUser -UserId $UPN `
            -Property "Id,DisplayName,UserPrincipalName,Department,AccountEnabled" `
            -ErrorAction Stop
        if (-not $User.AccountEnabled) {
            Write-Host "[-] Account is disabled. TAP cannot be issued." -ForegroundColor Red
            exit 1
        }
        Write-Host "[+] User found: $($User.DisplayName) | Dept: $($User.Department)" -ForegroundColor Green
        return $User
    }
    catch {
        Write-Host "[-] User not found: $UPN" -ForegroundColor Red
        exit 1
    }
}

function Test-ExistingTAP {
    param([string]$UserId)
    Write-Host "[*] Checking for existing active TAP..." -ForegroundColor Cyan
    try {
        $ExistingMethods = Get-MgUserAuthenticationMethod -UserId $UserId -ErrorAction Stop
        $ExistingTAP = $ExistingMethods | Where-Object {
            $_.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.temporaryAccessPassAuthenticationMethod"
        }
        if ($ExistingTAP) {
            Write-Host "[-] BLOCKED: User already has an active TAP." -ForegroundColor Red
            Write-Host "    Wait for existing TAP to expire or delete it in Entra ID first." -ForegroundColor Yellow
            exit 1
        }
        Write-Host "[+] No active TAP found - cleared to issue." -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Could not verify TAP status: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

function New-TAPCredential {
    param([string]$UserId, [int]$Lifetime, [bool]$IsOneTimeUse)
    Write-Host "[*] Generating TAP - Lifetime: $Lifetime min | Single-use: $IsOneTimeUse" -ForegroundColor Cyan
    $TAPBody = @{
        lifetimeInMinutes = $Lifetime
        isUsableOnce      = $IsOneTimeUse
    }
    try {
        $TAP = New-MgUserAuthenticationTemporaryAccessPassMethod `
            -UserId $UserId `
            -BodyParameter $TAPBody `
            -ErrorAction Stop
        return $TAP
    }
    catch {
        Write-Host "[-] TAP generation failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "    Verify TAP is enabled in Entra ID Authentication Methods policy." -ForegroundColor Yellow
        exit 1
    }
}

function Write-TAPResult {
    param($TAP, $User)
    $ExpiryTime = (Get-Date).AddMinutes($LifetimeMinutes).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Green
    Write-Host "  TAP ISSUED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "=================================================================" -ForegroundColor Green
    Write-Host "  User:       $($User.DisplayName)" -ForegroundColor White
    Write-Host "  UPN:        $($User.UserPrincipalName)" -ForegroundColor White
    Write-Host "  Ticket:     $TicketNumber" -ForegroundColor White
    Write-Host "  Lifetime:   $LifetimeMinutes minutes" -ForegroundColor White
    Write-Host "  Expires:    $ExpiryTime" -ForegroundColor White
    Write-Host "  Single-use: $SingleUse" -ForegroundColor White
    Write-Host ""
    Write-Host "  TAP CREDENTIAL (copy now - displayed once only):" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  $($TAP.TemporaryAccessPass)" -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    Write-Host "  INSTRUCTIONS FOR HELP DESK:" -ForegroundColor Cyan
    Write-Host "  1. Read TAP to user verbally or paste into secure chat only" -ForegroundColor White
    Write-Host "  2. Direct user to sign in at aka.ms/mysecurityinfo" -ForegroundColor White
    Write-Host "  3. User registers permanent passwordless method during TAP session" -ForegroundColor White
    Write-Host "  4. TAP expires after first use or at $ExpiryTime" -ForegroundColor White
    Write-Host "  5. Do NOT email or send TAP in plaintext" -ForegroundColor Yellow
    Write-Host ""
}

function Write-AuditLog {
    param($TAP, $User, [string]$Operator)
    $AuditEntry = [PSCustomObject]@{
        Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Operator          = $Operator
        TargetUPN         = $User.UserPrincipalName
        TargetDisplayName = $User.DisplayName
        Department        = $User.Department
        TicketNumber      = $TicketNumber
        LifetimeMinutes   = $LifetimeMinutes
        SingleUse         = $SingleUse
        TAPId             = $TAP.Id
        ExpiresAt         = (Get-Date).AddMinutes($LifetimeMinutes).ToString("yyyy-MM-dd HH:mm:ss")
        ScriptVersion     = $ScriptVersion
    }
    $AuditEntry | Export-Csv -Path $AuditFile -NoTypeInformation -Append -Encoding UTF8
    Write-Host "[+] Audit log entry written: $AuditFile" -ForegroundColor Green
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

Write-Banner

if ($LifetimeMinutes -gt $MaxLifetime) {
    Write-Host "[-] Lifetime exceeds NorthBridge policy maximum of $MaxLifetime minutes." -ForegroundColor Red
    exit 1
}

$Operator = Connect-ToGraph
$User     = Get-TargetUser -UPN $UserPrincipalName

Test-ExistingTAP -UserId $User.Id

Write-Host ""
Write-Host "[?] Confirm TAP issuance for $($User.DisplayName)?" -ForegroundColor Yellow
Write-Host "    Ticket: $TicketNumber | Lifetime: $LifetimeMinutes min | Single-use: $SingleUse" -ForegroundColor White
Write-Host ""
$Confirm = Read-Host "    Type YES to confirm"

if ($Confirm -ne "YES") {
    Write-Host "[!] TAP issuance cancelled by operator." -ForegroundColor Yellow
    exit 0
}

$TAP = New-TAPCredential -UserId $User.Id -Lifetime $LifetimeMinutes -IsOneTimeUse $SingleUse

Write-TAPResult -TAP $TAP -User $User
Write-AuditLog  -TAP $TAP -User $User -Operator $Operator

Write-Host "[+] $ScriptName v$ScriptVersion complete" -ForegroundColor Green
Write-Host ""

Disconnect-MgGraph -ErrorAction SilentlyContinue
