# upath

**Minimal PowerShell utility for managing the Windows User PATH.**

## Installation

Install upath using a single PowerShell command:

```powershell
irm "https://raw.githubusercontent.com/xbvuno/win-user-path/main/install.ps1" | iex
```

and you're ready to use it

> This installer executes a remote script using `Invoke-RestMethod | Invoke-Expression`. Always review the source before installing. Check [What gets installed](#what-gets-installed).

## Features

- Manage **User PATH** directly from the terminal
- Prevents duplicate entries (case-insensitive normalization)
- Safe add/remove operations
- Instant session refresh without restarting the terminal
- Lightweight, dependency-free PowerShell script


## Behavior

- User PATH only (no system PATH modifications)
- Automatic normalization of paths
- Duplicate prevention (case-insensitive)
- Persistent changes via Windows environment variables
- Instant session update with `refresh`

## Usage

#### show help message

```powershell
upath help
```

#### list user PATH entries

```powershell
upath list
```

#### Add a new entry to the user PATH if it doesn’t already exist

```powershell
upath add "C:\Tools"
```

#### remove an entry from the user PATH if it exists

```powershell
upath remove "C:\Tools"
```

#### refresh PATH for the current session

```powershell
upath refresh
```

## What gets installed

upath is installed locally in:

```
%LOCALAPPDATA%\upath\
```

Core script:
```
%LOCALAPPDATA%\upath\upath.ps1
```

The installer automatically injects upath into your user path

## License

ISC License

