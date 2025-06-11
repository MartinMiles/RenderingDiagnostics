<#
.SYNOPSIS
    Download a page and parse Sitecore debug comments into a JSON hierarchy.

.DESCRIPTION
    Scans a Sitecore-rendered HTML page for <!-- start-component='…' --> and <!-- end-component='…' -->
    markers, extracts metadata (name, id, uid, placeholder, path), and reconstructs a nested
    component-to-placeholder tree. Strict UID matching ensures proper pairing of start/end tags,
    while allowing the root layout to remain on the stack at the end.

.PARAMETER Url
    The page URL to download and parse. Defaults to the local Habitat example.

.PARAMETER OutputPath
    Optional. File path to write the resulting JSON. If omitted, JSON is written to the console.

.EXAMPLE
    # Default URL, output to console
    .\Get-PlaceholdersStructure.ps1

.EXAMPLE
    # Custom URL, output to file
    .\Get-PlaceholdersStructure.ps1 -Url "http://example.com" -OutputPath "page.json"
#>
param(
    [Parameter(Mandatory=$false)]
    [string]$Url = 'http://platform.dev.local/',
    [Parameter(Mandatory=$false)]
    [string]$OutputPath
)

# Download HTML with timeout
try {
    Write-Host "Downloading HTML from $Url"
    $req = [System.Net.HttpWebRequest]::Create($Url)
    $req.Timeout = 10000
    $res = $req.GetResponse()
    $reader = New-Object System.IO.StreamReader($res.GetResponseStream())
    $content = $reader.ReadToEnd()
    $reader.Close(); $res.Close()
} catch {
    Write-Error "Error downloading '$Url': $_"
    exit 1
}

# Capture component markers
$pattern = "<!--\s*(start-component|end-component)\s*=\s*'(?<json>\{.*?\})'\s*-->"
$matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
if ($matches.Count -eq 0) {
    Write-Error "No component markers found."
    exit 1
}

# Parse JSON-like component metadata
function Convert-ComponentStringToObject {
    param([string]$str)
    $json = $str -replace '(\w+)\s*:', '"$1":'
    try { return $json | ConvertFrom-Json -ErrorAction Stop } catch { throw "Invalid metadata JSON: $str" }
}

# Define root layout signature
$rootUid = '00000000-0000-0000-0000-000000000000'
$rootPlaceholder = ''
$rootName = 'Default'

# Build hierarchy using strict UID matching
$stack = @()
$root = $null
foreach ($m in $matches) {
    $type = $m.Groups[1].Value
    $rawJson = $m.Groups['json'].Value
    $meta = Convert-ComponentStringToObject $rawJson
    $isRoot = ($meta.uid -eq $rootUid -and $meta.placeholder -eq $rootPlaceholder -and $meta.name -eq $rootName)

    if ($type -eq 'start-component') {
        # Create new node
        $node = [PSCustomObject]@{
            name = $meta.name
            id = $meta.id
            uid = $meta.uid
            placeholder = $meta.placeholder
            path = $meta.path
            placeholders = @{}
        }
        if (-not $root) {
            # First start defines root
            $root = $node
        } else {
            # Add to parent placeholders
            $parent = $stack[-1]
            $ph = $meta.placeholder
            if (-not $parent.placeholders.ContainsKey($ph)) {
                $parent.placeholders[$ph] = @()
            }
            $parent.placeholders[$ph] += $node
        }
        # Always push for matching (including root)
        $stack += $node
    } else {
        # end-component
        if ($isRoot) {
            # ignore root end, but do not pop
            continue
        }
        if (-not $stack) { throw "End without matching start (UID: $($meta.uid))" }
        $top = $stack[-1]
        if ($top.uid -ne $meta.uid) { throw "UID mismatch: expected '$($top.uid)', got '$($meta.uid)'" }
        # Pop matched node
        $stack = $stack[0..($stack.Count-2)]
    }
}

# Only root may remain unmatched
if ($stack.Count -gt 1) {
    Write-Error "Unmatched components remain after parsing:"
    foreach ($n in $stack[0..($stack.Count-2)]) { Write-Error " - $($n.name) [UID: $($n.uid)]" }
    exit 1
}
if (-not $root) { Write-Error "No root component parsed."; exit 1 }

# Output JSON
$json = $root | ConvertTo-Json -Depth 20
if ($OutputPath) {
    try { $json | Out-File $OutputPath -Encoding UTF8; Write-Host "JSON written to $OutputPath" } catch { Write-Error "Write error: $_"; exit 1 }
} else {
    Write-Output $json
}
