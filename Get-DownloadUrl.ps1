<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   Download files from fosshub website
#̷𝓍   
#>


function Get-DownloadUrl{
    [CmdletBinding(SupportsShouldProcess)]
    param(
    ) 
    try{
        $Url = 'https://api.fosshub.com/download'
        $Params = @{
            Uri             = $Url
            Body            = @{
                projectId  = '5b8d1f5659eee027c3d7883a'
                releaseId  = '623457812413750bd71fef36'
                projectUri = 'IrfanView.html'
                fileName   = 'iview460_plugins_x64_setup.exe'
                source     = 'CF'
            }

            Headers         = @{
                'User-Agent'          = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36'
            }
            Method          = 'POST'
            UseBasicParsing = $true
        }
        Write-Verbose "Invoke-WebRequest $Params"
        $Data = (Invoke-WebRequest  @Params).Content | ConvertFrom-Json
        $ErrorType = $Response.error
        if($ErrorType -ne $Null){
            throw "ERROR RETURNED $ErrorType"
            return $Null
        }
        return $Data.data
    }catch{
        Show-ExceptionDetails $_ -ShowStack
    }
}

