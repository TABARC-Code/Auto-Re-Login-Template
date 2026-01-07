# Auto-Re-Login-Template
A coordinate driven login automation template for applications that insist on logging you out and offers no sane API to get back in.

# Auto Re-Login Template (PowerShell)

A coordinate driven login automation template for applications that insist on logging you out and offer no sane API to get back in.

Author: TABARC-Code  
Plugin URI: https://github.com/TABARC-Code/

## What this is

This script repeatedly attempts to log into a target application by:

- waiting for the process window to exist
- clicking fixed screen coordinates
- typing credentials via SendKeys
- clicking a login button
- looping for a fixed amount of time

It is a **template**, not a finished solution. You are expected to adapt it.

## Why this exists

Some applications:
- expire sessions aggressively
- crash and restart without warning
- refuse to expose automation hooks
- only support mouse and keyboard input

This script is for those situations. It is not elegant. It is effective.

## Script location

In the toolbox repo:

`scripts/04-Auto-ReLogin-Template.ps1`

It imports:

`src/Tabarc.Toolbox.psm1`

## Usage

Basic run:

```powershell
.\scripts\04-Auto-ReLogin-Template.ps1 `
  -TargetProcessName YourApp `
  -Username your_user `
  -Password your_password
Limit runtime (minutes):

powershell
Copy code
-RunMinutes 30
Stop early with Ctrl + C.

Parameters
-TargetProcessName
Process name as shown in Task Manager. No .exe.

-Username
Text typed into the username field.

-Password
Text typed into the password field.

-RunMinutes (default 15)
Total time the loop runs before exiting.

Coordinate configuration
These values must be edited:

powershell
Copy code
$UserField = @{ X = 200; Y = 200 }
$PassField = @{ X = 200; Y = 240 }
$LoginBtn  = @{ X = 200; Y = 300 }
Use:

a mouse coordinate tracker

scripts/25-Monitor-Map-Dumper.ps1

DPI scaling and window position must stay consistent.

How it works
Each cycle:

Checks whether the target process has a visible main window

Clicks the username field

Selects existing text and types the username

Clicks the password field

Selects existing text and types the password

Clicks the login button

Waits 30 seconds before trying again

If the window does not exist, it waits and retries.

### Logging
The script relies on shared logging via:

Write-TbLog

Look in:
logs/toolbox.log

There is no per attempt success detection. This is intentional. Many UIs lie.

### Security warning
This script contains plaintext credentials.

That is not a theoretical problem.

Do not:!!!!!!!!!!!!!!!!

commit real credentials

leave this running unattended on shared machines. i fuck you not do not be a newbie...

assume obscurity equals safety

If you need real credential security, this approach is the wrong tool.

### Known limitations
Breaks if the window moves

Breaks if DPI scaling changes

Breaks if the UI layout changes

Breaks if the app switches to secure desktop

All expected. This is pixel automation.

When not to use this
When the application provides an API

When credentials can be refreshed via token

When automation frameworks are available

Use this when everything else failed and you just need the thing logged in.
