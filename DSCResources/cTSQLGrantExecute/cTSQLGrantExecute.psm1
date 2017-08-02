Function Get-TargetResource  {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$User,

        [Parameter(Mandatory = $true)]
        [String]$Object,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure        
    )

    
    if (!(Get-command Invoke-Sqlcmd  -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }            

    $SQLQuery = Invoke-Sqlcmd -verbose -Query "SELECT princ.name, princ.type_desc, perm.permission_name, perm.state_desc, perm.class_desc, object_name(perm.major_id)
                                                    FROM sys.database_principals princ
                                               LEFT JOIN
                                                    sys.database_permissions perm
                                               ON perm.grantee_principal_id = princ.principal_id"

    if ($Object.Split(".").Count -gt 1) {$objectname = $Object.Split(".")[1]} else {$Objectname = $Object} 
    $checkpermission = $SQLQuery | where {$_.name -eq $User -and $_.Column1 -eq $objectname}
    $presence = if ($checkpermission) {"Present"} else {"Absent"}

    return @{
        Ensure = $presence
        LoginGroup = $LoginGroup
    }
}

Function Test-TargetResource {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$User,

        [Parameter(Mandatory = $true)]
        [String]$Object,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure        
    )

    
    if (!(Get-command Invoke-Sqlcmd  -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }            

    $SQLQuery = Invoke-Sqlcmd -verbose -Query "SELECT princ.name, princ.type_desc, perm.permission_name, perm.state_desc, perm.class_desc, object_name(perm.major_id)
                                                    FROM sys.database_principals princ
                                               LEFT JOIN
                                                    sys.database_permissions perm
                                               ON perm.grantee_principal_id = princ.principal_id"

    if ($Object.Split(".").Count -gt 1) {$objectname = $Object.Split(".")[1]} else {$Objectname = $Object} 
    $checkpermission = $SQLQuery | where {$_.name -eq $User -and $_.Column1 -eq $objectname}
    $presence = if ($checkpermission) {"Present"} else {"Absent"}

    return $Presence -eq $Ensure
}

Function Set-TargetResource {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$User,

        [Parameter(Mandatory = $true)]
        [String]$Object,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure        
    )

    
    if (!(Get-command Invoke-Sqlcmd  -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }            
         
    switch ($Ensure) {
        "Present" {
            Invoke-Sqlcmd -Verbose -Query "DECLARE @User NVARCHAR(60); 
                                           DECLARE @Obj NVARCHAR(128);
                                           SET @User = N'$User'
                                           SET @Obj = N'$object'
                                           EXEC ('GRANT EXECUTE on ' + @Obj + ' to [' + @User + ']')"
        }
        "Absent" {
            Invoke-Sqlcmd -Verbose -Query "DECLARE @ReturnCode INT; 
                                           DECLARE @User NVARCHAR(60); 
                                           SET @User = N'$User'; 
                                           EXEC @ReturnCode = sp_revokelogin @User 
                                           Print 'Return Code from sp_Addlogin is' + @returncode"        
        }
    }

}

Export-ModuleMember -Function *-TargetResource