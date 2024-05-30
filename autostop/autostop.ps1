param(
    [Parameter()]
    [switch]$install,
    [Parameter()]
    [Int]$uptimelimit = 3600,
    [Parameter()]
    [Int]$limit = 0,
    [Parameter()]
    [switch]$auto

)
if ($psversiontable.PSVersion.Major -lt 7){
    Write-Error -Message "Powershell needs to be at least version 7" -ErrorAction Stop
}
write-host $Myinvocation.mycommand.source

if ($auto.ispresent) {
    write-output "Auto present"
}

#check if modules are installed
if (-not (Get-InstalledModule -Name PSTerminalServices)) {
    write-output "Installing PSTerminalServices"
    Install-Module -Name PSTerminalServices -force
}
if (-not (Get-InstalledModule -Name AZ.Automation)) {
    write-output "Installing Az.Automation"
    Install-Module -Name AZ.Automation -force
}
if (-not (Get-InstalledModule -Name AZ.compute)) {
    write-output "Installing Az.Compute"
    Install-Module -Name AZ.compute -force
}


if ($install.ispresent) {
    
    Write-Output "scheduling Task"
    $st = Get-ScheduledTask -TaskName 'Lubon autostop'
    if ($null -ne $st) {
        Unregister-ScheduledTask -Taskname $st.Taskname 
    }
    $action = New-ScheduledTaskAction -Execute "c:\Program Files\PowerShell\7\pwsh.exe" -Argument ('-executionpolicy bypass -file "' + $Myinvocation.mycommand.source +'" -auto' )
    $trigger = $trigger = New-ScheduledTaskTrigger -at 18:00 -Weekly -DaysofWeek Friday,Saturday
    $sectrigger = New-ScheduledTaskTrigger -once -at 18:00 -RepetitionInterval (New-TimeSpan -minutes 15) -RepetitionDuration (new-timespan -hours 8)
    $trigger.Repetition = $sectrigger.Repetition
    $t = new-scheduledtask -Action $action -Description "Lubon autostop powershell script" -trigger $trigger
    Register-ScheduledTask -TaskName "Lubon autostop" -TaskPath lubon -user "System" -Action $action -Trigger $trigger 
    Write-Output "End scheduling Task, pausing"

}

$Sessions = Get-TSSession | where-Object { $_.state -ne 'Listening' } | where-Object { $_.state -ne 'Connected' } | where-Object { $_.sessionid -ne 0 }
write-output ("Number of logged on users: " + $sessions.count)
$uptime = [int]((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).totalseconds
write-output ("Uptime: " + $uptime)
if (($sessions.count -le $limit) -and ($uptime -gt $uptimelimit)) {
    write-output "Processing", $env:COMPUTERNAME
    Connect-AzAccount -Identity
    $vm = get-azvm
    if ($vm.Tags['AutoShutDown'] -eq 'Yes') {
        $params = [ordered]@{"vmname" = $vm.Name }      
        if ($auto.ispresent ) {	  
            Start-AzAutomationRunbook -name AutoShutDown -ResourceGroupName $vm.Tags['ResizeRG'] -AutomationAccountName $vm.Tags['ResizeACC'] -Parameters $params
	    exit 0	
        }
        else {
            $msg = 'Auto is not present. Execute Runbook, will resize server? [Y/N]'
            do {
                $response = Read-Host -Prompt $msg
                if ($response -eq 'y') {
                    $response='n'
                    Start-AzAutomationRunbook -name AutoShutDown -ResourceGroupName $vm.Tags['ResizeRG'] -AutomationAccountName $vm.Tags['ResizeACC'] -Parameters $params
                }
            } until ($response -eq 'n')
        }
    }
}
else {
    write-output ("Do nothing: " + $session.Count)
    exit 100

}
