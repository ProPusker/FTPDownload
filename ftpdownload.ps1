
########################################################################
# Script Configuration

Author: Pusker Ghimire
# DISCLAIMER
# This script is provided "AS IS" without warranty of any kind, either 
# express or implied, including without limitation any implied warranties 
# of condition, uninterrupted use, merchantability, fitness for a 
# particular purpose, or non-infringement. The entire risk arising out 
# of the use or performance of this script remains with you. 
# In no event shall the author be liable for any damages whatsoever 
# (including, without limitation, damages for loss of business profits, 
# business interruption, loss of business information, or other pecuniary 
# loss) arising out of the use of or inability to use this script

########################################################################

$ScriptName = [io.path]::GetFileNameWithoutExtension($(Get-ChildItem $PSCommandPath | Select-Object -Expand Name))
$ScriptBuild = "230101"
$ScriptPath = Split-Path -Path $PSCommandPath

# FTP Configuration
$Protocol = "ftp"  # ftp or sftp
$HostName = "ftp.YOURFTP.com"
$PortNumber = 990
$FtpUser = "USERNAME"
$FtpPassword = "PASSWORD"  # Plain text password
$FtpSecure = "Implicit"  # For FTP: Implicit, Explicit or None

# Path Configuration
$RemotePath = "/local/test/FolderA"
$FileMask = "*rate*.pdf"
$LocalPath = "C:\Users\ABC\Documents\Download"
$RemoveAfterTransfer = $true

# WinSCP Configuration
$WinSCPPath = "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

# Logging Configuration
$LogPath = $ScriptPath
$LogFileName = "$LogPath\$ScriptName.txt"
$LogSize = 64 * 1024  # 64KB
$LogCount = 5

########################################################################
# Logging Functions
########################################################################

function Write-NoPrefixLog {
    [CmdletBinding()]
    Param ([parameter(Mandatory = $True)]$Message)
    $Message | Out-File -Append -Encoding utf8 -FilePath ('FileSystem::' + $LogFileName)
}

function Write-Log {
    [CmdletBinding()]
    Param ([parameter(Mandatory = $True)]$Message)
    $LogLine = "$(Get-Date -Format 'MM/dd/yyyy HH:mm:ss.fff')|$($MyInvocation.ScriptLineNumber)|$Message"
    Write-NoPrefixLog $LogLine
    Write-Host $Message
}

function Init-LogFile {
    if (!(Test-Path $LogFileName)) {
        New-Item -Path $LogFileName -ItemType File -Force | Out-Null
    }
    else {
        if ((Get-Item $LogFileName).Length -gt $LogSize) {
            Move-Item -Path $LogFileName -Destination "$LogPath\$ScriptName-$(Get-Date -format yyyyMMdd)-$(Get-Date -Format HHmmss).bak" -Force
        }
    }
    While ((Get-ChildItem "$LogPath\$ScriptName-*.bak").count -gt $LogCount) {
        Get-ChildItem "$LogPath\$ScriptName-*.bak" | Sort-Object LastWriteTime | Select-Object -First 1 | Remove-Item -Force
    }
    
    Write-Log "INFO|Script: $ScriptName build $ScriptBuild"
    Write-Log "INFO|Computer: $env:COMPUTERNAME"
    Write-Log "INFO|User: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
}

########################################################################
# Main Script
########################################################################

try {
    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $WarningsCounter = 0
    Init-LogFile

    # Load WinSCP assembly
    if (!(Test-Path -Path $WinSCPPath)) {
        throw "WinSCP assembly not found at $WinSCPPath"
    }
    Add-Type -Path $WinSCPPath

    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Ftp
        HostName = $HostName
        PortNumber = $PortNumber
        UserName = $FtpUser
        Password = $FtpPassword
        FtpSecure = [WinSCP.FtpSecure]::Implicit
    }

    $transferOptions = New-Object WinSCP.TransferOptions
    $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
    $transferOptions.ResumeSupport.State = [WinSCP.TransferResumeSupportState]::On

    $session = New-Object WinSCP.Session

    try {
        $session.Open($sessionOptions)

        # Create local directory if needed
        if (!(Test-Path -Path $LocalPath)) {
            New-Item -Path $LocalPath -ItemType Directory -Force | Out-Null
            Write-Log "INFO|Created local directory: $LocalPath"
        }

        # Transfer files
        $transferResult = $session.GetFilesToDirectory(
            $RemotePath, 
            $LocalPath, 
            $FileMask, 
            $RemoveAfterTransfer, 
            $transferOptions
        )

        # Log results
        foreach ($transfer in $transferResult.Transfers) {
            Write-Log "INFO|Copied $($transfer.FileName) successfully"
        }

        if ($transferResult.Transfers.Count -eq 0) {
            Write-Log "INFO|No files found matching pattern: $FileMask"
        }
    }
    finally {
        $session.Dispose()
    }
}
catch {
    $errormessage = "$($_.Exception.Message)`n$($_.InvocationInfo.PositionMessage)"
    Write-Log "ERROR|$errormessage"
    exit 1
}

# Finalize
$totalseconds = [Math]::Round($StopWatch.Elapsed.TotalSeconds, 0)
Write-Log "INFO|Script completed. Elapsed time: $totalseconds seconds"
exit 0
