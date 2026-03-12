$tempFile1 = "bench1.txt"
$tempFile2 = "bench2.txt"

Set-Content -Path $tempFile1 -Value "test string" -Encoding UTF8
Set-Content -Path $tempFile2 -Value "test string" -Encoding UTF8

$iterations = 1000

$time1 = Measure-Command {
    for ($i = 0; $i -lt $iterations; $i++) {
        $raw = Get-Content -Path $tempFile1 -Raw
        $raw += "`r`n`r`n[Enlace roto](docs/no-existe.md)`r`n"
        Set-Content -Path $tempFile1 -Encoding UTF8 -Value $raw
    }
}

$time2 = Measure-Command {
    for ($i = 0; $i -lt $iterations; $i++) {
        Add-Content -Path $tempFile2 -Value "`r`n`r`n[Enlace roto](docs/no-existe.md)`r`n" -NoNewline -Encoding utf8
    }
}

Write-Host "Baseline (+Get/Set-Content): $($time1.TotalMilliseconds) ms"
Write-Host "Optimized (Add-Content): $($time2.TotalMilliseconds) ms"

Remove-Item $tempFile1
Remove-Item $tempFile2
