<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   Download files from fosshub website
#̷𝓍   
#>
[CmdletBinding(SupportsShouldProcess)]
param()

function Get-DownloadUrl{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, position = 0)]
        [ValidateSet('iview460_x64_setup.exe','iview460_plugins_x64_setup.exe')]
        [string]$FileName,
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


function Invoke-DownloadOnlineFile{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true, position = 0)]
        [string]$Url,
        [Parameter(Mandatory=$true, position = 1)]
        [string]$DestinationPath      
    )  
  try{

    $Script:ProgressTitle = 'STATE: DOWNLOAD'
    $uri = New-Object "System.Uri" "$Url"
    $request = [System.Net.HttpWebRequest]::Create($Url)
    $request.PreAuthenticate = $false
    $request.Method = 'GET'

    $request.Headers.Add('sec-ch-ua', '" Not A;Brand";v="99", "Chromium";v="99", "Google Chrome";v="99"')
    $request.Headers.Add('sec-ch-ua-mobile', '?0')
    $request.Headers.Add('sec-ch-ua-platform', "Windows")
    $request.Headers.Add('Upgrade-Insecure-Requests', '1')
    $request.Headers.Add('User-Agent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36')
    $request.Headers.Add('Sec-Fetch-Site', 'same-site')
    $request.Headers.Add('Sec-Fetch-Mode' ,'navigate')
    $request.Headers.Add('Sec-Fetch-Dest','document')
    $request.Headers.Add('Referer' , 'https=//www.fosshub.com/')
    $request.Headers.Add('Accept-Encoding', 'gzip, deflate, br')

    $request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'
    $request.KeepAlive = $true
    $request.Timeout = ($TimeoutSec * 1000)
    $request.set_Timeout(15000) #15 second timeout

    $response = $request.GetResponse()

    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
    $totalLengthBytes = [System.Math]::Floor($response.get_ContentLength())
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $DestinationPath, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $dlkb = 0
    $downloadedBytes = $count
    $script:steps = $totalLength
    while ($count -gt 0){
       $targetStream.Write($buffer, 0, $count)
       $count = $responseStream.Read($buffer,0,$buffer.length)
       $downloadedBytes = $downloadedBytes + $count
       $dlkb = $([System.Math]::Floor($downloadedBytes/1024))
       $msg = "Downloaded $dlkb Kb of $totalLength Kb"
       $perc = (($downloadedBytes / $totalLengthBytes)*100)
       if(($perc -gt 0)-And($perc -lt 100)){
         Write-Progress -Activity $Script:ProgressTitle -Status $msg -PercentComplete $perc 
       }
    }

    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
  }catch{
    Write-Error $_
    return $false

  }finally{
    Write-Progress -Activity $Script:ProgressTitle -Completed
    Write-verbose "Downloaded $Url"
  }

  return $true
}

Remove-Item -Path "$PSSCriptRoot\bin" -Recurse -Force -ErrorAction Ignore | Out-Null
New-Item -Path "$PSSCriptRoot\bin" -ItemType Directory -Force -ErrorAction Ignore | Out-Null





[string]$FileName = 'iview460_x64_setup.exe'  
Write-Host "------------------------------------------" -f DarkRed
Write-Host "Getting URL for file `"$FileName`"" -f DarkYellow

[string]$DestinationPath = "$PSSCriptRoot\bin\$FileName"
$Url = (Get-DownloadUrl -FileName $FileName).url
Write-Verbose "URL is `"$Url`""
[string]$DestinationPath = "$PSSCriptRoot\bin\$FileName"
    
Write-Host "Downloading..." -f DarkYellow -n

$ret = Invoke-DownloadOnlineFile $Url $DestinationPath
if($ret){
  Write-Host "SUCCESS" -f DarkGreen
}else{
  Write-Host "ERROR" -f DarkRed
}

[string]$FileName = 'iview460_plugins_x64_setup.exe' 
Write-Host "------------------------------------------" -f DarkRed
Write-Host "Getting URL for file `"$FileName`"" -f DarkYellow

 
[string]$DestinationPath = "$PSSCriptRoot\bin\$FileName"
$Url = (Get-DownloadUrl -FileName $FileName).url
Write-Verbose "URL is `"$Url`""
[string]$DestinationPath = "$PSSCriptRoot\bin\$FileName"
    
Write-Host "Downloading..." -f DarkYellow -n

$ret = Invoke-DownloadOnlineFile $Url $DestinationPath
if($ret){
  Write-Host "SUCCESS" -f DarkGreen
}else{
  Write-Host "ERROR" -f DarkRed
}