# Creates a new portfolio project from your template and tags it 'portfolio',
# so it shows on your GitHub profile automatically.
# Usage (in PowerShell, from anywhere):
#   & "$HOME\code\cloud-journey\scripts\new-project.ps1" -Name cloud-resume-challenge -Description "My resume on Azure, built with Terraform"
param(
    [Parameter(Mandatory = $true)][string]$Name,
    [string]$Description = ''
)
$login = ((gh api user --jq .login) -join '').Trim()
$codeRoot = Join-Path $HOME 'code'
$dest = Join-Path $codeRoot $Name

gh repo create "$login/$Name" --public --template "$login/cloud-project-template" --description "$Description"
if ($LASTEXITCODE -ne 0) { Write-Host 'Could not create the repo.' -ForegroundColor Red; exit 1 }
gh repo edit "$login/$Name" --add-topic 'portfolio,azure,terraform' | Out-Null

# The template needs a few seconds before it can be cloned
foreach ($i in 1..6) {
    Start-Sleep -Seconds 5
    gh repo clone "$login/$Name" "$dest" 2>$null
    if (Test-Path (Join-Path $dest 'README.md')) { break }
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
}
if (-not (Test-Path (Join-Path $dest 'README.md'))) { Write-Host 'Repo created, but cloning failed. Try: gh repo clone' "$login/$Name" -ForegroundColor Yellow; exit 1 }

# Put the project's own name into its README
$readme = Join-Path $dest 'README.md'
$text = [IO.File]::ReadAllText($readme).Replace('REPO-NAME', $Name).Replace('# Project name', "# $Name")
if ($Description) { $text = $text.Replace('One-line summary of what this project does.', $Description) }
[IO.File]::WriteAllText($readme, $text, (New-Object Text.UTF8Encoding $false))
Push-Location $dest
git add README.md
git commit -q -m "Name the project"
git push -q
Pop-Location

Write-Host "Created https://github.com/$login/$Name in $dest" -ForegroundColor Green
Write-Host 'It appears on your profile within six hours, or straight away if you run the'
Write-Host "'Update profile' action in your $login repo's Actions tab."
