#PS_BEGIN
# Zelda Ocarina of Time 2026 Remake Save Editor - local helper
# Author: Ernani Zanandrea Dalzotto - https://github.com/ezdalzotto
# Modifications are allowed as long as credit is given to the author.
#
# Serves the editor on http://127.0.0.1 and reads/writes the game's save files
# (progress.sav, caption.sav, option.sav). Browsers cannot write inside AppData, this helper can.
$ErrorActionPreference = 'Stop'
try { $Host.UI.RawUI.WindowTitle = 'Zelda Ocarina of Time 2026 Remake Save Editor v1.0 - keep this window open' } catch { }

$self = $env:OOT_SELF
$raw = [IO.File]::ReadAllText($self, [Text.Encoding]::UTF8)
$marker = '#HTML' + '_BEGIN'
$htmlStart = $raw.IndexOf($marker, [StringComparison]::Ordinal)
if ($htmlStart -lt 0) { throw 'Editor file is incomplete (HTML not found).' }
$htmlBytes = [Text.Encoding]::UTF8.GetBytes($raw.Substring($htmlStart + $marker.Length))

$titleId = '0400486024DEC000'
$relPattern = '^([A-Za-z0-9_\-]+/){0,2}(progress|caption|option)\.sav$'
$roots = New-Object System.Collections.ArrayList
$emulators = @('eden', 'fritchii', 'yuzu', 'suyu', 'sudachi', 'citron', 'torzu')

function Get-DownloadsDir {
  $d = $null
  try { $d = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders' -ErrorAction Stop).'{374DE290-123F-4565-9164-39C4925E467B}' } catch { }
  if (-not $d -or -not (Test-Path -LiteralPath $d -PathType Container)) { $d = Join-Path $env:USERPROFILE 'Downloads' }
  return $d
}
$backupDir = Join-Path (Get-DownloadsDir) 'Zelda OoT Save Editor - Backups'

function Find-Roots {
  foreach ($emu in $emulators) {
    foreach ($baseDir in @($env:APPDATA, $env:LOCALAPPDATA)) {
      if (-not $baseDir) { continue }
      $base = Join-Path $baseDir ($emu + '\nand\user\save\0000000000000000')
      if (-not (Test-Path -LiteralPath $base -PathType Container)) { continue }
      foreach ($u in @(Get-ChildItem -LiteralPath $base -Directory -ErrorAction SilentlyContinue)) {
        $g = Join-Path $u.FullName $titleId
        if ((Test-Path -LiteralPath $g -PathType Container) -and -not ($roots -contains $g)) { [void]$roots.Add($g) }
      }
    }
  }
}

function JStr([string]$s) {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('"')
  foreach ($ch in $s.ToCharArray()) {
    $c = [int]$ch
    if ($c -eq 34) { [void]$sb.Append('\"') }
    elseif ($c -eq 92) { [void]$sb.Append('\\') }
    elseif ($c -lt 32) { [void]$sb.Append('\u' + $c.ToString('x4')) }
    else { [void]$sb.Append($ch) }
  }
  [void]$sb.Append('"')
  return $sb.ToString()
}

function Root-Label([string]$g) {
  $user = Split-Path -Leaf (Split-Path -Parent $g)
  $emu = ''
  foreach ($e in $emulators) { if ($g -match ('\\' + $e + '\\')) { $emu = $e; break } }
  if (-not $emu) { return $g }
  if ($user.Length -gt 8) { $user = $user.Substring(0, 8) + '...' }
  return ($emu + ' - ' + $user)
}

function Scan-Json {
  $items = @()
  foreach ($g in $roots) {
    $newest = ''
    try { $f = @(Get-ChildItem -LiteralPath $g -Recurse -Depth 2 -File -Filter 'progress.sav' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending); if ($f.Count -gt 0) { $newest = $f[0].LastWriteTime.ToString('yyyy-MM-dd HH:mm') } } catch { }
    $items += ('{"path":' + (JStr $g) + ',"label":' + (JStr (Root-Label $g)) + ',"newest":' + (JStr $newest) + '}')
  }
  return ('{"helper":3,"dirs":[' + ($items -join ',') + '],"backupDir":' + (JStr $backupDir) + '}')
}

function Get-Root([string]$r) {
  foreach ($x in $roots) { if ($x -eq $r) { return $x } }
  throw 'Folder not allowed.'
}

function Get-SafePath([string]$root, [string]$rel) {
  if ($rel -notmatch $relPattern) { throw 'Invalid path.' }
  return (Join-Path $root ($rel -replace '/', '\'))
}

# Accepts a save folder, a slot folder or the progress.sav file itself.
function Add-Root([string]$p) {
  $p = [Environment]::ExpandEnvironmentVariables($p.Trim().Trim('"')).TrimEnd('\')
  if (Test-Path -LiteralPath $p -PathType Leaf) { $p = Split-Path -Parent $p }
  if (-not (Test-Path -LiteralPath $p -PathType Container)) { throw ('Folder not found: ' + $p) }
  $p = (Get-Item -LiteralPath $p).FullName.TrimEnd('\')
  if ((Split-Path -Leaf $p) -match '^slot_\d+$') { $p = Split-Path -Parent $p }
  $found = @(Get-ChildItem -LiteralPath $p -Recurse -Depth 2 -File -Filter 'progress.sav' -ErrorAction SilentlyContinue)
  if ($found.Count -eq 0) { throw ('No progress.sav found in this folder or its subfolders: ' + $p) }
  if (-not ($roots -contains $p)) { [void]$roots.Add($p) }
  return $p
}

function List-Json([string]$root) {
  $rootFull = (Get-Item -LiteralPath $root).FullName.TrimEnd('\')
  $items = @()
  foreach ($f in @(Get-ChildItem -LiteralPath $root -Recurse -Depth 2 -File -ErrorAction SilentlyContinue)) {
    if ($f.Length -gt 4MB) { continue }
    $rel = $f.FullName.Substring($rootFull.Length + 1) -replace '\\', '/'
    if ($rel -notmatch $relPattern) { continue }
    $items += ('{"rel":' + (JStr $rel) + ',"size":' + $f.Length + '}')
  }
  return ('{"files":[' + ($items -join ',') + ']}')
}

function Hash-Bytes([byte[]]$b) {
  $sha = [Security.Cryptography.SHA256]::Create()
  try { return [BitConverter]::ToString($sha.ComputeHash($b)) } finally { $sha.Dispose() }
}

function New-BatchId { return (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss') }

# Copies the current file into the backup folder (once per batch), then writes and verifies the new data.
function Write-SaveFile([string]$root, [string]$rel, [byte[]]$data, [string]$batch) {
  $full = Get-SafePath $root $rel
  if ($data.Length -lt 48 -or $data[0] -ne 4 -or $data[1] -ne 3 -or $data[2] -ne 2 -or $data[3] -ne 1) { throw 'The data is not a valid save file.' }
  $batchDir = Join-Path $backupDir $batch
  $bk = ''
  if (Test-Path -LiteralPath $full -PathType Leaf) {
    $bk = Join-Path $batchDir ($rel -replace '/', '\')
    if (-not (Test-Path -LiteralPath $bk)) {
      [void](New-Item -ItemType Directory -Force -Path (Split-Path -Parent $bk))
      Copy-Item -LiteralPath $full -Destination $bk -Force
      $rootFile = Join-Path $batchDir '_folder.txt'
      if (-not (Test-Path -LiteralPath $rootFile)) { [IO.File]::WriteAllText($rootFile, $root, [Text.Encoding]::UTF8) }
    }
  }
  $tmp = $full + '.editor-tmp'
  [IO.File]::WriteAllBytes($tmp, $data)
  [IO.File]::Copy($tmp, $full, $true)
  Remove-Item -LiteralPath $tmp -Force
  if ((Hash-Bytes ([IO.File]::ReadAllBytes($full))) -ne (Hash-Bytes $data)) { throw ('Verification failed after writing ' + $full) }
  Write-Host ('  Saved: ' + $full)
  return @{ Full = $full; Backup = $bk }
}

function Backups-Json([string]$root) {
  $items = @()
  if (Test-Path -LiteralPath $backupDir -PathType Container) {
    foreach ($d in @(Get-ChildItem -LiteralPath $backupDir -Directory | Sort-Object Name -Descending | Select-Object -First 80)) {
      $rf = Join-Path $d.FullName '_folder.txt'
      $owner = ''
      if (Test-Path -LiteralPath $rf) { $owner = [IO.File]::ReadAllText($rf, [Text.Encoding]::UTF8).Trim() }
      if ($owner -and $owner -ne $root) { continue }
      $base = $d.FullName.TrimEnd('\')
      $files = @()
      foreach ($f in @(Get-ChildItem -LiteralPath $d.FullName -Recurse -File)) {
        $rel = $f.FullName.Substring($base.Length + 1) -replace '\\', '/'
        if ($rel -match $relPattern) { $files += (JStr $rel) }
      }
      if ($files.Count -gt 0) { $items += ('{"id":' + (JStr $d.Name) + ',"files":[' + ($files -join ',') + ']}') }
    }
  }
  return ('{"dir":' + (JStr $backupDir) + ',"backups":[' + ($items -join ',') + ']}')
}

function Status-Json {
  $items = @()
  foreach ($pr in @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match '^(eden|fritchii|yuzu|suyu|sudachi|citron|torzu)' })) {
    $title = ''
    try { $title = [string]$pr.MainWindowTitle } catch { }
    $g = 'false'
    if ($title -match 'zelda|ocarina|0400486024DEC000') { $g = 'true' }
    $items += ('{"name":' + (JStr $pr.ProcessName) + ',"title":' + (JStr $title) + ',"game":' + $g + '}')
  }
  return ('{"emulators":[' + ($items -join ',') + ']}')
}

function Files-Json([string]$root) {
  $rootFull = (Get-Item -LiteralPath $root).FullName.TrimEnd('\')
  $items = @()
  foreach ($f in @(Get-ChildItem -LiteralPath $root -Recurse -Depth 4 -File -Force -ErrorAction SilentlyContinue | Select-Object -First 400)) {
    $rel = $f.FullName.Substring($rootFull.Length + 1) -replace '\\', '/'
    $items += ('{"rel":' + (JStr $rel) + ',"size":' + $f.Length + ',"mtime":' + (JStr $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')) + '}')
  }
  return ('{"files":[' + ($items -join ',') + ']}')
}

function Browse-ForSave {
  Add-Type -AssemblyName System.Windows.Forms
  $owner = New-Object System.Windows.Forms.Form
  $owner.TopMost = $true
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Title = 'Select progress.sav (inside slot_00, slot_01, ...)'
  $dlg.Filter = 'progress.sav|progress.sav|Save files (*.sav)|*.sav'
  $init = Join-Path $env:APPDATA 'eden\nand\user\save\0000000000000000'
  if (Test-Path -LiteralPath $init) { $dlg.InitialDirectory = $init }
  try { $r = $dlg.ShowDialog($owner) } finally { $owner.Dispose() }
  if ($r -ne [System.Windows.Forms.DialogResult]::OK) { return '' }
  return $dlg.FileName
}

function Parse-Query([string]$q) {
  $h = @{}
  foreach ($kv in $q.Split('&')) {
    if (-not $kv) { continue }
    $i = $kv.IndexOf('=')
    if ($i -lt 0) { $h[[Uri]::UnescapeDataString($kv)] = '' }
    else { $h[[Uri]::UnescapeDataString($kv.Substring(0, $i))] = [Uri]::UnescapeDataString($kv.Substring($i + 1).Replace('+', ' ')) }
  }
  return $h
}

function Read-Request($stream) {
  $buf = New-Object byte[] 65536
  $ms = New-Object System.IO.MemoryStream
  $idx = -1
  $txt = ''
  while ($idx -lt 0) {
    $n = $stream.Read($buf, 0, $buf.Length)
    if ($n -le 0) { return $null }
    $ms.Write($buf, 0, $n)
    $txt = [Text.Encoding]::ASCII.GetString($ms.GetBuffer(), 0, [int]$ms.Length)
    $idx = $txt.IndexOf("`r`n`r`n", [StringComparison]::Ordinal)
    if ($idx -lt 0 -and $ms.Length -gt 65536) { return $null }
  }
  $lines = $txt.Substring(0, $idx) -split "`r`n"
  $parts = $lines[0].Split(' ')
  if ($parts.Length -lt 2) { return $null }
  $hdrs = @{}
  for ($i = 1; $i -lt $lines.Length; $i++) {
    $c = $lines[$i].IndexOf(':')
    if ($c -gt 0) { $hdrs[$lines[$i].Substring(0, $c).Trim().ToLower()] = $lines[$i].Substring($c + 1).Trim() }
  }
  $len = 0
  if ($hdrs.ContainsKey('content-length')) { $len = [int]$hdrs['content-length'] }
  if ($len -lt 0 -or $len -gt 8MB) { return $null }
  $all = $ms.ToArray()
  $start = $idx + 4
  $body = New-Object byte[] $len
  $have = [Math]::Min($all.Length - $start, $len)
  if ($have -gt 0) { [Array]::Copy($all, $start, $body, 0, $have) } else { $have = 0 }
  while ($have -lt $len) {
    $n = $stream.Read($body, $have, $len - $have)
    if ($n -le 0) { break }
    $have += $n
  }
  return @{ Method = $parts[0]; Target = $parts[1]; Headers = $hdrs; Body = $body }
}

function Send-Resp($stream, [string]$status, [string]$ctype, [byte[]]$body) {
  if ($null -eq $body) { $body = New-Object byte[] 0 }
  $head = 'HTTP/1.1 ' + $status + "`r`nContent-Type: " + $ctype + "`r`nContent-Length: " + $body.Length + "`r`nCache-Control: no-store`r`nX-Content-Type-Options: nosniff`r`nConnection: close`r`n`r`n"
  $hb = [Text.Encoding]::ASCII.GetBytes($head)
  $stream.Write($hb, 0, $hb.Length)
  if ($body.Length -gt 0) { $stream.Write($body, 0, $body.Length) }
  $stream.Flush()
}
function Send-Json($stream, [string]$json) { Send-Resp $stream '200 OK' 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes($json)) }
function Send-Text($stream, [string]$status, [string]$text) { Send-Resp $stream $status 'text/plain; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes($text)) }

function Handle-Request($stream, $req) {
  $target = $req.Target
  $q = ''
  $qi = $target.IndexOf('?', [StringComparison]::Ordinal)
  if ($qi -ge 0) { $q = $target.Substring($qi + 1); $target = $target.Substring(0, $qi) }

  if ($target -eq '/' -or $target -eq '/index.html') { Send-Resp $stream '200 OK' 'text/html; charset=utf-8' $htmlBytes; return }
  if (-not $target.StartsWith('/api/', [StringComparison]::Ordinal)) { Send-Text $stream '404 Not Found' 'Not found'; return }
  # The token travels in a custom header, which other websites cannot send to this address.
  if ($req.Headers['x-token'] -ne $token) { Send-Text $stream '403 Forbidden' 'Invalid token. Open the editor with the .bat file.'; return }
  $qs = Parse-Query $q
  $post = ($req.Method -eq 'POST')

  if ($target -eq '/api/scan') {
    Find-Roots
    Send-Json $stream (Scan-Json)
  }
  elseif ($target -eq '/api/addroot' -and $post) {
    $p = Add-Root ([Text.Encoding]::UTF8.GetString($req.Body))
    Send-Json $stream ('{"root":' + (JStr $p) + ',"scan":' + (Scan-Json) + '}')
  }
  elseif ($target -eq '/api/browse' -and $post) {
    $file = Browse-ForSave
    if (-not $file) { Send-Json $stream '{"root":""}'; return }
    $p = Add-Root $file
    Send-Json $stream ('{"root":' + (JStr $p) + ',"scan":' + (Scan-Json) + '}')
  }
  elseif ($target -eq '/api/status') {
    Send-Json $stream (Status-Json)
  }
  elseif ($target -eq '/api/files') {
    Send-Json $stream (Files-Json (Get-Root $qs['root']))
  }
  elseif ($target -eq '/api/list') {
    Send-Json $stream (List-Json (Get-Root $qs['root']))
  }
  elseif ($target -eq '/api/read') {
    $full = Get-SafePath (Get-Root $qs['root']) $qs['rel']
    Send-Resp $stream '200 OK' 'application/octet-stream' ([IO.File]::ReadAllBytes($full))
  }
  elseif ($target -eq '/api/write' -and $post) {
    $batch = $qs['batch']
    if ($batch -notmatch '^[0-9_\-]{8,40}$') { throw 'Invalid batch id.' }
    $r = Write-SaveFile (Get-Root $qs['root']) $qs['rel'] $req.Body $batch
    Send-Json $stream ('{"ok":true,"path":' + (JStr $r.Full) + ',"backup":' + (JStr $r.Backup) + '}')
  }
  elseif ($target -eq '/api/backups') {
    Send-Json $stream (Backups-Json (Get-Root $qs['root']))
  }
  elseif ($target -eq '/api/restore' -and $post) {
    $root = Get-Root $qs['root']
    $id = $qs['id']
    if ($id -notmatch '^[0-9_\-]{8,40}$') { throw 'Invalid backup id.' }
    $src = Join-Path $backupDir $id
    if (-not (Test-Path -LiteralPath $src -PathType Container)) { throw 'Backup not found.' }
    $base = (Get-Item -LiteralPath $src).FullName.TrimEnd('\')
    $batch = (New-BatchId) + '_00'
    $n = 0
    foreach ($f in @(Get-ChildItem -LiteralPath $src -Recurse -File)) {
      $rel = $f.FullName.Substring($base.Length + 1) -replace '\\', '/'
      if ($rel -notmatch $relPattern) { continue }
      [void](Write-SaveFile $root $rel ([IO.File]::ReadAllBytes($f.FullName)) $batch)
      $n++
    }
    Send-Json $stream ('{"ok":true,"files":' + $n + '}')
  }
  elseif ($target -eq '/api/openbackups' -and $post) {
    [void](New-Item -ItemType Directory -Force -Path $backupDir)
    Start-Process explorer.exe -ArgumentList ('"' + $backupDir + '"')
    Send-Json $stream '{"ok":true}'
  }
  else { Send-Text $stream '404 Not Found' 'Not found' }
}

try {
  $token = [Guid]::NewGuid().ToString('N')
  $listener = $null
  $port = 0
  foreach ($p in 47123..47150) {
    try {
      $l = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $p)
      $l.Start()
      $listener = $l
      $port = $p
      break
    } catch { }
  }
  if ($null -eq $listener) { throw 'Could not open a local port (47123-47150).' }
  Find-Roots
  $url = 'http://127.0.0.1:' + $port + '/#t=' + $token
  Write-Host ''
  Write-Host '  Zelda Ocarina of Time 2026 Remake Save Editor v1.0'
  Write-Host '  by Ernani Zanandrea Dalzotto - https://github.com/ezdalzotto'
  Write-Host '  ------------------------------------------------------------'
  Write-Host ('  Save folders found: ' + $roots.Count)
  foreach ($g in $roots) { Write-Host ('    ' + $g) }
  Write-Host ('  Backups: ' + $backupDir)
  Write-Host ''
  Write-Host '  The editor is open in your browser. If it did not open, copy this address:'
  Write-Host ('  ' + $url)
  Write-Host ''
  Write-Host '  Close the game before saving. Close this window to quit the editor.'
  Write-Host '  (Feche o jogo antes de salvar. Feche esta janela para encerrar o editor.)'
  Write-Host ''
  Start-Process $url

  while ($true) {
    $client = $listener.AcceptTcpClient()
    $stream = $null
    try {
      $client.ReceiveTimeout = 2000
      $client.SendTimeout = 10000
      $stream = $client.GetStream()
      $req = Read-Request $stream
      if ($null -ne $req) { Handle-Request $stream $req }
    } catch {
      $m = $_.Exception.Message
      if ($null -ne $stream) { try { Send-Text $stream '500 Internal Server Error' $m } catch { } }
    } finally {
      $client.Close()
    }
  }
} catch {
  Write-Host ''
  Write-Host ('  ERROR: ' + $_.Exception.Message)
  Write-Host ''
  Read-Host '  Press Enter to exit'
}
#PS_END
