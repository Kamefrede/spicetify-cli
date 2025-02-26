$curVer = [regex]::Match((Get-Content ".\spicetify.go"), "version = `"([\d\.]*)`"").Captures.Groups[1].Value
Write-Host "Current version: $curVer"

function BumpVersion {
    param (
        [Parameter(Mandatory = $true)][int16]$major,
        [Parameter(Mandatory = $true)][int16]$minor,
        [Parameter(Mandatory = $true)][int16]$patch
    )

    $ver = "$($major).$($minor).$($patch)"

    (Get-Content ".\spicetify.go") -replace "version = `"[\d\.]*`"", "version = `"$($ver)`"" |
        Set-Content ".\spicetify.go"
}

function Dist {
    param (
        [Parameter(Mandatory = $true)][int16]$major,
        [Parameter(Mandatory = $true)][int16]$minor,
        [Parameter(Mandatory = $true)][int16]$patch
    )

    BumpVersion $major $minor $patch

    $nameVersion = "spicetify-$($major).$($minor).$($patch)"
    $env:GOARCH = "amd64"

    if (Test-Path "./bin") {
        Remove-Item -Recurse "./bin"
    }

    Write-Host "Building Linux binary:"
    $env:GOOS = "linux"

    go build -o "./bin/linux/spicetify"

    7z a -bb0 "./bin/linux/$($nameVersion)-linux-amd64.tar" "./bin/linux/*" "./CustomApps" "./Extensions" "./Themes" "./jsHelper" "globals.d.ts" "css-map.json" >$null 2>&1
    7z a -bb0 -sdel -mx9 "./bin/$($nameVersion)-linux-amd64.tar.gz" "./bin/linux/$($nameVersion)-linux-amd64.tar" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green

    Write-Host "Building MacOS binary:"
    $env:GOOS = "darwin"

    go build -o "./bin/darwin/spicetify"

    7z a -bb0 "./bin/darwin/$($nameVersion)-darwin-amd64.tar" "./bin/darwin/*" "./CustomApps" "./Extensions" "./Themes" "./jsHelper" "globals.d.ts" "css-map.json" >$null 2>&1
    7z a -bb0 -sdel -mx9 "./bin/$($nameVersion)-darwin-amd64.tar.gz" "./bin/darwin/$($nameVersion)-darwin-amd64.tar" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green

    Write-Host "Building Windows binary:"
    $env:GOOS = "windows"

    go build -o "./bin/windows/spicetify.exe"

    7z a -bb0 -mx9 "./bin/$($nameVersion)-windows-x64.zip" "./bin/windows/*" "./CustomApps" "./Extensions" "./Themes" "./jsHelper" "globals.d.ts" "css-map.json" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green

    $env:GOARCH = "arm64"

    Write-Host "Building MacOS ARM binary:"
    $env:GOOS = "darwin"

    go build -o "./bin/darwin-arm/spicetify"

    7z a -bb0 "./bin/darwin-arm/$($nameVersion)-darwin-arm64.tar" "./bin/darwin-arm/*" "./CustomApps" "./Extensions" "./Themes" "./jsHelper" "globals.d.ts" "css-map.json" >$null 2>&1
    7z a -bb0 -sdel -mx9 "./bin/$($nameVersion)-darwin-arm64.tar.gz" "./bin/darwin-arm/$($nameVersion)-darwin-arm64.tar" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green
}

function Format {
    prettier --print-width 80 --tab-width 4 --trailing-comma es5 --arrow-parens always --write .\Extensions\*.js
}