# Import the CSV file
$csvPath = "test1.csv"
$outputCsvPath = "output.csv"
$csvContent = Import-Csv -Path $csvPath

# Function to check if a string is a valid IP address using regex
function IsValidIpAddress($ipAddress) {
    $regex = '^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$'
    return $ipAddress -match $regex
}

# Array to hold the results
$results = @()

# Process each row in the CSV
foreach ($row in $csvContent) {
    foreach ($column in $row.PSObject.Properties) {
        $value = $column.Value
        if (IsValidIpAddress $value) {
            Write-Output "Performing nslookup on IP: $value"
            # Perform nslookup and mask errors
            $nslookupResult = nslookup -type=PTR $value 2>$null
            # Parse the nslookup result to find the name
            $name = $nslookupResult | Select-String -Pattern "name = (.*)" | ForEach-Object { $_.Matches[0].Groups[1].Value }
            if ($name) {
                # Add the IP and name to the results array
                $results += [PSCustomObject]@{ IP = $value; Name = $name }
            } else {
                # Add the IP with "NOT FOUND" to the results array
                $results += [PSCustomObject]@{ IP = $value; Name = "NOT FOUND" }
            }
        }
    }
}

# Export the results to a new CSV file
$results | Export-Csv -Path $outputCsvPath -NoTypeInformation
