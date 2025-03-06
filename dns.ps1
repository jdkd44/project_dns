# Define the path to the CSV file
$csvFilePath = "path/to/your/file.csv"
$outputCsvFilePath = "path/to/your/output_file.csv"

# Import the CSV file
$csvContent = Import-Csv -Path $csvFilePath

# Function to check if a string is a valid IP address
function IsValidIPAddress {
    param (
        [string]$ipAddress
    )
    return [System.Net.IPAddress]::TryParse($ipAddress, [ref]$null)
}

# Create a list to hold the modified rows
$modifiedRows = @()

# Loop through each row in the CSV
foreach ($row in $csvContent) {
    # Create a new ordered dictionary to hold the modified row
    $modifiedRow = [ordered]@{}

    # Loop through each column in the row
    foreach ($column in $row.PSObject.Properties) {
        $value = $column.Value
        # Add the original column to the modified row
        $modifiedRow[$column.Name] = $value

        # Check if the column value is a valid IP address
        if (IsValidIPAddress $value) {
            # Perform nslookup
            $nslookupResult = nslookup $value
            # Extract the PTR record from the nslookup result
            $ptrRecord = ($nslookupResult | Select-String -Pattern "name = (.*)$").Matches.Groups[1].Value.Trim()
            # Add the PTR record to a new column next to the original column
            $modifiedRow["${column.Name}_PTR"] = $ptrRecord
        }
    }

    # Add the modified row to the list of modified rows
    $modifiedRows += [pscustomobject]$modifiedRow
}

# Export the modified rows to a new CSV file
$modifiedRows | Export-Csv -Path $outputCsvFilePath -NoTypeInformation
