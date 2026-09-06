<#
.SYNOPSIS
    New-TAPForUser.ps1 — NorthBridge Financial Group IAM Architecture Team
.DESCRIPTION
    Issues a Temporary Access Pass (TAP) for a specified user in Microsoft
    Entra ID, requesting NorthBridge policy-compliant values:
      - Single-use only
      - Maximum 4-hour lifetime
      - Requires a valid ServiceNow ticket number for the audit trail
      - Writes a local issuance record (defense-in-depth)
      - Blocks issuance if the user already has an active TAP

    IMPORTANT — where enforcement actually lives:
    This script *requests* compliant TAP values. The authoritative ceiling on
    TAP lifetime and single-use is the Entra ID Authentication Methods policy
    (TAP settings), not this script. The values below cannot exceed what the
    tenant policy permits, and the tenant policy — not this tool — is the
    control a reviewer or auditor should rely on. The Entra audit log is the
    system of record for issuance; the local CSV here is a convenience copy.

    AUTHORIZED USERS: Help Desk Tier 2 and above only.
    POLICY REFERENCE: NorthBridge TAP Policy — target-state-architecture.md Section 7
.PARAMETER UserPrincipalName
    The UPN of the user to issue a Temporary Access Pass for. Mandatory.
.PARAMETER TicketNumber
    The ServiceNow incident ticket number authorizing this action, in the
    format INC followed by 7 digits (e.g. INC0042891). Mandatory.
.PARAMETER LifetimeMinutes
    TAP lifetime in minutes. Must be between 60 and 240 (4 hours max). Defaults to 240.
.PARAMETER AuditLogPath
    Directory to write the local issuance record CSV to. Defaults to the current directory.
.PARAMETER Force
    Switch. Override the safety stop that occurs when the existing-TAP check
    cannot be completed. Use only with explicit approval — see notes.
.EXAMPLE
    .\New-TAPForUser.ps1 -UserPrincipalName "jane.smith@northbridge.example" -TicketNumber "INC0042891"
.EXAMPLE
    .\New-TAPForUser.ps1 -UserPrincipalName "john.doe@northbridge.example" -TicketNumber "INC0042901" -LifetimeMinutes 120
.EXAMPLE
    .\New-TAPForUser.ps1 -UserPrincipalName "jane.smith@northbridge.example" -TicketNumber "INC0042891" -WhatIf
.NOTES
    Version: 1.1 | Date: June 2026
    Prerequisites: Microsoft Graph PowerShell SDK
    Permissions: UserAuthenticationMethod.ReadWrite.All, User.Read.All
#>

#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Identity.SignIns

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
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
    [string]$AuditLogPath = ".",

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# =============================================================================
# CONFIGURATION
# =============================================================================

$ScriptVersion   = "1.1"
$ScriptName      = "New-TAPForUser"
$Organization    = "NorthBridge Financial Group"
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
    Write-Host "  [!] All issuance events are recorded; Entra audit log is the system of record" -ForegroundColor Yellow
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
        throw "Graph connection failed: $($_.Exception.Message)"
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
            throw "Account '$UPN' is disabled. TAP cannot be issued."
        }
        Write-Host "[+] User found: $($User.DisplayName) | Dept: $($User.Department)" -ForegroundColor Green
        return $User
    }
    catch {
        throw "User lookup failed for '$UPN': $($_.Exception.Message)"
    }
}

function Test-ExistingTAP {
    param([string]$UserId, [switch]$Force)
    Write-Host "[*] Checking for existing active TAP..." -ForegroundColor Cyan
    try {
        $ExistingMethods = Get-MgUserAuthenticationMethod -UserId $UserId -ErrorAction Stop
        $ExistingTAP = $ExistingMethods | Where-Object {
            $_.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.temporaryAccessPassAuthenticationMethod"
        }
        if ($ExistingTAP) {
            throw "User already has an active TAP. Wait for it to expire or delete it in Entra ID first."
        }
        Write-Host "[+] No active TAP found - cleared to issue." -ForegroundColor Green
    }
    catch {
        # Fail closed: if we cannot confirm the user has no active TAP, do NOT
        # proceed to issue another one — that would risk two live TAPs for one
        # user. -Force allows an explicitly-approved override.
        if ($_.Exception.Message -like "*already has an active TAP*") {
            throw $_.Exception.Message
        }
        if ($Force) {
            Write-Host "[!] Could not verify TAP status, but -Force set. Proceeding." -ForegroundColor Yellow
        }
        else {
            throw "Could not verify existing TAP status: $($_.Exception.Message). Aborting (use -Force to override with approval)."
        }
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
        throw "TAP generation failed: $($_.Exception.Message). Verify TAP is enabled in the Entra ID Authentication Methods policy."
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
    try {
        $AuditEntry | Export-Csv -Path $AuditFile -NoTypeInformation -Append -Encoding UTF8
        Write-Host "[+] Local issuance record written: $AuditFile" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] TAP was issued but the local record could not be written: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "    The Entra audit log remains the system of record." -ForegroundColor Yellow
    }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

try {
    Write-Banner

    $Operator = Connect-ToGraph
    $User     = Get-TargetUser -UPN $UserPrincipalName

    Test-ExistingTAP -UserId $User.Id -Force:$Force

    # ShouldProcess provides -WhatIf and -Confirm for this privileged action.
    if (-not $PSCmdlet.ShouldProcess(
            "$($User.DisplayName) <$($User.UserPrincipalName)>",
            "Issue single-use TAP (ticket $TicketNumber, lifetime $LifetimeMinutes min)")) {
        Write-Host "[!] TAP issuance not confirmed. Exiting without action." -ForegroundColor Yellow
        return
    }

    $TAP = New-TAPCredential -UserId $User.Id -Lifetime $LifetimeMinutes -IsOneTimeUse $SingleUse

    Write-TAPResult -TAP $TAP -User $User
    Write-AuditLog  -TAP $TAP -User $User -Operator $Operator

    Write-Host "[+] $ScriptName v$ScriptVersion complete" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host "[-] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue
}
