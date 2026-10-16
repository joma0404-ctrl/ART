[CmdletBinding()]
param (
    [Parameter(Position=0, Mandatory=$false)]
    [string]$RepoUrl = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$gitCandidates = @(
    "git.exe",
    "$env:LOCALAPPDATA\Programs\MinGit\cmd\git.exe",
    "C:\Program Files\Git\cmd\git.exe"
)

$git = $null
foreach ($c in $gitCandidates) {
    if (Get-Command $c -ErrorAction SilentlyContinue) {
        $git = (Get-Command $c).Source
        break
    } elseif (Test-Path $c) {
        $git = (Get-Item $c).FullName
        break
    }
}

if (-not $git) {
    Write-Host "找不到 Git 執行檔。" -ForegroundColor Red
    exit 1
}

Write-Host "Git 執行路徑: $git" -ForegroundColor Green

if ($RepoUrl -ne "") {
    Write-Host "設定遠端倉庫: $RepoUrl" -ForegroundColor Cyan
    & $git remote remove origin 2>$null
    & $git remote add origin $RepoUrl
    Write-Host "正在推送到 GitHub main 分支..." -ForegroundColor Green
    & $git push -u origin main
} else {
    Write-Host "本地倉庫已就緒！" -ForegroundColor Green
    Write-Host "請在建立 GitHub Repository 後，執行：" -ForegroundColor Yellow
    Write-Host "powershell -File .\deploy-to-github.ps1 -RepoUrl '您的 GitHub 倉庫網址'" -ForegroundColor White
}
