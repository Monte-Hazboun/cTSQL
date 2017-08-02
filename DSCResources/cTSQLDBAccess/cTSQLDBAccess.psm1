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
        [String]$Database,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$SamAccountNameofLoginGroupMember,
        
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure             
    )

    
    if (!(Get-command Invoke-Sqlcmd  -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }            

    if ($PSBoundParameters.ContainsKey("Domain")) {
        $userset = "SET @User = '$domain' + N'\$SamAccountNameofLoginGroupMember';"
    } else {
        $userset = "SET @User = N'$LoginGrouporAccount';"
    }
    $SQLQuery = Invoke-Sqlcmd -Query "DECLARE @User NVARCHAR(60); 
                                      $userset
                                      EXECUTE AS USER = @User;
                                      SELECT HAS_DBACCESS('$Database')"
    
    $presence = if ($SQLQuery.Column1 -eq 1) {"Present"} else {"Absent"}

    return @{
        Ensure = $presence
        Domain = $Domain
        LoginGroup = $LoginGroup
        Database = $Database
        TestAccount = $SamAccountNameofLoginGroupMember
    }
}

Function Test-TargetResource {
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$Domain,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginGrouporAccount,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Database,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$SamAccountNameofLoginGroupMember,
        
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure             
    )

    
    if (!(Get-command Invoke-Sqlcmd  -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }            

    if ($PSBoundParameters.ContainsKey("Domain")) {
        $userset = "SET @User = '$domain' + N'\$SamAccountNameofLoginGroupMember';"
    } else {
        $userset = "SET @User = N'$LoginGrouporAccount';"
    }

    $SQLQuery = Invoke-Sqlcmd -Query "DECLARE @User NVARCHAR(60); 
                                      $userset
                                      EXECUTE AS USER = @User;
                                      SELECT HAS_DBACCESS('$Database')"
    
    $presence = if ($SQLQuery.Column1 -eq 1) {"Present"} else {"Absent"}

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
        [String]$Database,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$SamAccountNameofLoginGroupMember,
        
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure             
    )

    
    if (!(Get-command Invoke-Sqlcmd -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }   
             
    if ($PSBoundParameters.ContainsKey("Domain")) {
        $userset = "SET @User = '$domain' + N'\$LoginGrouporAccount';"
    } else {
        $userset = "SET @User = N'$LoginGrouporAccount';"
    }
    switch ($Ensure) {
        "Present" {
            Invoke-Sqlcmd -Verbose -Query "DECLARE @User NVARCHAR(60); 
                                           DECLARE @ReturnCode INT;
                                           $userset
                                           USE $database;
                                           EXEC @ReturnCode = sp_grantdbaccess @User; 
                                           print 'Return Code from sp_grantlogin is ' + @returncode " 
         }
        "Absent" {
            Invoke-Sqlcmd -Verbose -Query "DECLARE @User NVARCHAR(60); 
                                           DECLARE @ReturnCode INT;
                                           $userset 
                                           USE $database;
                                           EXEC @ReturnCode = sp_revokedbaccess @User; 
                                           print 'Return Code from sp_grantlogin is ' + @returncode "      
         }
    }
}

Export-ModuleMember -Function *-TargetResource