# Change Set concept

$sampleChangeSet = @{
    "SequenceName" = "BJB_Patch_By_Scripts";
    "BatchName" = "cp-host-1";
    "Add" = @("server1", "server2");
    "Remove" = @("server3", "server4");
    "SnapshotTag" = "Snapshot06202016_11_33_51";
}


# Generate Change Set.
# Can use format of Json.
# Generation happens each time the script scans the difference.
# Generate from where: diff result.
# Change Sets ==> Change Set
function genChangeSets {
    param(
        $diffResults
    )
    $changeSets = @{}
    foreach ($diffResult in $diffResults) {
        $items = $diffResult.InputObject.split(":")
        if ($changeSets.keys -notcontains $items[0]) {
            $changeSets[$items[0]] = @{}
        }

        $action = ""
        if ($diffResult.SideIndicator -eq "=>") {
            $action = "add"
        } else {
            $action = "remove"
        }

        $($changeSets[$items[0]])[$action] += @($items[1])
     }

     $changeSets

}

function genChangeSet {
    param(
        [hash] $changeSets
    )

    foreach ($changeSet in $changeSets.GetEnumerator()) {
        $keyname = $changeSet.key
        # unfinished
    }
}

# Test
$left = @(
    '\APClientPROD.xml\apclient-1st.txt:DM2SP1PINBHCA01',     
    '\APClientPROD.xml\apclient-4th.txt:CO1SOLBHCBN05'    
)

$right = @(
    '\BJB_Patch_By_Scripts\cp-1.txt:BJBCCOPSFTP01',  
    '\BJB_Patch_By_Scripts\cp-1.txt:BJBCCSQLBAKA03', 
    '\BJB_Patch_By_Scripts\cp-1.txt:BJBCSMEAD02',    
    '\BJB_Patch_By_Scripts\cp-1.txt:SHACSMEADMUTL02',
    '\BJB_Patch_By_Scripts\cp-2.txt:BJBCSMEAD01',    
    '\BJB_Patch_By_Scripts\cp-2.txt:SHACSMEADMDEP02',
    '\BJB_Patch_By_Scripts\cp-2.txt:SHACSMEADMUTL01'

)

$diffResults = diff $left $right
#echo $diffResults
#echo "==="
genChangeSets -diffResults $diffResults | convertTo-Json

#--- Use a seperate command to commit the change ---#
# Backup the target server list file.

# Write log about the change.

# Commit the change set to the target server list file.