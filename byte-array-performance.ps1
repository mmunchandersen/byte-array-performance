
$picturesPath = "$PSScriptRoot\pictures"
$numberOfTestRuns = 3

Clear-Host

$psVersion = $PSVersionTable.PSVersion
$pictures = Get-ChildItem -Path "$picturesPath\*" -Include *.jpg

if ($pictures.Count -eq 0) {
    Write-Output "No jpg pictures in $picturesPath"
} else {

    Write-Output "Running $numberOfTestRuns test runs on $($pictures.Count) picture(s). PS version: $($psVersion.Major)"

    for ($i = 1; $i -le $numberOfTestRuns; $i++) {

        if ($psVersion.Major -eq 5) {

            $GetContentResult = Measure-Command -Expression {
                foreach ($picture in $pictures) {
                    [byte[]]$bytes1 = Get-Content $picture.FullName -Encoding byte
                }
            }

            $GetContentRawResult = Measure-Command -Expression {
                foreach ($picture in $pictures) {
                    [byte[]]$bytes3 = Get-Content $picture.FullName -Raw -Encoding byte
                }
            }

            $SystemIOStreamResults = Measure-Command -Expression {
                foreach ($picture in $pictures) {
                    [System.IO.Stream]$Stream = [System.IO.File]::OpenRead($picture.FullName)
                    try {
                        [byte[]]$bytes2 = New-Object byte[] $Stream.length
                        [void] $Stream.Read($bytes2, 0, $Stream.Length)
                    } finally {
                        $Stream.Close()
                    }
                }
            }

        } elseif ($psVersion.Major -eq 7) {

            $GetContentResult = Measure-Command -Expression {
                foreach ($picture in $pictures) {
                    [byte[]]$bytes1 = Get-Content $picture.FullName -AsByteStream
                }
            }

            $GetContentRawResult = Measure-Command -Expression {
                foreach ($picture in $pictures) {
                    [byte[]]$bytes3 = Get-Content $picture.FullName -Raw -AsByteStream
                }
            }

            $SystemIOStreamResults = Measure-Command -Expression {
                foreach ($picture in $pictures) {
                    [System.IO.Stream]$Stream = [System.IO.File]::OpenRead($picture.FullName)
                    try {
                        [byte[]]$bytes2 = New-Object byte[] $Stream.length
                        [void] $Stream.Read($bytes2, 0, $Stream.Length)
                    } finally {
                        $Stream.Close()
                    }
                }
            }
        }

        $output = [PSCustomObject][ordered]@{
            Iteration      = "Test $i"
            GetContent     = $GetContentResult.TotalSeconds
            GetContentRaw  = $GetContentRawResult.TotalSeconds
            SystemIoStream = $SystemIOStreamResults.TotalSeconds
        }

        Write-Output $output

    }
}

# inspiration: https://jeffbrown.tech/measuring-performance-in-powershell/