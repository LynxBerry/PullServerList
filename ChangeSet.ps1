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

#--- Use a seperate command to commit the change ---#
# Backup the target server list file.

# Write log about the change.

# Commit the change set to the target server list file.