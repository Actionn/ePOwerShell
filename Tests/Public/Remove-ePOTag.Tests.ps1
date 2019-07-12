[System.String]    $ProjectDirectoryName = 'ePOwerShell'
[System.String]    $FunctionType         = 'Public'
[IO.FileInfo]      $PesterFile           = [IO.FileInfo] ([System.String] (Resolve-Path -Path $MyInvocation.MyCommand.Path))
[System.String]    $FunctionName         = $PesterFile.Name.Split('.')[0]
[IO.DirectoryInfo] $ProjectRoot          = Split-Path -Parent $PesterFile.Directory

while (-not ($ProjectRoot.Name -eq $ProjectDirectoryName)) {
    $ProjectRoot = Split-Path -Parent $ProjectRoot.FullName
}

[IO.DirectoryInfo] $ExampleDirectory          = Join-Path (Join-Path -Path $ProjectRoot -ChildPath 'Examples' -Resolve) -ChildPath $FunctionType -Resolve
[IO.DirectoryInfo] $ExampleDirectory          = Join-Path $ExampleDirectory.FullName -ChildPath $FunctionName -Resolve
[IO.DirectoryInfo] $Global:ReferenceDirectory = Join-Path $ExampleDirectory.FullName -ChildPath 'References' -Resolve

$Examples = Get-ChildItem $ExampleDirectory -Filter "*.psd1" -File

$Tests = foreach ($Example in $Examples) {
    [hashtable] $Test = @{
        Name = $Example.BaseName.Split('.')[1]
    }

    Write-Verbose "Test: $($Test | ConvertTo-Json)"

    foreach ($ExampleData in (Import-PowerShellDataFile -LiteralPath $Example.FullName).GetEnumerator()) {
        $Test.Add($ExampleData.Name, $ExampleData.Value) | Out-Null
    }

    Write-Verbose "Test: $($Test | ConvertTo-Json)"
    Write-Output $Test
}

Describe $FunctionName {
    foreach ($Global:Test in $Tests) {
        InModuleScope ePOwerShell {
            Mock Invoke-ePORequest {
                if (-not ($ComputerFile = Get-ChildItem $ReferenceDirectory.FullName -Filter ('{0}.html' -f $Query.names))) {
                    Throw "Error 1: Invalid computername"
                }

                if (-not ($TagFile = Get-ChildItem $ReferenceDirectory.FullName -Filter ('{0}.html' -f $Query.tagName))) {
                    Throw "Error 1: Invalid tag"
                }

                $Computer = (Get-Content $ComputerFile.FullName | Out-String).Substring(3).Trim() | ConvertFrom-Json
                $Tag = (Get-Content $TagFile.FullName | Out-String).Substring(3).Trim() | ConvertFrom-Json

                if ($Test.Unknown) {
                    return 4
                } elseif (-not ($Computer.'EPOLeafNode.Tags'.Split(',').Trim() | ? { $_ -eq $Tag.tagName })) {
                    return 0
                } else {
                    return 1
                }
            }

            Mock Write-Warning {
                Write-Debug $Message
            }

            Remove-Variable -Scope 'Script' -Name 'RequestResponse' -Force -ErrorAction SilentlyContinue

            Context $Test.Name {
                [hashtable] $parameters = $Test.Parameters

                if ($Test.Output.Throws) {
                    It "Remove-ePOTag Throws" {
                        { $script:RequestResponse = Remove-ePOTag @parameters -Confirm:$False } | Should Throw
                    }
                    continue
                }

                It "Remove-ePOTag" {
                    { $script:RequestResponse = Remove-ePOTag @parameters -Confirm:$False } | Should Not Throw
                }
                
                It "Output Type: $($Test.Output.Type)" {
                    $script:RequestResponse | Should BeNullOrEmpty
                }
            }
        }
    }

    Remove-Variable -Scope 'Global' -Name 'Test' -Force -ErrorAction SilentlyContinue
    Remove-Variable -Scope 'Global' -Name 'ReferenceDirectory' -Force -ErrorAction SilentlyContinue
}