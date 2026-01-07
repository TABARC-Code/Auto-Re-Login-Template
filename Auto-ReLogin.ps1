# TABARC-Code
param(
  [Parameter(Mandatory=$true)][string]$Username,
  [Parameter(Mandatory=$true)][string]$Password
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Mouse {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int X,int Y);
  [DllImport("user32.dll")] public static extern void mouse_event(int f,int dx,int dy,int c,int e);
  public const int LD=0x02; public const int LU=0x04;
}
"@

function Click($x,$y){
  [Mouse]::SetCursorPos($x,$y)|Out-Null
  Start-Sleep -Milliseconds 50
  [Mouse]::mouse_event([Mouse]::LD,0,0,0,0)
  [Mouse]::mouse_event([Mouse]::LU,0,0,0,0)
}

# CONFIG
$UserField = @{X=200;Y=200}
$PassField = @{X=200;Y=240}
$LoginBtn  = @{X=200;Y=300}

Click $UserField.X $UserField.Y
[System.Windows.Forms.SendKeys]::SendWait("^a{DEL}$Username")

Click $PassField.X $PassField.Y
[System.Windows.Forms.SendKeys]::SendWait("^a{DEL}$Password")

Click $LoginBtn.X $LoginBtn.Y
