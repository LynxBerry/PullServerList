
# return raw config
function ReadConfigFromFile
{
    param(
        [string] $strSourceFolder,
        [string] $strSourceConfigFileName
    )

    #
    @{
        "dirSource" = 'C:\Users\stevensh\Microsoft\TechOpsShanghai - MonthlySecurityPatching';
        "nameSourceFile" = 'Master SH Patching Server Inventory_Update.xlsx';
        # computed property
        "nameSourceFileFullPath" = "";
        "nameExcelSheet" = "SH";
        "nameSeqCol" = "PATsequence";
        "namePatchBatchCol" = "PatchingBatch";
        "nameServerNameCol" = "ServerName";
        "dirServerListAudit" =  'D:\SourceSum\ServerListAudit';

    }
}


# Return processed config.
function ProcessConfig
{
    param(
        [hashtable] $hashRawConfig

    )

    # Clone hashtable to avoid mutation.
    $hashComputedConfig = $hashRawConfig.Clone()

    # Generate computed settings.
    $hashComputedConfig["nameSourceFileFullPath"] = Join-Path $hashRawConfig["dirSource"] $hashRawConfig["nameSourceFile"]

    # Return resulted config.
    $hashComputedConfig
}

