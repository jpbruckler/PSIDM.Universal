

#New-PSUSystemEvent -Script "SystemEvent.ps1" -Credential "Default" -Type "Create" -Condition "TargetInstance ISA `"Cim_DirectoryContainsFile`" AND TargetInstance.GroupComponent=`"Win32_Directory.Name='C:\\test'`"" -Name "File Created"