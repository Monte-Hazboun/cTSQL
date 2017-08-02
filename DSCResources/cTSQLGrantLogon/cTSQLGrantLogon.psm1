Function Get-TargetResource  {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Domain,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginGroup,
        
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure
               
    )

    
    if (!(Get-command Invoke-Sqlcmd  -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }            

    $SQLQuery = Invoke-Sqlcmd -Query "DECLARE @User NVARCHAR(60); 
                                      SET @User = '$domain' + N'\$LoginGroup'; 
                                      SELECT * FROM master..syslogins WHERE loginname = @User"
    
   $presence = if ($SQLQuery) {"Present"} else {"Absent"}

    return @{
        Ensure = $presence
        Domain = $Domain
        LoginGroup = $LoginGroup
    }
}

Function Test-TargetResource {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Domain,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginGroup,
        
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure
               
    )

    
    if (!(Get-command Invoke-Sqlcmd -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }            

    $SQLQuery = Invoke-Sqlcmd -Query "DECLARE @User NVARCHAR(60); 
                                      SET @User = '$domain' + N'\$LoginGroup'; 
                                      SELECT * FROM master..syslogins WHERE loginname = @User"
    
    $Presence = If ($SQLQuery) {"Present"} else {"Absent"}

    return $Presence -eq $Ensure
}

Function Set-TargetResource {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Domain,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$LoginGroup,
        
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
                                           DECLARE @User NVARCHAR(60); SET @User = '$domain' + N'\$LoginGroup'; 
                                           EXEC @ReturnCode = sp_grantlogin @User; 
                                           Print 'Return Code from sp_grantlogin is' + @returncode" 
        }
        "Absent" {
            Invoke-Sqlcmd -Verbose -Query "DECLARE @ReturnCode INT; DECLARE @User NVARCHAR(60); 
                                           SET @User = '$domain' + N'\$LoginGroup'; 
                                           EXEC @ReturnCode = sp_revokelogin @User; 
                                           Print 'Return Code from sp_grantlogin is' + @returncode" 
        }
    }

}

Export-ModuleMember -Function *-TargetResource