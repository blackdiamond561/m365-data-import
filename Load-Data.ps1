[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory, ValueFromPipeline)]
    $SourceData
)

PROCESS {
    $SourceData | ForEach-Object {
        $Data = $PSItem
        $WebUrl = $Data.WebUrl
        $ListTitle = $Data.ListTitle
        $Key = "Title"
        $KeyValue = $Data.$Key

        $ListItemCollection = m365 spo listitem list --webUrl $WebUrl --title $ListTitle --camlQuery "<View><Query><Where><Eq><FieldRef Name='Title' /><Value Type='Text'>$($Data.Title)</Value></Eq></Where></Query></View>" --output json | Join-String | ConvertFrom-Json -AsHashTable

        if ($ListItemCollection.length -eq 0) {
            if ($PSCmdlet.ShouldProcess($KeyValue, "Add list item")) {
                $ListItemCollection = @(m365 spo listitem add --webUrl $WebUrl --listTitle $ListTitle --Title "$($Data.Title)" --output json | Join-String | ConvertFrom-Json -AsHashTable)
            }
        }

        $ListItemCollection | Foreach-Object {
            $ListItem = $PSItem
            $ID = $ListItem.ID
            if ($PSCmdlet.ShouldProcess($ID, "Update list item")) {
                $ListItemUpdated = m365 spo listitem set --webUrl $WebUrl --listTitle $ListTitle --id $ID --Title $($Data.Title) --output json | Join-String | ConvertFrom-Json -AsHashTable
                Write-Debug $ListItemUpdated
            }
        }
    }
}
