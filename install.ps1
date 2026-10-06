[CmdletBinding()]
param(
    [string]$TargetDir = (Join-Path $HOME '.codex\skills\CN_job-requirement-fit-analysis'),
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SourceDir = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSCommandPath))
$RequiredFiles = @(
    '.gitignore',
    'AGENTS.md',
    'LICENSE',
    'README.md',
    'SKILL.md',
    'references\CAMPUS-HIRING.md',
    'references\EXPERIENCED-HIRING.md',
    'references\INTERNSHIP-HIRING.md',
    'references\ISOLATED-EVALUATOR-PROTOCOL.md',
    'docs\DEVELOPMENT.md',
    'docs\RECRUITMENT-MODE-RULES.md',
    'docs\SPECIFICATION.md'
)

function Get-NormalizedPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw 'TargetDir must not be empty.'
    }
    return [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
}

function Assert-SafeTarget {
    param([Parameter(Mandatory = $true)][string]$Path)

    $fullPath = Get-NormalizedPath $Path
    $homePath = Get-NormalizedPath $HOME
    $sourcePath = Get-NormalizedPath $SourceDir
    $sourceParent = Get-NormalizedPath (Split-Path -Parent $SourceDir)
    $root = [System.IO.Path]::GetPathRoot($fullPath).TrimEnd('\', '/')

    if ($fullPath -eq $root -or $fullPath -eq $homePath -or
        $fullPath -eq $sourcePath -or $fullPath -eq $sourceParent) {
        throw "Refusing unsafe target directory: $fullPath"
    }

    if ((Test-Path -LiteralPath $fullPath) -and -not (Get-Item -LiteralPath $fullPath).PSIsContainer) {
        throw "Target exists but is not a directory: $fullPath"
    }

    $existingPath = $fullPath
    while (-not (Test-Path -LiteralPath $existingPath)) {
        $parent = Split-Path -Parent $existingPath
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $existingPath) {
            break
        }
        $existingPath = $parent
    }

    while ($true) {
        $item = Get-Item -Force -LiteralPath $existingPath
        if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Refusing target path that traverses a symlink or junction: $fullPath"
        }
        $parent = Split-Path -Parent $existingPath
        if ([string]::IsNullOrEmpty($parent) -or $parent -eq $existingPath) {
            break
        }
        $existingPath = $parent
    }
    return $fullPath
}

function Assert-RequiredFiles {
    param([Parameter(Mandatory = $true)][string]$Root)

    foreach ($relativePath in $RequiredFiles) {
        $candidate = Join-Path $Root $relativePath
        if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            throw "Required payload file is missing: $relativePath"
        }
    }
}

function Assert-Payload {
    param([Parameter(Mandatory = $true)][string]$Root)

    Assert-RequiredFiles $Root

    foreach ($forbidden in @('.git', '.github', 'runs', 'cases', 'evaluation')) {
        if (Test-Path -LiteralPath (Join-Path $Root $forbidden)) {
            throw "Forbidden development artifact found in payload: $forbidden"
        }
    }
}

function Assert-HashParity {
    param(
        [Parameter(Mandatory = $true)][string]$Left,
        [Parameter(Mandatory = $true)][string]$Right
    )

    foreach ($relativePath in $RequiredFiles) {
        $leftHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $Left $relativePath)).Hash
        $rightHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $Right $relativePath)).Hash
        if ($leftHash -ne $rightHash) {
            throw "SHA-256 verification failed: $relativePath"
        }
    }
}

function Get-SkillVersion {
    param([Parameter(Mandatory = $true)][string]$Root)
    $match = Select-String -LiteralPath (Join-Path $Root 'SKILL.md') -Pattern '<!-- skill-version: ([^ ]+) -->' | Select-Object -First 1
    if ($null -eq $match) {
        throw 'Skill version marker is missing from SKILL.md.'
    }
    return $match.Matches[0].Groups[1].Value
}

Assert-RequiredFiles $SourceDir
$SourceVersion = Get-SkillVersion $SourceDir
$TargetPath = Assert-SafeTarget $TargetDir
$TargetParent = Split-Path -Parent $TargetPath
$TargetLeaf = Split-Path -Leaf $TargetPath

if (Test-Path -LiteralPath $TargetPath) {
    if (-not $Force) {
        $answer = Read-Host "existing installation found at $TargetPath. Overwrite? [y/N]"
        if ([string]$answer -notmatch '^(?i:y|yes)$') {
            Write-Host 'Installation cancelled.'
            exit 0
        }
    }
}

New-Item -ItemType Directory -Force -Path $TargetParent | Out-Null
$nonce = [Guid]::NewGuid().ToString('N')
$StagingPath = Join-Path $TargetParent ".${TargetLeaf}.staging.$PID.$nonce"
$BackupPath = Join-Path $TargetParent ".${TargetLeaf}.backup.$PID.$nonce"
$hadExistingTarget = $false
$activatedTarget = $false

try {
    New-Item -ItemType Directory -Path $StagingPath | Out-Null
    foreach ($relativePath in $RequiredFiles) {
        $destination = Join-Path $StagingPath $relativePath
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath (Join-Path $SourceDir $relativePath) -Destination $destination
    }

    Assert-Payload $StagingPath
    Assert-HashParity $SourceDir $StagingPath

    $hadExistingTarget = Test-Path -LiteralPath $TargetPath
    if ($hadExistingTarget) {
        Move-Item -LiteralPath $TargetPath -Destination $BackupPath
    }

    try {
        Move-Item -LiteralPath $StagingPath -Destination $TargetPath
        $activatedTarget = $true
        Assert-Payload $TargetPath
        Assert-HashParity $SourceDir $TargetPath
        $version = Get-SkillVersion $TargetPath
        if ($version -ne $SourceVersion) {
            throw 'Installed version marker does not match source payload.'
        }
    }
    catch {
        if ($activatedTarget -and (Test-Path -LiteralPath $TargetPath)) {
            Remove-Item -LiteralPath $TargetPath -Recurse -Force
        }
        if ($hadExistingTarget -and -not (Test-Path -LiteralPath $TargetPath) -and (Test-Path -LiteralPath $BackupPath)) {
            Move-Item -LiteralPath $BackupPath -Destination $TargetPath
        }
        throw
    }

    if (Test-Path -LiteralPath $BackupPath) {
        Remove-Item -LiteralPath $BackupPath -Recurse -Force
    }

    Write-Host "CN_job-requirement-fit-analysis $version installed successfully"
    Write-Host "Source: $SourceDir"
    Write-Host "Target: $TargetPath"
    Write-Host "Files installed: $($RequiredFiles.Count)"
    Write-Host 'Integrity: PASS'
    Write-Host 'INSTALL_SUCCESS'
}
catch {
    if (Test-Path -LiteralPath $StagingPath) {
        Remove-Item -LiteralPath $StagingPath -Recurse -Force
    }
    Write-Error "INSTALL_FAILED: $($_.Exception.Message)"
    exit 1
}
