# ==============================================================================
# 藝境墨華 · GitHub 一鍵發佈與推送腳本
# ==============================================================================

param (
    [Parameter(Mandatory=$false)]
    [string]$RepoUrl = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 1. 尋找 Git 執行檔
$gitCandidates = @(
    "git.exe",
    "$env:LOCALAPPDATA\Programs\MinGit\cmd\git.exe",
    "C:\Program Files\Git\cmd\git.exe",
    "C:\Program Files\Git\bin\git.exe",
    "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe"
)

$gitExe = $null
foreach ($c in $gitCandidates) {
    if (Get-Command $c -ErrorAction SilentlyContinue) {
        $gitExe = (Get-Command $c).Source
        break
    } elseif (Test-Path $c) {
        $gitExe = (Get-Item $c).FullName
        break
    }
}

if (-not $gitExe) {
    Write-Host "⚠️ 尚未偵測到 Git，正在等待 MinGit 解壓縮..." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ 使用 Git: $gitExe" -ForegroundColor Green

# 2. 初始化 Git 倉庫
if (-not (Test-Path ".git")) {
    Write-Host "📦 正在初始化本機 Git 倉庫..." -ForegroundColor Cyan
    & $gitExe init -b main
}

# 3. 檢查設定使用者名稱與信箱
$userName = & $gitExe config user.name
if (-not $userName) {
    & $gitExe config user.name "Art Exhibition Creator"
    & $gitExe config user.email "art-exhibition@example.com"
}

# 4. 加入檔案並提交
Write-Host "📄 正在準備作品檔案與網頁..." -ForegroundColor Cyan
& $gitExe add .
& $gitExe commit -m "feat: 初次發佈藝境墨華學生得獎水墨作品特展網頁"

# 5. 若有提供遠端網址則綁定並推送
if ($RepoUrl -ne "") {
    Write-Host "🔗 設定遠端倉庫網址: $RepoUrl" -ForegroundColor Cyan
    & $gitExe remote remove origin 2>$null
    & $gitExe remote add origin $RepoUrl
    
    Write-Host "🚀 正在推送至 GitHub (main 分支)..." -ForegroundColor Green
    & $gitExe push -u origin main
} else {
    Write-Host ""
    Write-Host "💡 本地 Commit 已就緒！" -ForegroundColor Green
    Write-Host "請在建立 GitHub Repository 後，執行：" -ForegroundColor Yellow
    Write-Host ".\deploy-to-github.ps1 -RepoUrl '您的 GitHub 倉庫網址'" -ForegroundColor White
}
