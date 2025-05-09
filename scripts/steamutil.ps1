function Get-SteamGameDirectory {
    param (
        [Parameter(Mandatory=$true)]
        [string]$gameId
    )

    Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty "SteamPath" |
    Join-Path -ChildPath "/config/libraryfolders.vdf" |
    ForEach-Object { Get-Content $_ } |
    ForEach-Object {
        $matches = [regex]::Matches($_, '"([^"]*)"')
        if ($matches) {
            $key = $matches[0].Groups[1].Value
            if ($key -eq "path") {
                $value = $matches[1].Groups[1].Value
                $manifestPath = "$value\steamapps\appmanifest_$gameId.acf"
                if (Test-Path $manifestPath) {
                    $libraryPath = $value
                    $manifestPath
                }
            }
        }
    } |
    ForEach-Object { Get-Content $_ } |
    ForEach-Object {
        $matches = [regex]::Matches($_, '"([^"]*)"')
        if ($matches) {
            $key = $matches[0].Groups[1].Value
            if ($key -eq "installdir") {
                $dir = $matches[1].Groups[1].Value
                "$libraryPath\steamapps\common\$dir"
            }
        }
    }
}
