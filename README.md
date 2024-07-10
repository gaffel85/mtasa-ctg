# mtasa-ctg
MTA SA - Capture the gold


```
%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -noexit -command "Set-Location 'C:\games\MTA SA\server\mods\deathmatch\resources\``[gamemodes``]\``[ctg``]\"'; & '.\SwitchToHighestDevBranch.ps1'"
```

New-Item -Path "ctg-link" -ItemType SymbolicLink -Value "C:\games\MTA SA\server\mods\deathmatch\resources\``[gamemodes``]\``[ctg``]\"