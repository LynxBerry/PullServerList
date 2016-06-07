# return success or not
function CopyFile
{
    param(
        [string] $strSourceFolder,
        [string] $strTargetFolder,
        [string] $strSourceFileName

    )

    # specify timeout
    # retry one time
    Robocopy $strSourceFolder $strTargetFolder $strSourceFileName /R:1

    If($?)
    {
        $true
    }
    else
    {
        #copy failed
        $false
    }


}


If ($false)
{
    . .\ProcessConfig.ps1

    $config = ProcessConfig -hashRawConfig $(ReadConfigFromFile)

    CopyFile -strSourceFolder $config["dirSource"] -strTargetFolder $config["dirServerListAudit"] -strSourceFileName $config["nameSourceFile"]


}
