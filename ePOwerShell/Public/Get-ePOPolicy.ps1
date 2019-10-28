<#
#>

function Get-ePOPolicy {
    [CmdletBinding()]
    [Alias('Find-ePOwerShellPolicy','Find-ePOPolicy')]
    [OutputType([System.Object[]])]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $True)]
        [Alias('PolicyName')]
        $Policy = ''
    )

    begin {}

    process {
        try {
            if ($Policy -is [ePOPolicy]) {
                Write-Verbose 'Using pipelined ePOPolicy object'
                Write-Output $Policy
            } else {
                Write-Verbose 'Either not pipelined, or pipeline object is not an ePOPolicy object'
                $Request = @{
                    Name  = 'policy.find'
                    Query = @{
                        searchText = $Policy
                    }
                }

                Write-Debug "Request: $($Request | ConvertTo-Json)"
                $ePOPolicies = Invoke-ePORequest @Request

                foreach ($ePOPolicy in $ePOPolicies) {
                    if (-not ($Policy) -or ($Policy -eq $ePOPolicy.policyName)) {
                        $PolicyObject = [ePOPolicy]::new($ePOPolicy.FeatureID, $ePOPolicy.FeatureName, $ePOPolicy.ObjectID, $ePOPolicy.ObjectName, `
                        $ePOPolicy.ObjectNotes, $ePOPolicy.ProductID, $ePOPolicy.ProductName, $ePOPolicy.TypeID, $ePOPolicy.TypeName )
                        Write-Output $PolicyObject
                    }
                }
            }
        } catch {
            Write-Information $_ -Tags Exception
        }
    }

    end {}
}

Export-ModuleMember -Function 'Get-ePOPolicy' -Alias 'Find-ePOwerShellPolicy','Find-ePOPolicy'