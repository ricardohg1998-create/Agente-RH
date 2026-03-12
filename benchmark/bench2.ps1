$skillsRoot = ".agent/skills"
if (-not (Test-Path $skillsRoot)) {
    New-Item -ItemType Directory -Path $skillsRoot -Force | Out-Null
}

Write-Host "Creating mock files..."
for ($i = 1; $i -le 2000; $i++) {
    $dir = Join-Path $skillsRoot "skill_$i"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $content = @"
# Skill $i

This is a mock skill file.
It has some lines.
Some empty lines.

---

\`\`\`powershell
# some code
\`\`\`

This is the summary line 1.
This is the summary line 2.
This is the summary line 3.
This is the summary line 4.
This is the summary line 5.
This is the summary line 6.
This is the summary line 7.
This is the summary line 8.
This is the summary line 9.
This is the summary line 10.
"@
    Set-Content -Path (Join-Path $dir "SKILL.md") -Value $content
}

Write-Host "Running benchmark..."
$time = Measure-Command {
    pwsh -NoProfile -ExecutionPolicy Bypass -File agente-rh-template/scripts/generate-catalog.ps1
}
Write-Host "Baseline: $($time.TotalMilliseconds) ms"

Write-Host "Cleaning up mock files..."
Remove-Item -Path $skillsRoot -Recurse -Force
