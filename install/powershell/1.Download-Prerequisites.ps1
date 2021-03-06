Set-ExecutionPolicy Unrestricted

$prerequisitesDir = "c:\cspa\prerequisites"
If (![System.IO.Directory]::Exists($prerequisitesDir)) {
	[System.IO.Directory]::CreateDirectory($prerequisitesDir)
}
$downloader = new-object System.Net.WebClient

# http://www.microsoft.com/en-us/download/confirmation.aspx?id=19988
$prerequisiteUrl = "http://download.microsoft.com/download/c/4/b/c4b15d7d-6f37-4d5a-b9c6-8f07e7d46635/setup.exe"
Write-Host "Downloading .NET Framework 2.0 Software Development Kit (SDK) (x86)"
$file = Join-Path $prerequisitesDir "DotNET2SDK.exe"
$downloader.DownloadFile($prerequisiteUrl, $file)

# https://www.python.org/download/releases/2.7.8/
$prerequisiteUrl = "https://www.python.org/ftp/python/2.7.8/python-2.7.8.msi"
Write-Host "Downloading Python 2.7.8 Windows x86 MSI Installer (2.7.8)"
$file = Join-Path $prerequisitesDir "python-2.7.8.msi"
$downloader.DownloadFile($prerequisiteUrl, $file)

# http://nodejs.org/dist/v0.10.32/
$prerequisiteUrl = "http://nodejs.org/dist/v0.10.32/node-v0.10.32-x86.msi"
Write-Host "Downloading Node.js v0.10.32 Windows x86 MSI Installer"
$file = Join-Path $prerequisitesDir "node-v0.10.32-x86.msi"
$downloader.DownloadFile($prerequisiteUrl, $file)

# http://cran.r-project.org/
$prerequisiteUrl = "http://cran.r-project.org/bin/windows/base/R-3.1.1-win.exe"
Write-Host "Downloading R 3.1.1 for Windows"
$file = Join-Path $prerequisitesDir "R-3.1.1-win.exe"
$downloader.DownloadFile($prerequisiteUrl, $file)

# http://www.confusedbycode.com/curl/
$prerequisiteUrl = "http://www.confusedbycode.com/curl/curl-7.38.0-win32-local.msi"
Write-Host "Downloading cURL version 7.38.0 Without Administrator Privileges 32-bit"
$file = Join-Path $prerequisitesDir "curl-7.38.0-win32-local.msi"
$downloader.DownloadFile($prerequisiteUrl, $file)