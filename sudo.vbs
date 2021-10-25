Option Explicit
If WScript.Arguments.Count = 0 Then
    WScript.Echo "Usage: sudo program [arg1 arg2 ...]" & vbCrLf & _
                 "Run `program` with paramators as root in new console window"
Else
    Dim ShellApp, WshShell
    Dim cmd, varg, i
    Set WshShell = CreateObject("WScript.Shell")
    cmd = WshShell.ExpandEnvironmentStrings("%COMSPEC%")
    'Build paramator
    varg = "/C CD " & WshShell.CurrentDirectory    & " & "
    For i = 0 To WScript.Arguments.Count - 1
        varg = varg & " " & WScript.Arguments(i)
    Next
    varg = varg & " & PAUSE"
    'run cmd /C ... as root
    Set ShellApp = CreateObject("Shell.Application")
    ShellApp.ShellExecute cmd, varg, "", "runas"
End If