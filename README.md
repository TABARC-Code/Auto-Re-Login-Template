# Auto Re-Login Template (Windows)

A fixed-coordinate PowerShell template for a **single** attempted login to a visible application window. Designed for applications without a supported automation interface.

It does not monitor the session, repeat attempts, bypass multi-factor authentication, or verify a successful login.

## Usage

Run from an interactive Windows session with PowerShell 5.1 or PowerShell 7+.

Preview (does not request credentials or click):


```powershell
.\Auto-ReLogin.ps1 -TargetProcessName notepad
```

Actual one-time attempt:


```powershell
.\Auto-ReLogin.ps1 -TargetProcessName MyApp -Apply -UserX 200 -UserY 200 -PasswordX 200 -PasswordY 240 -LoginX 200 -LoginY 300
```

You will be prompted for credentials if you do not pass an existing PowerShell `PSCredential` object. Passwords are no longer accepted as plain command-line string parameters.

The script brings the target window to the foreground and checks it before sending each input. It aborts when focus changes. It escapes SendKeys metacharacters, but unusual keyboard layouts and characters should be tested with dummy credentials first.

## Cautions

- Coordinates are absolute screen pixels. Different monitors, DPI scaling and window position can invalidate them.
- SendKeys is inherently less reliable than a supported login API or UI Automation element targeting.
- The password must briefly exist in process memory as ordinary text to send keystrokes; it is not written to logs or the clipboard by this script.
- Use a dedicated test account first. Do not use this template for privileged or sensitive authentication flows without additional safeguards.
- Never leave this running with unattended credentials: it makes one attempt and exits.
