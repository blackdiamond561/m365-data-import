# m365-data-import

Utilities to import data from file storage to m365 drives, e.g. SharePoint lists and libraries

## Usage

### Authentication

The scripts assume that the current identity is already authenticated by a suitable method and that that identity has suitable authorization on the source and target locations.

### Examples

To upload data from a CSV file to a SharePoint list ensuring all titles are unique

```ps1
m365 login
Get-Content -Path:./data.csv |
    ConvertFrom-Csv |
    ./Load-Data.ps1 `
        -Url:https://tenancy.sharepoint.com/sites/site `
        -ListTitle:"My List" `
        -Key:Title
```

CSV file uses one row per item and one field, with internal name, per field.

```csv
Title,Description
My Title,"My Description"
```

## Build

## Design

## Contributions
