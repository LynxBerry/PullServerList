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
			# $node.value >  $(join-path $parentPath $(join-path $path $($node.key + ".txt")))
            # Use encoding ascii for output file otherwise the reader cannot work properly.
            $node.value | Out-File -Encoding ascii -FilePath $(join-path $parentPath $(join-path $path $($node.key + ".txt")))
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
    get-date -f 'MMddyyy_HH_mm_ss'

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
