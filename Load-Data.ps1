[CmdletBinding(SupportsShouldProcess)]
param (
    # Data in the form of an array of hash tables, i.e. a CSV with keys thata re internal names of fields in the target list
    [Parameter(Mandatory, ValueFromPipeline)]
    $SourceData,

    # The URL of the web to load the data into
    [Parameter(Mandatory)]
    [string]
    $WebUrl,

    # The title of the list to load the data into
    [Parameter(Mandatory)]
    [string]
    $ListTitle,

    # The key field to use to detect duplicates
    [Parameter(Mandatory)]
    [string]
    $Key
)

PROCESS {
    $ErrorActionPreference = "Stop"
    $InformationPreference = "Continue"

    function Invoke-CLI {
        param(
            # The command to execute
            [Parameter(Mandatory)]
            [string]
            $Command,

            # Output that overrides displaying the command, e.g. when it contains a plain text password
            [string]
            $Message = $Command
        )

        Write-Information -MessageData:$Message

        # Az can output WARNINGS on STD_ERR which PowerShell interprets as Errors
        $CurrentErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue" 

        Invoke-Expression -Command:$Command
        $ExitCode = $LastExitCode
        Write-Information -MessageData:"Exit Code: $ExitCode"
        $ErrorActionPreference = $CurrentErrorActionPreference

        switch ($ExitCode) {
            0 {
                Write-Debug -Message:"Last exit code: $ExitCode"
            }
            default {
                throw $ExitCode
            }
        }
    }

    $SourceData | ForEach-Object {
        $Data = $PSItem
        $KeyValue = $Data.$Key

        $ListItemCollection = m365 spo listitem list --webUrl "$WebUrl" --title $ListTitle --camlQuery "<View><Query><Where><Eq><FieldRef Name='$Key' /><Value Type='Text'>$KeyValue</Value></Eq></Where></Query></View>" --output json | Join-String | ConvertFrom-Json -AsHashTable

        $DataCollection = $Data.PSObject.Properties |
            Foreach-Object {
                if ($PSItem.Value.length -gt 0) {
                    Write-Output "--$($PSItem.Name) ""$($PSItem.Value.trim())"""
                }
            }

        if ($ListItemCollection.length -eq 0) {
            if ($PSCmdlet.ShouldProcess("$ListTitle $KeyValue", "Add list item")) {
                $ListItemCollection = @(Invoke-CLI -Command:"m365 spo listitem add --webUrl ""$WebUrl"" --listTitle ""$ListTitle"" $DataCollection --output json" | Join-String | ConvertFrom-Json -AsHashTable)
            }
        }
        else {
        $ListItemCollection | Foreach-Object {
            $ListItem = $PSItem
            $ID = $ListItem.ID

            if ($PSCmdlet.ShouldProcess("$ListTitle $ID", "Update list item")) {
                $ListItem = Invoke-CLI -Command "m365 spo listitem set --webUrl ""$WebUrl"" --listTitle ""$ListTitle"" --id $ID $DataCollection --output json" | Join-String | ConvertFrom-Json -AsHashTable
            }
        }
        }
    }
}


