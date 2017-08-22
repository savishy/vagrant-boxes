# referenceS:
# https://forums.docker.com/t/unable-to-find-package-provider-power-shell-error/26075/4
# https://docs.docker.com/engine/installation/windows/docker-ee/#install-docker-ee
# https://forums.docker.com/t/error-installing-docker-on-windows-server-2016-essentials/34182/8

Set-ExecutionPolicy unrestricted
Enable-WindowsOptionalFeature -Online -FeatureName containers -All
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name DockerMsftProvider -Force
Unregister-PackageSource -ProviderName DockerMsftProvider -Name DockerDefault -Erroraction Ignore
Unregister-PackageSource -ProviderName DockerMsftProvider -Name Docker -Erroraction Ignore
Register-PackageSource -ProviderName DockerMsftProvider -Name Docker -Location https://download.docker.com/components/engine/windows-server/index.json
Install-Package -Name docker -ProviderName DockerMsftProvider -Source Docker -Force
