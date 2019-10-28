<#
    .SYNOPSIS
        Set policies of ePO Computer
#>
function Set-ePOComputerPolicy {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([System.Object[]])]
    param (
        [Parameter(ParameterSetName = 'ComputerName', Position = 1, ValueFromPipeline = $True)]
        [Alias('hostname', 'name', 'computername')]
        $Computer,
        [Parameter(ParameterSetName = 'HIPSPolicy',  ValueFromPipeline = $False)]
        $HIPSPolicy,
        [Parameter(ParameterSetName = 'VSEPolicy',  ValueFromPipeline = $False)]
        $VSEPolicy,
        [Parameter(ParameterSetName = 'All')]
        [Switch]
        $All
    )

    begin {
        try {
            #This will grab our productId, typeId, and objectId
            $policyFindRequest = @{
                Name  = 'policy.find'
                Query = @{
                    searchText = ''
                }
            }
        } catch {
            Write-Information $_ -Tags Exception
            Throw $_
        }
    }

    process {
        try {
            switch ($PSCmdlet.ParameterSetName) {
                "HIPSPolicy" {
                    Write-Debug ("Searching for HIPS Policy: {0]" -f $HIPSPolicy)
                    $policyFindRequest.Query.searchText = $HIPSPolicy
                    $HIPSPolicies = Invoke-epoRequest @policyFindRequest
                }
                "ComputerName" {
                    foreach ($Comp in $Computer) {
                        Write-Debug ('Searching by computer name for: {0}' -f $Comp)
                        #this [ePOComputer] section I believe is checking the object type, like at the top of a gm output
                        if ($Comp -is [ePOComputer]) {
                            Write-Verbose 'Using ePOComputer object'
                            Write-Output $Comp
                        } else {
                            if ($ForceWildcardHandling) {
                                if (-not ($script:AllePOComputers)) {
                                    $Request.Query.searchText = ''
                                    $script:AllePOComputers = Invoke-ePORequest @Request
                                }

                                foreach ($ePOComputer in $script:AllePOComputers) {
                                    if ($ePOComputer.'EPOComputerProperties.ComputerName' -like $Comp) {
                                        $ePOComputerObject = ConvertTo-ePOComputer $ePOComputer
                                        Write-Output $ePOComputerObject
                                    }
                                }
                            } else {
                                $Request.Query.searchText = $Comp
                                $ePOComputers = Invoke-ePORequest @Request

                                foreach ($ePOComputer in $ePOComputers) {
                                    if ($ePOComputer.'EPOComputerProperties.ComputerName' -eq $Comp) {
                                        $ePOComputerObject = ConvertTo-ePOComputer $ePOComputer
                                        Write-Output $ePOComputerObject
                                    }
                                }
                            }
                        }
                    }
                }

                "All" {
                    $Request.Query.searchText = ''
                    $ePOComputers = Invoke-ePORequest @Request

                    foreach ($ePOComputer in $ePOComputers) {
                        $ePOComputerObject = ConvertTo-ePOComputer $ePOComputer
                        Write-Output $ePOComputerObject
                    }
                }
            }
        } catch {
            Write-Information $_ -Tags Exception
        }
    }

    end {
        if (Get-Variable 'AllePOComputers' -Scope Script -ErrorAction SilentlyContinue) {
            Remove-Variable -Name 'AllePOComputers' -Scope Script
        }
    }
}

Export-ModuleMember -Function 'Get-ePOComputer' -Alias 'Find-ePOwerShellComputerSystem', 'Find-ePOComputerSystem'