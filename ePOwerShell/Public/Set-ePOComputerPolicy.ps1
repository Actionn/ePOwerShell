function Set-ePOPolicy {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "Medium", DefaultParameterSetName = 'Computer')]
    [Alias('Set-ePOwerShellPolicy')]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ParameterSetName = 'Computer')]
        [Alias('ComputerName', 'cn')]
        $Computer,

        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [Alias('Policy')]
        $PolicyName
    )

    begin {
        try {
            $Request = @{
                Name  = 'policy.AssignToSystem'
                Query = @{
                    ids         = ''
                    productId   = ''
                    typeId      = ''
                    objectId    = ''
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
                'Computer' {
                    :Computer foreach ($Comp in $Computer) {
                        :Policy foreach ($Policy in $PolicyName) {
                            if ($Comp -is [ePOPolicy] -and $Policy -is [ePOComputer]) {
                                Write-Verbose 'Computer and tag objects are mismatched. Swapping...'
                                $Comp, $Policy = $Policy, $Comp
                            }

                            if ($Comp -is [ePOComputer]) {
                                $Request.Query.ids = $Comp.ParentID
                            } elseif ($Comp -is [String]) {
                                if (-not ($Comp = Get-ePOComputer -Computer $Comp)) {
                                    Write-Error ('Failed to find a computer with provided name: {0}' -f $Comp)
                                    continue Computer
                                }
                                $Request.Query.ids = $Comp.ParentID
                            } else {
                                Write-Error 'Failed to interpret computer'
                                continue Computer
                            }

                            if ($Policy -is [ePOPolicy]) {
                                $Request.Query.productId = $Policy.ProductID
                                $Request.Query.typeId = $Policy.TypeID
                                $Request.Query.objectId = $Policy.ObjectID
                            } elseif ($Policy -is [String]) {
                                if (-not ($Policy = Get-ePOPolicy -Policy $Policy)) {
                                    Write-Error ('Failed to find a Policy with provided name: {0}' -f $Policy)
                                    continue Policy
                                }
                                $Request.Query.productId = $Policy.ProductID
                                $Request.Query.typeId = $Policy.TypeID
                                $Request.Query.objectId = $Policy.ObjectID
                            } else {
                                Write-Error 'Failed to interpret policy'
                                continue Policy
                            }

                            Write-Verbose ('Computer Name: {0}' -f $Comp.ComputerName)
                            Write-Verbose ('Computer ID: {0}' -f $Comp.ParentID)
                            Write-Verbose ('Tag ProductID: {0}' -f $Policy.ProductID)
                            Write-Verbose ('Tag TypeID: {0}' -f $Policy.TypeID)
                            Write-Verbose ('Tag ObjectID: {0}' -f $Policy.ObjectID)
                            Write-Verbose ('Tag ObjectName: {0}' -f $Policy.ObjectName)
                            

                            if ($PSCmdlet.ShouldProcess("Set ePO policy on $($Comp.ComputerName) to $($Policy.ObjectName)")) {
                                $Result = Invoke-ePORequest @Request

                                if ($Result -eq 0) {
                                    Write-Verbose ('Policy [{0}] is already set on computer {1}' -f $Policy.ObjectName, $Comp.ComputerName)
                                } elseif ($Result -eq 1) {
                                    Write-Verbose ('Successfully set policy [{0}] on computer {1}' -f $Policy.ObjectName, $Comp.ComputerName)
                                } else {
                                    Write-Error ('Unknown response while setting policy [{0}] from {1}: {2}' -f $Policy.ObjectName, $Comp.ComputerName, $Result) -ErrorAction Stop
                                }
                            }
                        }
                    }
                }

            }
        } catch {
            Write-Information $_ -Tags Exception
            Throw $_
        }
    }

    end {}
}

Export-ModuleMember -Function 'Set-ePOPolicy' -Alias 'Set-ePOwerShellPolicy'