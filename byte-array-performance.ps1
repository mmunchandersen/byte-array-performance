
$picturesPath = "$PSScriptRoot\pictures"
$numberOfTestRuns = 3

Clear-Host


$pictures = Get-ChildItem -Path "$picturesPath\*" -Include *.jpg

Write-Output "Running $numberOfTestRuns test runs on $($pictures.Count) pictures"

for ($i = 1; $i -le $numberOfTestRuns; $i++) {

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

    $output = [PSCustomObject][ordered]@{
        Iteration      = "Test $i"
        GetContent     = $GetContentResult.TotalSeconds
        GetContentRaw  = $GetContentRawResult.TotalSeconds
        SystemIoStream = $SystemIOStreamResults.TotalSeconds
    }

    Write-Output $output

}
# inspiration: https://jeffbrown.tech/measuring-performance-in-powershell/