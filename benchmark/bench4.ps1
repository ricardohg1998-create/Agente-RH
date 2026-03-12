$skillsRoot = ".agent/skills"
if (-not (Test-Path $skillsRoot)) {
    New-Item -ItemType Directory -Path $skillsRoot -Force | Out-Null
}

Write-Host "Creating mock files..."
for ($i = 1; $i -le 1000; $i++) {
    $dir = Join-Path $skillsRoot "skill_$i"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $content = ""
    for ($j = 1; $j -le 50; $j++) {
        $content += "Line $j`n"
    }
    Set-Content -Path (Join-Path $dir "SKILL.md") -Value $content
}

Write-Host "Running benchmark..."

$time1 = Measure-Command {
    $repoRoot = (Resolve-Path (Join-Path 'agente-rh-template/scripts' '..')).Path
    $skillsRootFull = Join-Path $repoRoot '.agent/skills'

    $skillFiles = @()
    if (Test-Path -LiteralPath $skillsRootFull -PathType Container) {
        $skillFiles = @(Get-ChildItem -Path $skillsRootFull -Filter SKILL.md -Recurse -File | Sort-Object FullName)
    }

    foreach ($skillFile in $skillFiles) {
        $raw = Get-Content -Path $skillFile.FullName -Raw
        $lines = @()
        foreach ($line in ($raw -split "`r?`n")) {
            $clean = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($clean)) { continue }
            if ($clean.StartsWith('#')) { continue }
            if ($clean.StartsWith('```')) { continue }
            if ($clean.StartsWith('---')) { continue }
            $lines += $clean
        }
    }
}
Write-Host "Baseline array concat: $($time1.TotalMilliseconds) ms"

$time2 = Measure-Command {
    $repoRoot = (Resolve-Path (Join-Path 'agente-rh-template/scripts' '..')).Path
    $skillsRootFull = Join-Path $repoRoot '.agent/skills'

    $skillFiles = @()
    if (Test-Path -LiteralPath $skillsRootFull -PathType Container) {
        $skillFiles = @(Get-ChildItem -Path $skillsRootFull -Filter SKILL.md -Recurse -File | Sort-Object FullName)
    }

    foreach ($skillFile in $skillFiles) {
        $raw = Get-Content -Path $skillFile.FullName -Raw
        $lines = [System.Collections.Generic.List[string]]::new()
        foreach ($line in ($raw -split "`r?`n")) {
            $clean = $line.Trim()
            if ([string]::IsNullOrWhiteSpace($clean)) { continue }
            if ($clean.StartsWith('#')) { continue }
            if ($clean.StartsWith('```')) { continue }
            if ($clean.StartsWith('---')) { continue }
            $lines.Add($clean)
        }
    }
}
Write-Host "Optimized list add: $($time2.TotalMilliseconds) ms"

Write-Host "Cleaning up mock files..."
Remove-Item -Path $skillsRoot -Recurse -Force
