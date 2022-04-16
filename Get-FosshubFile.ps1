<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   Download files from fosshub website
#̷𝓍   
#>


function Get-DownloadUrl{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$FileName = 'iview460_plugins_x64_setup.exe',
        [Parameter(Mandatory=$false)]
        [string]$ReleaseId = '623457812413750bd71fef36',
        [Parameter(Mandatory=$false)]
        [string]$ProjectId = '5b8d1f5659eee027c3d7883a'       
    )  
    try{
        $Url = 'https://api.fosshub.com/download'
        $Params = @{
            Uri             = $Url
            Body            = @{
                projectId  = "$ProjectId"
                releaseId  = "$ReleaseId"
                projectUri = 'IrfanView.html'
                fileName   = "$FileName"
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
        Write-Error $_
    }
}


function Invoke-DownloadFile{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$FileName = 'iview460_plugins_x64_setup.exe'      
    ) 
    try{
        $u = Get-DownloadUrl -FileName $FileName
        $Url = $u.url
        $Params = @{
            Uri             = $Url
            Body            = @{
            }

            Headers         = @{
                'sec-ch-ua'= '" Not A;Brand";v="99", "Chromium";v="99", "Google Chrome";v="99"'
                'sec-ch-ua-mobile'= '?0'
                'sec-ch-ua-platform'= "Windows"
                'Upgrade-Insecure-Requests'= '1'
                
                'Accept'= 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'

                'User-Agent'          = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36'
                'Sec-Fetch-Site'= 'same-site'
                'Sec-Fetch-Mode'   = 'navigate'
                'Sec-Fetch-Dest'='document'
                'Referer' = 'https=//www.fosshub.com/'
                'Accept-Encoding'= 'gzip, deflate, br'
            }
            Method          = 'GET'
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
        Write-Error $_
    }
}
