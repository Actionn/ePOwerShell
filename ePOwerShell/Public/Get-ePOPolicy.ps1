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
                    if (-not ($Policy) -or ($Policy -eq $ePOPolicy.objectName)) {
                        #These are case sensitive, need to match the fields in json output from invoke-webrequest
                        $PolicyObject = [ePOPolicy]::new($ePOPolicy.featureId, $ePOPolicy.featureName, $ePOPolicy.objectId, $ePOPolicy.objectName,
                        $ePOPolicy.objectNotes, $ePOPolicy.productId, $ePOPolicy.productName, $ePOPolicy.typeId, $ePOPolicy.typeName)
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