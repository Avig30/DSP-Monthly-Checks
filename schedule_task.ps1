# schedule_task.ps1
# Registers a Windows Task Scheduler job to run DSP checks
# on the 1st of every month at 8:00 AM.
# Run as Administrator (setup.bat does this automatically).

$taskName   = "DSP Monthly Compliance Checks"
$scriptDir  = $PSScriptRoot
$batchFile  = Join-Path $scriptDir "run_checks.bat"

# Remove existing task if present
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

$action  = New-ScheduledTaskAction `
    -Execute  "cmd.exe" `
    -Argument "/c `"$batchFile`"" `
    -WorkingDirectory $scriptDir

$trigger = New-ScheduledTaskTrigger `
    -Monthly `
    -DaysOfMonth 1 `
    -At "08:00AM"

$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit  (New-TimeSpan -Hours 3) `
    -StartWhenAvailable  `
    -RunOnlyIfNetworkAvailable `
    -MultipleInstances   IgnoreNew

$principal = New-ScheduledTaskPrincipal `
    -UserId    "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType Interactive `
    -RunLevel  Highest

Register-ScheduledTask `
    -TaskName  $taskName `
    -Action    $action `
    -Trigger   $trigger `
    -Settings  $settings `
    -Principal $principal `
    -Force

Write-Host ""
Write-Host "Scheduled task '$taskName' registered successfully."
Write-Host "It will run on the 1st of every month at 8:00 AM."
Write-Host "To verify: open Task Scheduler and look for '$taskName'."
