<#
 # Author: Steven Shao
 # Email: stevensh@microsoft.com
 # Description: Pull the latest server list from sharepoint excel sheet and compare against existing baseline to find out the difference.
 # Created Date: 04/01/2016 00:00:00
 # Updated Date:
 # Syntax:
 #   shell prompt> .\PullServerList.ps1
 #
 # To-Do List:
 #   Generate changeSet  files based on the difference.
#>
param(
  [switch] $test
)

# stop on error. Don't forget.

# Import modules
. .\ProcessConfig.ps1
. .\CopyFile.ps1
. .\ProcessData.ps1

function ConvertFromFStoArray()
{
  param(
    [string] $basePath
  )

  $regExpBasePath = $basePath -replace @('\\','\\')
  # for each server list file
  foreach($filePath in $(dir -Recurse $basePath | %{$_.fullname} | ?{ $_ -like '*.txt'}))
  {
    type $filePath | %{$($filePath -replace "^$regExpBasePath") + ":" + $_ }
  }
}



# Main Entry
function Main
{
    # Script Config File Info
    # [string] $strCurrentPath = GetCurrentFolder
    # [string] $strConfigXml = "PullServerListConfig.xml"

    # Script Config Data Structure
    # [hashtable] $hashRawConfig = @{}
    [hashtable] $config = @{}

    # Server Record Data Structure
    # data read from Excel Sheet
    [array] $dataItems = @()
    [hashtable] $hashDataTree = @{}

    [string] $strTimeTag = TimeTag

    Start-Transcript $(Join-Path '.' $('log' + $strTimeTag + '.txt'))

    # To-DO: Refine ReadConfigFromFile
    $config = ProcessConfig -hashRawConfig $(ReadConfigFromFile)
    # Copy Excel sheet
    CopyFile -strSourceFolder $config["dirSource"] -strTargetFolder $config["dirServerListAudit"] -strSourceFileName $config["nameSourceFile"]
    # Convert Data from Excel Sheet
    $dataItems = ConvertFromExcelToRecords -strSourceFolder $config["dirServerListAudit"] -strExcelFileName $config["nameSourceFile"] -strExcelSheetName $config["nameExcelSheet"]

    # Process Data

    # $hashDataTree = ProcessData -dataItems $dataItems -nameSeqCol $config["nameSeqCol"] -namePatchBatchCol $config["namePatchBatchCol"] -nameServerNameCol $config["nameServerNameCol"]

    $hashDataTree = ProcessData2 -data $dataItems -arrayCol @($config["nameSeqCol"], $config["namePatchBatchCol"], $config["nameServerNameCol"])

    $dirOutput = Join-path $config["dirServerListAudit"] $('Snapshot' + $strTimeTag)
    $dirBaseline = Join-path $config["dirServerListAudit"]  'Baseline'
    mkdir $dirOutput
    # TraverseDataTree and output.
    TraverseDataTree -hashDataTree $hashDataTree -takeAction $(GenAction -parentPath $dirOutput)

    # Get baseline data from baseline folder
    [array] $base = ConvertFromFStoArray -basePath $dirBaseline

    # Get snapshot data from snapshot folder
    [array] $snapshot = ConvertFromFStoArray -basePath $dirOutput

    $(diff $base $snapshot | sort InputObject | format-table ) | Out-File -Encoding utf8 -FilePath $(Join-path $config["dirServerListAudit"] $('diff' + $strTimeTag + '.txt'))

    Stop-Transcript

}

# Run it

Main
