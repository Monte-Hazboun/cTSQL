Function Get-TargetResource  {
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$Domain,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginGrouporAccount,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$RoleName,
      
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure        
    )

    
    if ($PSBoundParameters.ContainsKey("Domain")) {
        $FQUN = "$domain\$LoginGrouporAccount"
    } else {
        $FQUN = $LoginGrouporAccount
    }
    $SQLQuery = Invoke-Sqlcmd -Query "sp_helprolemember @rolename = '$rolename'"

    $rolecheck = $SQLQuery.where({$_.MemberName -eq $FQUN })

    $presence = if ($rolecheck) {"Present"} else {"Absent"}

    return @{
        Ensure = $presence
        LoginGroup = $LoginGrouporAccount
        RoleName = $RoleName
        Domain = $Domain
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

    if ($PSBoundParameters.ContainsKey("Domain")) {
        $FQUN = "$domain\$LoginGrouporAccount"
    } else {
        $FQUN = $LoginGrouporAccount
    }
    $SQLQuery = Invoke-Sqlcmd -Query "sp_helprolemember @rolename = '$rolename'"

    $rolecheck = $SQLQuery.where({$_.MemberName -eq $FQUN })

    $presence = if ($rolecheck) {"Present"} else {"Absent"}

    return $Presence -eq $Ensure
}

Function Set-TargetResource {
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$Domain,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginGrouporAccount,

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
    
    if ($PSBoundParameters.ContainsKey("Domain")) {
        $userset = "SET @User = '$domain' + N'\$SamAccountNameofLoginGroupMember';"
    } else {
        $userset = "SET @User = N'$LoginGrouporAccount';"
    }
         
    switch ($Ensure) {
        "Present" {
            Invoke-Sqlcmd -Verbose -Query "DECLARE @ReturnCode INT;
                                           DECLARE @User NVARCHAR(60);
                                           $userset
                                           EXEC @ReturnCode = sp_addrolemember '$Rolename', @User
                                           Print 'Return Code from sp_Addlogin is' + @returncode"
        }
        "Absent" {
            Invoke-Sqlcmd -Verbose -Query "DECLARE @ReturnCode INT;
                                           DECLARE @User NVARCHAR(60); 
                                           $userset 
                                           EXEC @ReturnCode = sp_droprolemember '$Rolename', @User
                                           Print 'Return Code from sp_Addlogin is' + @returncode"       
        }
    }

}

Export-ModuleMember -Function *-TargetResource