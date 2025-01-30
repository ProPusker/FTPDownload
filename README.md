# FTP/SFTP File Transfer Script README

This script automates secure file transfers between a local machine and a remote FTP/FTPS server using WinSCP's .NET assembly. It is designed to download files matching a specific pattern and optionally remove them from the server after transfer.



## Features
- **Secure Transfers**: Supports FTP with Implicit/Explicit SSL (FTPS).
- **Automated File Transfer**: Downloads files matching a wildcard pattern from a remote directory.
- **Logging**: Detailed logs with rotation to prevent oversized files.
- **Error Handling**: Captures and logs errors for troubleshooting.
- **Configurable**: Easily adjust server settings, paths, and file patterns.



## Requirements
- **Windows OS**: Tested on Windows 10/11 and Windows Server.
- **PowerShell 5.1+**: Ensure PowerShell execution is allowed (check policy with `Get-ExecutionPolicy`).
- **WinSCP Installation**: Download and install [WinSCP](https://winscp.net/eng/download.php).
  - The script requires `WinSCPnet.dll`, typically located at `C:\Program Files (x86)\WinSCP\WinSCPnet.dll`.



## Setup Instructions
1. **Install WinSCP**:
   - Download from [WinSCP's official site](https://winscp.net/eng/download.php) and follow installation steps.

2. **Configure Script Parameters**:
   - Open the script in a text editor.
   - Update the following variables under `FTP Configuration`:
     - `$HostName`: FTP server address (e.g., `ftp.ABC.com`).
     - `$PortNumber`: Server port (e.g., `990` for FTPS Implicit).
     - `$FtpUser` and `$FtpPassword`: Your credentials.
     - `$FtpSecure`: Encryption mode (`Implicit`, `Explicit`, or `None` for plain FTP).
   - Set paths:
     - `$RemotePath`: Remote directory (e.g., `/local/test/folderA`).
     - `$LocalPath`: Local download directory (e.g., `C:\Users\XYZ\Documents\Rates`).
     - `$FileMask`: File pattern to download (e.g., `*ABC*.pdf`).
     - `$RemoveAfterTransfer`: Set to `$true` to delete remote files after download.

3. **Validate WinSCP Assembly Path**:
   - Ensure `$WinSCPPath` points to the correct `WinSCPnet.dll` location.



## Configuration Details
### FTP Settings
| Variable          | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `$Protocol`       | **Not used in current script** (hardcoded to FTP; modify code for SFTP).   |
| `$HostName`       | FTP server hostname or IP.                                                  |
| `$PortNumber`     | Port for the connection (e.g., `21` for FTP, `990` for Implicit FTPS).      |
| `$FtpUser`        | Username for authentication.                                                |
| `$FtpPassword`    | Password (stored in plain text; see [Security](#security-considerations)).  |
| `$FtpSecure`      | Encryption: `Implicit` (default), `Explicit`, or `None` for unencrypted FTP.|

Paths
| Variable               | Description                                       |
|------------------------|---------------------------------------------------|
| `$RemotePath`          | Remote directory to download files from.          |
| `$LocalPath`           | Local directory to save files.                    |
| `$FileMask`            | Wildcard pattern (e.g., `*ABC*.pdf`).             |
| `$RemoveAfterTransfer` | Delete remote files after transfer (`$true`/`$false`). |

---

## Logging
- **Log File**: Created at `[Script Directory]\ScriptName.txt`.
- **Rotation**: 
  - Logs rotate when exceeding **64KB**, retaining up to **5 backup files**.
  - Backup naming: `ScriptName-YYYYMMDD-HHmmss.bak`.
- **Log Format**: `Timestamp|LineNumber|LogLevel|Message`.



## Usage
1. **Run Manually**:
   - Execute the script in PowerShell:
     ```powershell
     .\ScriptName.ps1
     ```
2. **Scheduled Task**:
   - Use Windows Task Scheduler to run the script periodically.
   - Example: Daily at 2 AM to download new files.



## Security Considerations
- **Plain Text Password**: The script stores credentials in plain text. For enhanced security:
  - Use WinSCP's secure password storage (e.g., `SecurePassword` in WinSCP scripts).
  - Encrypt the password using PowerShell secure strings (advanced).
- **Permissions**: Restrict script access to authorized users.



## Error Handling
- The script exits with code `1` on errors (e.g., connection failure, missing DLL).
- Successful runs exit with code `0`.
- Check logs for details on failures.



## Troubleshooting
1. **WinSCP Assembly Not Found**:
   - Confirm `$WinSCPPath` points to the correct DLL location.
2. **Connection Issues**:
   - Verify `$HostName`, `$PortNumber`, and encryption settings.
   - Test credentials using an FTP client like WinSCP GUI.
3. **Permission Denied**:
   - Ensure the local directory is writable.
   - Check remote directory permissions.



## Support
For issues or feature requests, contact your system administrator or open a GitHub issue.
