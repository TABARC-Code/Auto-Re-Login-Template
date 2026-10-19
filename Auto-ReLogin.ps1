# TABARC-Code
# Single, explicitly authorised GUI login attempt using fixed coordinates.
[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [Parameter(Mandatory=$true)][string]$TargetProcessName,
  [int]$UserX = 200,
  [int]$UserY = 200,
  [int]$PasswordX = 200,
  [int]$PasswordY = 240,
  [int]$LoginX = 200,
  [int]$LoginY = 300,
  [PSCredential]$Credential,
  [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class LoginWindow {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(int flags,int dx,int dy,int data,int info);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int cmd);
  public const int Down = 0x02;
  public const int Up = 0x04;
}
"@

function Escape-SendKeys([string]$value) {
  $builder = New-Object System.Text.StringBuilder
  foreach ($ch in $value.ToCharArray()) {
    $token = switch ([string]$ch) {
      '+' {'{+}';break}
      '^' {'{^}';break}
      '%' {'{%}';break}
      '~' {'{~}';break}
      '(' {'{(}';break}
      ')' {'{)}';break}
      '{' {'{{}';break}
      '}' {'{}}';break}
      '[' {'{[}';break}
      ']' {'{]}';break}
      default {[string]$ch}
    }
    [void]$builder.Append($token)
  }
  return $builder.ToString()
}

$process = Get-Process -Name $TargetProcessName -ErrorAction SilentlyContinue |
  Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $process) { throw "No visible window found for $TargetProcessName." }

if (-not $Apply) {
  Write-Host "Preview: would make one login attempt in $TargetProcessName (PID $($process.Id)). Use -Apply to proceed."
  return
}
if (-not $PSCmdlet.ShouldProcess("$TargetProcessName (PID $($process.Id))", 'Enter credentials and click login')) { return }

if (-not $Credential) {
  $Credential = Get-Credential -Message "Credentials for $TargetProcessName"
}
if (-not $Credential) { throw 'No credentials were supplied.' }

[void][LoginWindow]::ShowWindow($process.MainWindowHandle,9)
[void][LoginWindow]::SetForegroundWindow($process.MainWindowHandle)
Start-Sleep -Milliseconds 250

function Assert-Foreground {
  if ([LoginWindow]::GetForegroundWindow() -ne $process.MainWindowHandle) {
    throw 'The target application is no longer in the foreground. Login aborted.'
  }
}
function Click-Target([int]$x,[int]$y) {
  Assert-Foreground
  [void][LoginWindow]::SetCursorPos($x,$y)
  Start-Sleep -Milliseconds 75
  [LoginWindow]::mouse_event([LoginWindow]::Down,0,0,0,0)
  [LoginWindow]::mouse_event([LoginWindow]::Up,0,0,0,0)
  Start-Sleep -Milliseconds 75
  Assert-Foreground
}

Click-Target $UserX $UserY
[Windows.Forms.SendKeys]::SendWait('^a{DEL}')
[Windows.Forms.SendKeys]::SendWait((Escape-SendKeys $Credential.UserName))

Click-Target $PasswordX $PasswordY
[Windows.Forms.SendKeys]::SendWait('^a{DEL}')

$passwordPtr = [IntPtr]::Zero
$password = $null
try {
  $passwordPtr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
  $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPtr)
  Assert-Foreground
  [Windows.Forms.SendKeys]::SendWait((Escape-SendKeys $password))
} finally {
  $password = $null
  if ($passwordPtr -ne [IntPtr]::Zero) {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPtr)
  }
}

Click-Target $LoginX $LoginY
Write-Host 'Submitted one login attempt. Authentication success was not verified.'
