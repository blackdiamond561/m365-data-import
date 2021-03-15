[CmdletBinding(SupportsShouldProcess)]
param (
    # Data in the form of an array of hash tables, i.e. a CSV filed
    [Parameter(Mandatory, ValueFromPipeline)]
    $SourceData,

    # The URL of the web to load the data into
    [Parameter(Mandatory)]
    [string]
    $WebUrl,

    # The tilte of the list to load the data into
    [Parameter(Mandatory)]
    [string]
    $ListTitle
)

PROCESS {
    $SourceData | ForEach-Object {
        $Data = $PSItem
        $Key = $Data.Key
        $KeyValue = $Data.$Key

        $ListItemCollection = m365 spo listitem list --webUrl $WebUrl --title $ListTitle --camlQuery "<View><Query><Where><Eq><FieldRef Name='$Key' /><Value Type='Text'>$($Data.Title)</Value></Eq></Where></Query></View>" --output json | Join-String | ConvertFrom-Json -AsHashTable

        if ($ListItemCollection.length -eq 0) {
            if ($PSCmdlet.ShouldProcess("$ListTitle $KeyValue", "Add list item")) {
                $ListItemCollection = @(m365 spo listitem add --webUrl $WebUrl --listTitle $ListTitle --Title "$($Data.Title)" --output json | Join-String | ConvertFrom-Json -AsHashTable)
            }
        }

        $ListItemCollection | Foreach-Object {
            $ListItem = $PSItem
            $ID = $ListItem.ID
            if ($PSCmdlet.ShouldProcess("$ListTitle $ID", "Update list item")) {
                $ListItemUpdated = m365 spo listitem set --webUrl $WebUrl --listTitle $ListTitle --id $ID --Title $($Data.Title) --output json | Join-String | ConvertFrom-Json -AsHashTable
                Write-Debug $ListItemUpdated
            }
        }
    }
}


