# It has side effects.
function ConvertFromExcelToRecords
{
    param(
        [string] $strSourceFolder,
        [string] $strExcelFileName,
        [string] $strExcelSheetName
    )

    Import-Module PSExcel

    @(Import-XLSX -Path $(Join-Path $strSourceFolder $strExcelFileName) -Sheet $strExcelSheetName)

}

function GetArrayofData # return array of data in target column
{
    param(
        [array] $dataItems,

        #filter conditions
        # ordered hashtable
        [hashtable] $filters,

        # target column to return
        [string] $targetCol
    )


    function InnerFilter
    {
        param(
            [array] $dataItems,
            # ordered hasntable
            [hashtable] $filters

        )

        # if still have filters
        if ($filters.Count -gt 0 )
        {
            #write-host "rabit"

             # Use first filter to filter
            $filter = $($filters.GetEnumerator())[0]
            $column = $filter.key
            $value = $filter.value

            # test code
            # write-host "Count of dataItems $($dataItems.Count)"
            # write-host "column: $column"
            # write-host "value: $value"

            #Big mistake
            $tmpFilters = $filters.Clone()
            $tmpFilters.Remove($filter.key)
            InnerFilter -dataItems @($dataItems | ?{ $_.$column -eq $value}) -filters $tmpFilters

            return

        }

        #write-host "rabit0"
        #write-host "$($dataItems.count)"
        $dataItems


    }

    @(InnerFilter -dataItems $dataItems -filters $filters | %{ $_.$targetCol} | sort -unique | ?{ $_.trim() -ne ''})


}

function ProcessData
{
    param(
        [array] $dataItems,

        # Name of PAT Sequence Column
        [string] $nameSeqCol,

        # Name of Patch Batch Column
        [string] $namePatchBatchCol,

        # Name of Server Name Column
        [string] $nameServerNameCol
    )


    # write-host "yyyxxx$namePatchBatchCol"
    # Data Structure holding resulted data
    [hashtable] $hashDataTree = @{}

    foreach($objPatSeq in @(GetArrayofData -dataItems $dataItems -filters @{} -targetCol $nameSeqCol))
    {
        $hashDataTree[$objPatSeq] = @{}
            #write-host "yyy$namePatchBatchCol"
            #write-host "zzz$nameSeqCol"

        foreach($objPatBatch in @(GetArrayofData -dataItems $dataItems -filters @{"$nameSeqCol" = "$objPatSeq"} -targetCol $namePatchBatchCol))
        {

            # Test output
            if ($test) { write-host "$objPatSeq $objPatPatch" }

            $hashDataTree[$objPatSeq][$objPatBatch] = @(GetArrayofData -dataItems $dataItems -filters @{"$nameSeqCol" = "$objPatSeq"; "$namePatchBatchCol" = "$objPatBatch"} -targetCol $nameServerNameCol);
        }

    }

    $hashDataTree
    # write-host "xxx"

}

function ProcessData2
{
    param(
        [array] $data,
        [array] $arrayCol
    )
    write-host "columns $arrayCol"

     function inner
     {
           param(
                $item,
                $arrayCol,
                $hash

            )

            if($item.$($arrayCol[0]) -and ($item.$($arrayCol[0]).trim() -ne ''))
            {
              if ($arrayCol.Count -eq 2 )
              {

                  if($item.$($arrayCol[1]) -and $item.$($arrayCol[1]).trim() -ne '')
                  {
                    $hash[$item.$($arrayCol[0])] += @($item.$($arrayCol[1]))
                  }

              }
              else # >2
              {
                  if($hash.keys -notcontains $item.$($arrayCol[0]))
                  {
                      $hash[$item.$($arrayCol[0])] = @{}
                  }

                  inner -item $item -arrayCol $arrayCol[1..$arrayCol.Count] -hash $hash[$item.$($arrayCol[0])]

                  # $hash[$item.$($arrayCol[0])][$item.$($arrayCol[1])] = @{}


              }
          }


      }


    $hash = @{}

    foreach($item in $data)
    {
        inner -item $item -arrayCol $arrayCol -hash $hash

    }

    $hash



}



# Function Factory
# Return function.
function GenAction
{
	param(
		$parentPath
	)

	{
    param(
      $node,
      $path
    )
		if($node.value -is [hashtable]) # If the node refers to hashtable, it means the node itself is folder. We need to make folder of it.
		{
			mkdir $(join-path $parentPath $(join-path $path $node.key))
		}
		elseif($node.value -is [array]) # If the node refers to array, it means the node itself is file.txt. We need to create a file.txt of it.
		{
			$node.value >  $(join-path $parentPath $(join-path $path $($node.key + ".txt")))
		}

	}.GetNewClosure()

}


function TraverseDataTree
{
    param(
        [hashtable] $hashDataTree,
        [string]   $path = ".", # default current folder
        [scriptblock] $takeAction
    )

    foreach($node in $hashDataTree.GetEnumerator())
    {
        & $takeAction -node $node -path $path

        if($node.value -is [hashtable])
        {
            TraverseDataTree -hashDataTree $node.value -path $(join-path $path $node.key) -takeAction $takeAction
        }

    }

}

# has side effects.
function TimeTag
{
    get-date -f 'MMddyyy_hh_mm_ss'

}

# The hash data structure sample:
<#
@{
    "sequence1" = @{
                        "PatchBatch1" = @("srv1", "srv2", "srv3");
                        "PatchBatch2" = @("srv1", "srv2", "srv3");
                  };

    "sequence2" = @{}




}
#>
