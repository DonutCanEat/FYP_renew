<#
.SYNOPSIS
    FYP（Victor2 Enterprise Network Infrastructure）唯一驗證入口。

.DESCRIPTION
    實作 agent.md §0 嘅 R1 規矩：
      任何修改都要先驗證，全部通過（RESULT: PASS，退出碼 0）先可以繼續下一步。

    階段（Stage）：
      A  檔案與文件基本檢查（UTF-8、編碼規則、無 tab、無不可見字元、
         .ps1 語法可解析、Markdown 連結可解析、agent.md 兩條最高規矩齊全）
      B  A ＋ 文件聲明一致性 ＋ tools/manifest.json 逐檔 SHA-256 比對（漂移偵測）
      D  B ＋ 里程碑驗收準則齊全檢查（成功準則／範圍外／評估套件／路線圖／風險）
      C  預留：IaC／自動化／AI 管理層嘅實測檢查（加入時在此擴充）

    編碼硬規則（踩過先寫落嚟）：
      * 所有 .ps1 必須帶 UTF-8 BOM。Windows PowerShell 5.1 會以 ANSI 讀冇 BOM 嘅 .ps1，
        中文註解會被誤讀並令整個腳本解析失敗（本檔第一版就係咁爆）。
      * 其他文字檔（.md／.txt 等）不准帶 BOM。

.PARAMETER Stage
    A、B（預設）或 D。

.PARAMETER Note
    今次驗證嘅說明，會寫入 _reports/ 記錄。

.PARAMETER WriteManifest
    重新產生 tools/manifest.json（確認改動無誤後使用；之後必須同一次 commit 一齊交）。

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/verify.ps1 -Note "改咗 README"

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/verify.ps1 -WriteManifest
#>
[CmdletBinding()]
param(
    [ValidateSet('A', 'B', 'D')]
    [string]$Stage = 'B',

    [string]$Note = '',

    [switch]$WriteManifest
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $root 'tools\manifest.json'
$reportDir = Join-Path $root '_reports'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# ── 收集結果 ────────────────────────────────────────────────────────────────
$results = New-Object System.Collections.ArrayList

function Add-Result {
    param([string]$Name, [bool]$Ok, [string]$Detail)
    [void]$results.Add([pscustomobject]@{ Check = $Name; Ok = $Ok; Detail = $Detail })
    $color = if ($Ok) { 'Green' } else { 'Red' }
    Write-Host ("[{0}] {1}" -f $(if ($Ok) { 'PASS' } else { 'FAIL' }), $Name) -ForegroundColor $color
    if ($Detail) { Write-Host ("       {0}" -f $Detail) -ForegroundColor DarkGray }
}

function Get-Utf8Hash {
    param([string]$Text)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($bytes)
        return ([System.BitConverter]::ToString($hash) -replace '-', '').ToLowerInvariant()
    } finally {
        $sha.Dispose()
    }
}

function Read-TextFile {
    param([string]$FullPath)
    return [System.IO.File]::ReadAllText($FullPath, $utf8NoBom)
}

function Get-TrackedFile {
    $skipDirs = @('_reports', '.git', 'node_modules', '.venv', 'venv', '__pycache__', '.dsh', '.vscode')
    Get-ChildItem -Path $root -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $rel = $_.FullName.Substring($root.Length + 1).Replace('\', '/')
            $parts = $rel.Split('/')
            if (@($parts | Where-Object { $skipDirs -contains $_ }).Count -gt 0) { return $false }
            if ($_.Name -like '*.tmp' -or $_.Name -like '*.bak' -or $_.Name -like '*.log') { return $false }
            return $true
        } |
        ForEach-Object { $_.FullName.Substring($root.Length + 1).Replace('\', '/') } |
        Sort-Object
}

# ── 檢查：文字檔可讀性與編碼 ────────────────────────────────────────────────
function Test-TextReadable {
    param([string]$RelPath)

    $full = Join-Path $root ($RelPath -replace '/', '\')
    if (-not (Test-Path -LiteralPath $full)) {
        Add-Result -Name "檔案存在：$RelPath" -Ok $false -Detail '找不到檔案'
        return $null
    }
    Add-Result -Name "檔案存在：$RelPath" -Ok $true -Detail ''

    $bytes = [System.IO.File]::ReadAllBytes($full)
    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)

    $strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)
    $text = $null
    try {
        $text = $strictUtf8.GetString($bytes)
        Add-Result -Name "UTF-8 可解碼：$RelPath" -Ok $true -Detail ("{0} bytes" -f $bytes.Length)
    } catch {
        Add-Result -Name "UTF-8 可解碼：$RelPath" -Ok $false -Detail $_.Exception.Message
        return $null
    }

    # 編碼規則：.ps1 必須有 BOM；其他文字檔不准有 BOM
    if ($RelPath -like '*.ps1') {
        Add-Result -Name "UTF-8 BOM（.ps1 必須有）：$RelPath" -Ok $hasBom -Detail $(if ($hasBom) {
            'OK（PowerShell 5.1 才讀得對中文）'
        } else {
            '缺少 BOM：PS 5.1 會以 ANSI 讀，中文註解令腳本解析失敗'
        })
    } else {
        Add-Result -Name "無 BOM：$RelPath" -Ok (-not $hasBom) -Detail $(if ($hasBom) { '檔案帶 U+FEFF BOM' } else { 'OK' })
    }

    return $text
}

# ── 檢查：文字檔衛生（tab／不可見字元／語法／連結） ─────────────────────────
function Test-TextHygiene {
    param([string]$RelPath)

    $text = Test-TextReadable -RelPath $RelPath
    if ($null -eq $text) { return }
    $full = Join-Path $root ($RelPath -replace '/', '\')

    # 禁止 hard tab
    $tabLines = @()
    $lineNo = 0
    foreach ($line in ($text -split "`r`n|`n")) {
        $lineNo++
        if ($line -match "`t") { $tabLines += $lineNo }
    }
    Add-Result -Name "無 tab 字元：$RelPath" -Ok ($tabLines.Count -eq 0) -Detail $(if ($tabLines.Count) { "行：$($tabLines -join ', ')" } else { 'OK' })

    # 禁止不可見／雙向控制字元（.ps1 必須有 BOM，該 BOM 已由 Test-TextReadable 驗過，唔當作違規）
    $scanText = $text
    if ($scanText.StartsWith([string][char]0xFEFF)) { $scanText = $scanText.Substring(1) }
    $badLines = @()
    $lineNo = 0
    foreach ($line in ($scanText -split "`r`n|`n")) {
        $lineNo++
        if ($line -match '[\u200B-\u200F\u202A-\u202E\u2060-\u2064\uFEFF]') { $badLines += $lineNo }
    }
    Add-Result -Name "無不可見字元：$RelPath" -Ok ($badLines.Count -eq 0) -Detail $(if ($badLines.Count) { "行：$($badLines -join ', ')" } else { 'OK' })

    # .ps1 語法必須可解析（唔執行，只解析）
    if ($RelPath -like '*.ps1') {
        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseFile($full, [ref]$null, [ref]$parseErrors)
        $messages = @()
        foreach ($e in @($parseErrors)) { $messages += ("行 {0}：{1}" -f $e.Extent.StartLineNumber, $e.Message) }
        Add-Result -Name "PowerShell 語法可解析：$RelPath" -Ok ($messages.Count -eq 0) -Detail $(if ($messages.Count) { $messages -join '；' } else { 'OK' })
    }

    # Markdown 連結必須指得到真實檔案
    if ($RelPath -like '*.md') {
        $broken = New-Object System.Collections.ArrayList
        foreach ($m in [regex]::Matches($text, '\[[^\]]*\]\(([^)]+)\)')) {
            $target = $m.Groups[1].Value.Trim()
            if ($target -match '^[a-zA-Z][a-zA-Z0-9+.-]*:') { continue }   # http(s)、mailto 等
            if ($target.StartsWith('#')) { continue }                       # 同檔錨點
            $target = ($target -split '#')[0]
            if ([string]::IsNullOrWhiteSpace($target)) { continue }
            $resolved = Join-Path (Split-Path -Parent $full) ($target -replace '/', '\')
            if (-not (Test-Path -LiteralPath $resolved)) {
                $line = ($text.Substring(0, $m.Index) -split "`n").Count
                [void]$broken.Add("$target（第 $line 行）")
            }
        }
        Add-Result -Name "Markdown 連結可解析：$RelPath" -Ok ($broken.Count -eq 0) -Detail $(if ($broken.Count) { $broken -join '；' } else { 'OK' })
    }
}

# ── 檢查：agent.md 兩條最高規矩 ─────────────────────────────────────────────
function Test-AgentRules {
    $full = Join-Path $root 'agent.md'
    if (-not (Test-Path -LiteralPath $full)) {
        Add-Result -Name 'agent.md 兩條最高規矩' -Ok $false -Detail '找不到 agent.md'
        return
    }
    $text = Read-TextFile -FullPath $full

    $required = @(
        @{ Label = 'R1 使用者原話'; Pattern = '有任何修改都要進行驗證' },
        @{ Label = 'R2 使用者原話'; Pattern = '每一次修改都要進行一次 commit' },
        @{ Label = 'R1 條文'; Pattern = '\*\*R1\*\*' },
        @{ Label = 'R2 條文'; Pattern = '\*\*R2\*\*' },
        @{ Label = '驗證入口指令'; Pattern = 'tools/verify\.ps1' },
        @{ Label = 'Manifest 漂移檢查'; Pattern = 'manifest\.json' },
        @{ Label = 'Commit 只准明確路徑'; Pattern = 'git add' },
        @{ Label = '明文禁止 git add -A'; Pattern = 'git add -A' },
        @{ Label = 'AI 唯讀預設'; Pattern = '唯讀為預設' },
        @{ Label = '變更五步鏈'; Pattern = '一次性 token' },
        @{ Label = '護欄：prompt injection'; Pattern = 'prompt injection' },
        @{ Label = '護欄：爆炸半徑'; Pattern = '爆炸半徑' },
        @{ Label = '完成定義章節'; Pattern = '## 7\. 完成定義' },
        @{ Label = '疑難排解章節'; Pattern = '## 8\. 疑難排解' }
    )

    $missing = @()
    foreach ($item in $required) {
        if (-not [regex]::IsMatch($text, $item.Pattern)) { $missing += $item.Label }
    }
    Add-Result -Name 'agent.md 兩條最高規矩齊全' -Ok ($missing.Count -eq 0) -Detail $(if ($missing.Count) { '缺少：' + ($missing -join '、') } else { "$($required.Count) 項齊全" })
}

# ── 檢查：文件聲明一致性 ────────────────────────────────────────────────────
function Test-Consistency {
    $readme = Join-Path $root 'README.md'
    $agent = Join-Path $root 'agent.md'
    if (-not (Test-Path -LiteralPath $readme) -or -not (Test-Path -LiteralPath $agent)) {
        Add-Result -Name '文件聲明一致性' -Ok $false -Detail '缺少 README.md 或 agent.md'
        return
    }
    $errors = @()

    $pairs = @(
        @{ File = $agent; Label = 'agent.md 提到 README.md'; Needle = 'README.md' },
        @{ File = $readme; Label = 'README.md 提到 agent.md'; Needle = 'agent.md' },
        @{ File = $readme; Label = 'README.md 提到驗證指令'; Needle = 'verify.ps1' }
    )
    foreach ($entry in $pairs) {
        $t = Read-TextFile -FullPath $entry.File
        if (-not $t.Contains($entry.Needle)) { $errors += $entry.Label }
    }

    # agent.md 引用嘅工具檔案必須真係存在
    foreach ($tool in @('tools/verify.ps1', 'tools/manifest.json')) {
        if (-not (Test-Path -LiteralPath (Join-Path $root ($tool -replace '/', '\')))) { $errors += "文件引用但不存在：$tool" }
    }

    Add-Result -Name '文件聲明一致性' -Ok ($errors.Count -eq 0) -Detail $(if ($errors.Count) { $errors -join '；' } else { 'OK' })
}

# ── 檢查：里程碑驗收準則齊全（Stage D） ─────────────────────────────────────
function Test-MilestoneContent {
    $readme = Join-Path $root 'README.md'
    if (-not (Test-Path -LiteralPath $readme)) {
        Add-Result -Name 'README 驗收準則齊全' -Ok $false -Detail '找不到 README.md'
        return
    }
    $text = Read-TextFile -FullPath $readme

    $required = @(
        @{ Label = '三族可達'; Pattern = '可達' },
        @{ Label = 'IaC 可重建'; Pattern = '重建' },
        @{ Label = '自動化幂等'; Pattern = '幂等' },
        @{ Label = 'AI 唯讀'; Pattern = '唯讀' },
        @{ Label = '人手批准'; Pattern = '批准' },
        @{ Label = 'Prometheus 監控'; Pattern = 'Prometheus' },
        @{ Label = '五階段流程'; Pattern = 'Manual deploy' },
        @{ Label = '範圍外聲明'; Pattern = '範圍外' },
        @{ Label = '評估套件'; Pattern = '評估' },
        @{ Label = '路線圖關卡 G0'; Pattern = 'G0' },
        @{ Label = '風險表'; Pattern = '風險' },
        @{ Label = '交付項 D1'; Pattern = 'D1' },
        @{ Label = '兩台實體 Cisco 目標'; Pattern = '4 Router' }
    )

    $missing = @()
    foreach ($item in $required) {
        if (-not [regex]::IsMatch($text, $item.Pattern)) { $missing += $item.Label }
    }
    Add-Result -Name 'README 驗收準則齊全' -Ok ($missing.Count -eq 0) -Detail $(if ($missing.Count) { '缺少：' + ($missing -join '、') } else { "$($required.Count) 項齊全" })
}

# ── 檢查：Manifest 漂移偵測（Stage B） ──────────────────────────────────────
function Test-Manifest {
    $files = @(Get-TrackedFile)
    $hashTargets = @($files | Where-Object { $_ -ne 'tools/manifest.json' })

    $expected = @{}
    foreach ($f in $hashTargets) {
        $expected[$f] = Get-Utf8Hash (Read-TextFile -FullPath (Join-Path $root ($f -replace '/', '\')))
    }

    if ($WriteManifest) {
        $entries = @()
        foreach ($f in $hashTargets) { $entries += [pscustomobject]@{ path = $f; sha256 = $expected[$f] } }
        $obj = [pscustomobject]@{
            version   = 1
            algorithm = 'sha256'
            note      = '由 tools/verify.ps1 -WriteManifest 產生，唔准手改；tools/manifest.json 自身不列入清單。'
            hashMode  = 'UTF-8 文字內容之 SHA-256；.docx 二進位檔以 UTF-8 解碼後計算，只用於偵測改動。'
            files     = $entries
        }
        $json = $obj | ConvertTo-Json -Depth 5
        [System.IO.File]::WriteAllText($manifestPath, $json + "`n", $utf8NoBom)
        Add-Result -Name 'Manifest 已重新產生' -Ok $true -Detail ("記錄 {0} 個檔案 → tools/manifest.json" -f $hashTargets.Count)
        return
    }

    if (-not (Test-Path -LiteralPath $manifestPath)) {
        Add-Result -Name 'Manifest 存在' -Ok $false -Detail '找不到 tools/manifest.json（用 -WriteManifest 產生）'
        return
    }

    $manifest = Read-TextFile -FullPath $manifestPath | ConvertFrom-Json
    $recorded = @{}
    $dupes = @()
    foreach ($e in $manifest.files) {
        if ($recorded.ContainsKey($e.path)) { $dupes += $e.path }
        $recorded[$e.path] = "$($e.sha256)".ToLowerInvariant()
    }

    Add-Result -Name 'Manifest 無重複路徑' -Ok ($dupes.Count -eq 0) -Detail $(if ($dupes.Count) { $dupes -join '、' } else { "$($recorded.Count) 筆" })

    $mismatch = @()
    $unregistered = @()
    foreach ($f in $hashTargets) {
        if (-not $recorded.ContainsKey($f)) { $unregistered += $f; continue }
        if ($recorded[$f] -ne $expected[$f]) { $mismatch += $f }
    }
    $stale = @($recorded.Keys | Where-Object { $hashTargets -notcontains $_ })

    Add-Result -Name 'Manifest hash 一致（漂移偵測）' -Ok ($mismatch.Count -eq 0) -Detail $(if ($mismatch.Count) { '內容已改但 manifest 未更新：' + ($mismatch -join '、') } else { "逐一比對 $($hashTargets.Count) 個檔案" })
    Add-Result -Name '所有入版控檔案已登記' -Ok ($unregistered.Count -eq 0) -Detail $(if ($unregistered.Count) { $unregistered -join '、' } else { 'OK' })
    Add-Result -Name 'Manifest 無已刪除檔案' -Ok ($stale.Count -eq 0) -Detail $(if ($stale.Count) { $stale -join '、' } else { 'OK' })
}

# ── 執行 ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "=== FYP 驗證（Stage $Stage） ===" -ForegroundColor Cyan
Write-Host "根目錄：$root" -ForegroundColor DarkGray

$head = (git -C $root rev-parse --short HEAD 2>$null)
Write-Host "git HEAD：$head" -ForegroundColor DarkGray
Write-Host ""

# Stage A
foreach ($doc in @('agent.md', 'README.md')) { Test-TextHygiene -RelPath $doc }
foreach ($script in @('tools/verify.ps1')) { Test-TextHygiene -RelPath $script }
Test-AgentRules

# Stage B
if ($Stage -eq 'B' -or $Stage -eq 'D' -or $WriteManifest) {
    Test-Consistency
    Test-Manifest
}

# Stage D
if ($Stage -eq 'D') { Test-MilestoneContent }

# ── 總結與記錄 ──────────────────────────────────────────────────────────────
$failed = @($results | Where-Object { -not $_.Ok })
$passed = @($results | Where-Object { $_.Ok })
$verdict = if ($failed.Count -eq 0) { 'PASS' } else { 'FAIL' }
$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

$fileHashes = @()
foreach ($f in @(Get-TrackedFile)) {
    $h = Get-Utf8Hash (Read-TextFile -FullPath (Join-Path $root ($f -replace '/', '\')))
    $fileHashes += ("  {0}  {1}" -f $h, $f)
}

$lines = @()
$lines += 'FYP 驗證記錄'
$lines += "時間：$stamp"
$lines += "Stage：$Stage"
$lines += "git HEAD：$head"
$lines += "說明：$Note"
$lines += ''
$lines += '檢查結果：'
foreach ($r in $results) {
    $lines += ("  [{0}] {1}{2}" -f $(if ($r.Ok) { 'PASS' } else { 'FAIL' }), $r.Check, $(if ($r.Detail) { " -- $($r.Detail)" } else { '' }))
}
$lines += ''
$lines += '檔案 SHA-256（UTF-8 內容）：'
$lines += $fileHashes
$lines += ''
$lines += ("RESULT: {0}（PASS {1} / FAIL {2}）" -f $verdict, $passed.Count, $failed.Count)

if (-not (Test-Path -LiteralPath $reportDir)) { New-Item -ItemType Directory -Path $reportDir -Force | Out-Null }
$stampFile = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportPath = Join-Path $reportDir "verify-$Stage-$stampFile.txt"
[System.IO.File]::WriteAllLines($reportPath, $lines, $utf8NoBom)
[System.IO.File]::WriteAllLines((Join-Path $reportDir 'verify-latest.txt'), $lines, $utf8NoBom)

Write-Host ""
Write-Host ("RESULT: {0}（PASS {1} / FAIL {2}）" -f $verdict, $passed.Count, $failed.Count) -ForegroundColor $(if ($verdict -eq 'PASS') { 'Green' } else { 'Red' })
Write-Host "記錄：_reports/$(Split-Path -Leaf $reportPath)" -ForegroundColor DarkGray
Write-Host ""

if ($failed.Count -gt 0) { exit 1 }
exit 0
