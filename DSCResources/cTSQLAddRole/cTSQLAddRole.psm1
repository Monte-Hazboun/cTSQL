Function Get-TargetResource  {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$RoleName,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure        
    )

    
    if (!(Get-command Invoke-Sqlcmd  -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }            

    $SQLQuery = Invoke-Sqlcmd -Query "SELECT * FROM sysusers WHERE name = '$RoleName' AND issqlrole = 1"

    $presence = if ($SQLQuery) {"Present"} else {"Absent"}

    return @{
        Ensure = $presence
        LoginGroup = $LoginGroup
    }
}

Function Test-TargetResource {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$RoleName,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure        
    )
    
    if (!(Get-command Invoke-Sqlcmd  -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }            

    $SQLQuery = Invoke-Sqlcmd -Query "SELECT * FROM sysusers WHERE name = '$RoleName' AND issqlrole = 1"

    $presence = if ($SQLQuery) {"Present"} else {"Absent"}

    return $Presence -eq $Ensure
}

Function Set-TargetResource {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$RoleName,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure        
    )
    
    if (!(Get-command Invoke-Sqlcmd -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }       
         
    switch ($Ensure) {
        "Present" {
            Invoke-Sqlcmd -Verbose -Query "DECLARE @ReturnCode INT; 
                                           EXEC @ReturnCode = sp_addrole '$rolename';
                                           Print 'Return Code from sp_Addlogin is' + @returncode"
        }
        "Absent" {
            Invoke-Sqlcmd -Verbose -Query "DECLARE @ReturnCode INT; 
                                           EXEC @ReturnCode = sp_droprole '$rolename';
                                           Print 'Return Code from sp_Addlogin is' + @returncode"       
        }
    }

}

Export-ModuleMember -Function *-TargetResource