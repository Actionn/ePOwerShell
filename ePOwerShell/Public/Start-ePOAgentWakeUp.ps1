function Start-ePOAgentWakeUp {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $True)]
        $Computer = ''
    )

    begin {}

    process {
        try {
            $Request = @{
                Name  = 'system.wakeupAgent'
                Query = @{
                    names = $Computer
                }
            }

            Write-Debug "Request: $($Request | ConvertTo-Json)"
            $ePOWakeRequests = Invoke-ePORequest @Request

            foreach ($ePOWakeRequest in $ePOWakeRequests) {
                Write-Output $ePOWakeRequest
            }
        } catch {
            Write-Information $_ -Tags Exception
        }
    }

    end {}
}

Export-ModuleMember -Function 'Start-ePOAgentWakeUp'