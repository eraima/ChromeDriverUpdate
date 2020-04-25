cls
$sb = [System.Text.StringBuilder]::new()
$logFileLocation = 'C:\temp\chromedriver\Logs\'
$chromeDriverPath = 'C:\temp\chromedriver\'

try{
    $currentChromeDriverVersion = ''
    if (!(Test-Path -Path ($chromeDriverPath+'chromedriverversion.txt'))){
        New-Item -path $chromeDriverPath -name chromedriverversion.txt -type "file"
        [void]$sb.AppendLine('Created ChromeDriver Version file')
    }
    else{
        $currentChromeDriverVersion = Get-Content -Path ($chromeDriverPath+'chromedriverversion.txt')
    }
    [void]$sb.AppendLine('Current ChromeDriver Version : ' + $currentChromeDriverVersion)

    $chromVersion = (Get-Item (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(Default)').VersionInfo.ProductVersion
    [void]$sb.AppendLine('Installed Chrome browser version : ' + $chromVersion)

    $chromeDriverLatestReleaseUrl = 'https://chromedriver.storage.googleapis.com/LATEST_RELEASE_' + $chromVersion;
    $chromeDriverLatestReleaseUrl = $chromeDriverLatestReleaseUrl.Substring(0,$chromeDriverLatestReleaseUrl.LastIndexOf('.'))
    [void]$sb.AppendLine('Chromedriver latest release uri : ' + $chromeDriverLatestReleaseUrl)


    $response = Invoke-WebRequest -Uri $chromeDriverLatestReleaseUrl
    $chromeDriverLatestVersion = $response.Content
    [void]$sb.AppendLine('Chromedriver latest version : ' + $chromeDriverLatestVersion)


    if ($chromeDriverLatestVersion -ne $currentChromeDriverVersion){
        [void]$sb.AppendLine('Current ChromeDriver version is out of date. Attempting to upgrade')

        if (Test-Path -Path ($chromeDriverPath+'chromedriver.exe')){
            Remove-Item -Path ($chromeDriverPath+'chromedriver.exe') -Force
            [void]$sb.AppendLine('Deleted chromedriver.exe from ' + $chromeDriverPath)
        }

        $chromeDriverDownloadUrl = 'https://chromedriver.storage.googleapis.com/' + $chromeDriverLatestVersion + '/chromedriver_win32.zip'
        [void]$sb.AppendLine('Chromedriver latest version download uri : ' + $chromeDriverDownloadUrl)
        
        Invoke-WebRequest -Uri $chromeDriverDownloadUrl -OutFile ($env:TEMP + '\chromedriver.zip')
        [void]$sb.AppendLine('Downloaded ChromeDriver zip to ' + ($env:TEMP + '\chromedriver.zip'))

        Expand-Archive -Path ($env:TEMP + '\chromedriver.zip') -DestinationPath ($env:TEMP + '\chromedriver')
        [void]$sb.AppendLine('Expanded the contents to ' + ($env:TEMP + '\chromedriver'))

        Copy-Item ($env:TEMP + '\chromedriver\chromedriver.exe') -Destination $chromeDriverPath
        [void]$sb.AppendLine('Copied the chromedriver.exe to ' + $chromeDriverPath)

        Remove-Item -Path ($env:TEMP + '\chromedriver.zip') -Force
        Remove-Item ($env:TEMP + '\chromedriver\*.exe') -Force
        [void]$sb.AppendLine('Cleaned up the temporarily files')

        Set-Content -Path ($chromeDriverPath+'chromedriverversion.txt') -Value $chromeDriverLatestVersion
        [void]$sb.AppendLine('Update current ChromeDriver version to  ' + $chromeDriverLatestVersion)
    }
    else{
        [void]$sb.AppendLine('ChromeDriver up to date')
    }
}
catch{
    [void]$sb.AppendLine('Failed: ' + $Error[0])
}

$sb.ToString()
$sb.ToString() | Out-File -FilePath ($logFileLocation + (Get-Date).ToString('yyyyMMdd_hhmmss') + '_logs.txt')

