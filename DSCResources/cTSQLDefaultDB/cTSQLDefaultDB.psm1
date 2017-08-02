Function Get-TargetResource  {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$User,

        [Parameter()]
        [String]$Database,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure        
    )

    
    if (!(Get-command Invoke-Sqlcmd  -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }            

    $SQLQuery = Invoke-Sqlcmd -Query "SELECT * FROM master..sysdatabases WHERE name = '$database'"

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
        [String]$User,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$PasswordHash,

        [Parameter()]
        [String]$DefaultDatabase,

        [Parameter()]
        [String]$DefaultLanguage,

        [Parameter()]
        [String]$SID,
                
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure        
    )

    
    if (!(Get-command Invoke-Sqlcmd  -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }            

    if ($DefaultDatabase -eq $null) {$DefaultDatabase = 'master'}

    $SQLQuery = Invoke-Sqlcmd -Query "DECLARE @User NVARCHAR(60); 
                                      SET @User = N'$User'; 
                                      SELECT * FROM $DefaultDatabase..syslogins WHERE loginname = @User"
    
    $Presence = If ($SQLQuery) {"Present"} else {"Absent"}

    return $Presence -eq $Ensure
}

Function Set-TargetResource {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$User,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$PasswordHash,

        [Parameter()]
        [String]$DefaultDatabase,

        [Parameter()]
        [String]$DefaultLanguage,

        [Parameter()]
        [String]$SID,

        [Parameter()]
        [ValidateSet("NULL","skip_encryption","skip_encryption_old")]
        [string]$encryptopt,
                
        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [String]$Ensure        
    )
    
    if (!(Get-command Invoke-Sqlcmd -ErrorAction SilentlyContinue)) {
        Add-PSSnapin SqlServerCmdletSnapin100         
    }       
         
    $executestatement = "EXEC @ReturnCode = sp_addlogin @User, @pwd"

    Foreach ($key in $PSBoundParameters.Keys) {
        $key
        if (($key -eq "User") -or ($key -eq "PasswordHash")) {continue}
        if ($key -eq "encryptopt") {$executestatement = $executestatement + ", @encryptopt = '$encryptopt'" }
        $executestatement = $executestatement + ", '$($PSBoundParameters[$key])'"
    }

    switch ($Ensure) {
        "Present" {
            Invoke-Sqlcmd -Verbose -Query "DECLARE @ReturnCode INT; 
                                           DECLARE @User NVARCHAR(60); 
                                           DECLARE @Pwd NVARCHAR(128);
                                           SET @User = N'$User';
                                           SET @Pwd = CONVERT (varbinary(256), $PasswordHash)
                                           $executestatment; 
                                           Print 'Return Code from sp_Addlogin is' + @returncode"
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