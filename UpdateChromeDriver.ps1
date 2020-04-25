cls
$sb = [System.Text.StringBuilder]::new()
$logFileLocation = 'c:\temp\chromedriver\logs\'
$chromeDriverPath = 'c:\temp\chromedriver\'

try{
    $currentChromeDriverVersion = ''
    if (!(Test-Path -Path ($chromeDriverPath+'chromedriverversion.txt'))){
        New-Item -path $chromeDriverPath -name chromedriverversion.txt -type "file"
        [void]$sb.AppendLine('Created ChromeDriver Version file')
    }
    else{
        $currentChromeDriverVersion = Get-Content -Path ($chromeDriverPath+'chromedriverversion.txt')
    }
    [void]$sb.AppendLine('Current ChromeDriver Version :' + $currentChromeDriverVersion)

    $chromVersion = (Get-Item (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(Default)').VersionInfo.ProductVersion
    [void]$sb.AppendLine('Installed Chrome browser version :' + $chromVersion)

    $chromeDriverLatestReleaseUrl = 'https://chromedriver.storage.googleapis.com/LATEST_RELEASE_' + $chromVersion;
    $chromeDriverLatestReleaseUrl = $chromeDriverLatestReleaseUrl.Substring(0,$chromeDriverLatestReleaseUrl.LastIndexOf('.'))
    [void]$sb.AppendLine('Chromedriver latest release uri :' + $chromeDriverLatestReleaseUrl)


    $response = Invoke-WebRequest -Uri $chromeDriverLatestReleaseUrl
    $chromeDriverLatestVersion = $response.Content
    [void]$sb.AppendLine('Chromedriver latest version :' + $chromeDriverLatestVersion)


    if ($chromeDriverLatestVersion -ne $currentChromeDriverVersion){
        [void]$sb.AppendLine('Current ChromeDriver version is out of date. Attempting to upgrade')

        if (Test-Path -Path ($chromeDriverPath+'chromedriver.exe')){
            Remove-Item -Path ($chromeDriverPath+'chromedriver.exe') -Force
            [void]$sb.AppendLine('Deleted chromedriver.exe from ' + $chromeDriverPath)
        }

        $chromeDriverDownloadUrl = 'https://chromedriver.storage.googleapis.com/index.html?path=' + $chromeDriverLatestVersion + '/'
        [void]$sb.AppendLine('Chromedriver latest version download uri :' + $chromeDriverDownloadUrl)


        Invoke-WebRequest -Uri $chromeDriverDownloadUrl -OutFile ($chromeDriverPath+'chromedriver.exe')
        [void]$sb.AppendLine('Downloaded ChromeDriver to ' + ($chromeDriverPath+'chromedriver.exe'))

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

