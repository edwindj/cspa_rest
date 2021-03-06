Set-ExecutionPolicy Unrestricted
$ErrorActionPreference = 'Stop'

Try { 
	# variables
	$installRootDir = 'c:\cspa\'
	$prerequisitesDir = 'c:\cspa\prerequisites'
	$RPath = 'C:\Program Files\R\R-3.1.1\bin\i386'
	$pythonPath = 'C:\Python27\'

	# install the prerequisites
	Write-Host "Installing the prerequisites"
	$file = Join-Path $prerequisitesDir "python-2.7.8.msi"
	Start-Process msiexec -ArgumentList ("/qb /i " + $file + " ALLUSERS=1") -Wait
	$file = Join-Path $prerequisitesDir "DotNET2SDK.exe"
	Start-Process $file -ArgumentList "/q:a /c:""install.exe /qb!""" -Wait
	$file = Join-Path $prerequisitesDir "node-v0.10.32-x86.msi"
	Start-Process msiexec -ArgumentList ("/qb /i " + $file) -Wait
	# bug in msi (http://stackoverflow.com/questions/25093276/nodejs-windows-error-enoent-stat-c-users-rt-appdata-roaming-npm)
	$roamingNpm = 'C:\Users\Administrator\AppData\Roaming\npm'
	If (![System.IO.Directory]::Exists($roamingNpm)) {
		[System.IO.Directory]::CreateDirectory($roamingNpm)
	}
	
	$file = Join-Path $prerequisitesDir "R-3.1.1-win.exe"
	Start-Process $file -ArgumentList ("/SILENT") -Wait
	$file = Join-Path $prerequisitesDir "curl-7.38.0-win32-local.msi"
	Start-Process msiexec -ArgumentList ("/qb /i " + $file) -Wait

	# set Environment Variables (Get-ChildItem Env: to check)
	Write-Host "Set Environment Variables"
	"C:\Program Files (x86)\Microsoft.NET\SDK\v2.0\Bin\sdkvars.bat"
	# powershell equivalent of setx PATH "%PATH%;C:\Program Files\R\R-3.1.1\bin\i386" /M
	$oldPath = [Environment]::GetEnvironmentVariable('path', 'machine');
	If ($oldPath.Split(";") -notcontains $RPath) 
	{
		[Environment]::SetEnvironmentVariable('path', "$($oldPath);$($RPath)",'Machine')
	}
	If ($oldPath.Split(";") -notcontains $pythonPath) 
	{
		[Environment]::SetEnvironmentVariable('path', "$($oldPath);$($pythonPath)",'Machine')
	}
	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
}
Catch {
	Write-Host 'Caught exception: ' $_.Exception.Message
}