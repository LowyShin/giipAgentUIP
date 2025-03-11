# User Variables ===============================================
$factor = "MachineResource"
$Attrib = "Status"
$sk = "9e2d4fbb9ba8516884604429fe47bd88"
$lssn = "71197"

# Get System Information ========================================
$cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
$mem = Get-WmiObject Win32_OperatingSystem
$totalMemory = [math]::Round($mem.TotalVisibleMemorySize / 1MB, 2)
$freeMemory = [math]::Round($mem.FreePhysicalMemory / 1MB, 2)
$usedMemory = $totalMemory - $freeMemory

$disk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | 
    Select-Object DeviceID, @{Name="TotalGB"; Expression={[math]::Round($_.Size / 1GB, 2)}}, 
                  @{Name="FreeGB"; Expression={[math]::Round($_.FreeSpace / 1GB, 2)}}

# JSON 데이터 생성 ==============================================
$valueJSON = @{}
$valueJSON["Factor-Attrib"] = "PC Status"
$valueJSON["CPU_Usage"] = [math]::Round($cpuLoad, 2)
$valueJSON["TotalMemory_GB"] = $totalMemory
$valueJSON["UsedMemory_GB"] = $usedMemory
$valueJSON["FreeMemory_GB"] = $freeMemory

# 디스크 데이터 펼치기
$disk | ForEach-Object {
    $drive = $_.DeviceID
    $valueJSON["Disk_${drive}_Total_GB"] = $_.TotalGB
    $valueJSON["Disk_${drive}_Free_GB"] = $_.FreeGB
}

# Send to KVSAPI Server =========================================
$qs = @{
    sk = $sk
    type = "lssn"
    key = $lssn
    factor = "$factor-$Attrib"
    value = ($valueJSON | ConvertTo-Json -Depth 3)
} 

$lwAPIURL = "https://giipasp.azurewebsites.net/API/kvs/kvsput.asp"

$response = Invoke-RestMethod -Uri $lwAPIURL -Method Post -Body $qs

# Print Response (for debugging)
Write-Output $response

#Start-Sleep -Seconds 5