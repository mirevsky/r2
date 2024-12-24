# install.ps1
function r2_read
{
    param($prompt)
    $set_read = Read-Host -Prompt $prompt
    return $set_read
}

$confirm = r2_read "Are you sure you want to install R2 CLI [y/N]?"

if ($confirm -eq "Y" -or $confirm -eq "y")
{
    $R2_WORKSPACE = Resolve-Path (Join-Path $PWD "..")

    # Copy the app.sh script (you might want to rename or adjust this for PowerShell)
    Copy-Item -Path ".\app.ps1" -Destination (Join-Path $R2_WORKSPACE ".r2.ps1")

    # Make the script executable (PowerShell doesn't use chmod, but you can set execution policy)
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

    # Update PowerShell profile
    $PROFILE_PATH = $PROFILE.CurrentUserCurrentHost

    if (Test-Path $PROFILE_PATH)
    {
        Add-Content -Path $PROFILE_PATH -Value "
`$R2_WORKSPACE = '$R2_WORKSPACE'
Set-Alias -Name r2 -Value '$R2_WORKSPACE\.r2.ps1'
"
        # Reload profile
        . $PROFILE_PATH
    }
    else
    {
        New-Item -Path $PROFILE_PATH -ItemType File -Force
        Add-Content -Path $PROFILE_PATH -Value "
`$R2_WORKSPACE = '$R2_WORKSPACE'
Set-Alias -Name r2 -Value '$R2_WORKSPACE\.r2.ps1'
"
        # Reload profile
        . $PROFILE_PATH
    }
    doskey r2=$R2_WORKSPACE\.r2.ps1
    reg add "HKCU\Software\Microsoft\Command Processor" /v Autorun /d "doskey /r2=$R2_WORKSPACE\.r2.ps1" /f
    reg query "HKCU\Software\Microsoft\Command Processor" /v Autorun
}
