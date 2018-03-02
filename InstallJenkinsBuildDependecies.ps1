# Requires -RunAsAdministrator
# Assumes target OS is Windows.

$buildToolsName = "vs_BuildTools.exe"

WriteHostNewLine "Downloading Visual Studio 2017 Build Tools...";
Invoke-WebRequest -Uri "https://aka.ms/vs/15/release/vs_buildtools.exe" -OutFile "$PSScriptRoot\$buildToolsName"

WriteHostNewLine "Installing Chocolately...";
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

WriteHostNewLine "Installing nuget...";
choco install nuget.commandline

WriteHostNewLine "Installing MSBuild dependencies...";
Start-Process "$buildToolsName" -ArgumentList '--installPath "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools" --quiet --add Microsoft.VisualStudio.Component.NuGet.BuildTools --add Microsoft.Net.Component.4.5.TargetingPack --add Microsoft.Net.Component.4.5.1.TargetingPack --add Microsoft.Net.Component.4.6.TargetingPack --add Microsoft.Net.Component.4.6.1.TargetingPack --add Microsoft.Net.Component.4.7.TargetingPack --add Microsoft.Net.Component.4.7.1.TargetingPack --add Microsoft.VisualStudio.Workload.NetCoreBuildTools --norestart --force' -Wait -PassThru

WriteHostNewLine "Adding msbuild as a system PATH environment variable...";
$registry = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
$msBuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin"
$oldPath = (Get-ItemProperty -Path "$registry" -Name PATH).Path
$newPath = "$oldPath;$msBuildPath"
Set-ItemProperty -Path "$registry" -Name PATH -Value $newPath

Update-SessionEnvironment

WriteHostNewLine "Please restart the Jenkins service to refresh environment variable references."

WriteHostNewLine -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

exit

function WriteHostNewLine
{
param([string]$logOutput)

Write-Host "$logOutput`n"
}
