#!/bin/bash

# Do not run this script directly as root (e.g. with "sudo")...

# -------------------------------------------------------------------------------------------------

# Prerequisites

# VMWare Workstation

# sudo apt -qqy install open-vm-tools-desktop

# VirtualBox

# Do not enable 3D acceleration for version 5.2.2: https://www.virtualbox.org/wiki/Downloads

# sudo apt -qqy install gcc
# sudo apt -qqy install make

# Install the Linux Guest Additions

# Ubuntu/Xbuntu

# Set the system language to "English (United States)"

# -------------------------------------------------------------------------------------------------

update_all() {
  echo 'Updating/upgrading all packages...'
  
  sudo apt -qqy update
  sudo apt -qqy upgrade
}

install_curl() {
  echo 'Installing curl...'

  sudo apt -qqy install curl
}

install_node() {
  echo 'Installing Node.js...'

  # Node.js is needed for certain dotnet templates like Angular.

  # https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
  curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -

  sudo apt -qqy install nodejs
}

install_chromium() {
  echo 'Installing Chromium...'

  sudo apt -qqy install chromium-browser

  # There seems to be an "xdg-open" bug in Xubuntu 17.10 with Firefox as the default browser
  # when starting an application with the Visual Studio Code debugger...

  # https://wiki.gentoo.org/wiki/Default_Applications#Setting_the_default_application_via_xdg-settings
  # https://chromium.googlesource.com/chromium/src/+/lkcr/docs/linux_dev_build_as_default_browser.md
  xdg-settings set default-web-browser chromium-browser.desktop
}

install_sqlitebrowser() {
  echo 'Installing DB Browser for SQLite...'

  sudo apt -qqy install sqlitebrowser
}

install_git() {
  echo 'Installing Git...'

  sudo apt -qqy install git
}

add_microsoft_key() {
  # https://www.microsoft.com/net/learn/get-started/linuxubuntu
  curl -s https://packages.microsoft.com/keys/microsoft.asc | \
  sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/microsoft.gpg
}

install_dotnet() {
  echo 'Installing .NET Core SDK...'

  sudo dd status=none of=/etc/apt/sources.list.d/dotnetdev.list <<< \
  'deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-artful-prod artful main'

  sudo apt -qqy update

  # Current version: https://www.microsoft.com/net/download/linux
  sudo apt -qqy install dotnet-sdk-2.0.3
}

install_visual_studio_code() {
  echo 'Installing Visual Studio Code...'

  sudo dd status=none of=/etc/apt/sources.list.d/vscode.list <<< \
  'deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main'

  sudo apt -qqy update

  sudo apt -qqy install code

  code --install-extension ms-vscode.csharp
  code --install-extension ms-mssql.mssql
  code --install-extension PeterJausovec.vscode-docker
  code --install-extension donjayamanne.githistory
  # code --install-extension eamodio.gitlens
}

install_docker() {
  echo 'Installing Docker...'

  # https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-convenience-script
  curl -fsSL get.docker.com | sudo -E bash -
}

docker_pull_mssql() {
  echo 'Pulling Docker SQL Server 2017 Linux container image...'
  
  sudo docker pull microsoft/mssql-server-linux:2017-latest
}

docker_run_mssql() {
  echo 'Running Docker SQL Server 2017 Linux container image demo...'

  # https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker
  sudo docker run \
  -e 'ACCEPT_EULA=Y' \
  -e 'MSSQL_SA_PASSWORD=Passw0rd!' \
  -p 1401:1433 \
  --name mssql \
  --network='host' \
  -d microsoft/mssql-server-linux:2017-latest

  # echo "
  # /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Passw0rd!'
  #
  # SQL...
  #
  # exit
  # " | sudo docker exec -i mssql 'bash'

  sudo docker kill mssql
  sudo docker rm mssql
}

docker_pull_dotnet() {
  echo 'Pulling Docker .NET and ASP.NET Core container images...'

  # https://github.com/dotnet/dotnet-docker-samples/blob/master/README.md
  sudo docker pull microsoft/dotnet-samples

  sudo docker pull microsoft/aspnetcore
  sudo docker pull microsoft/aspnetcore-build
}

docker_run_mvc() {
  echo 'Running Docker .NET Core MVC example...'

  # https://hub.docker.com/r/microsoft/dotnet/
  # sudo docker run -p 8000:80 -e 'ASPNETCORE_URLS=http://+:80' -it --rm microsoft/dotnet
  # mkdir app
  # cd app
  # dotnet new mvc
  # dotnet run
  # exit
}

create_projects() {
  mkdir AspNetCore2 && cd $_
  mkdir ColorName && cd $_ && dotnet new web && cd ..
  mkdir ReactApp && cd $_ && dotnet new react && npm i && cd ..
  mkdir RazorApp && cd $_ && dotnet new razor && cd ..
  mkdir MvcApp && cd $_ && dotnet new mvc --auth Individual && cd ..
  mkdir AngularApp && cd $_ && dotnet new angular && npm i && cd ..
  mkdir ReactReduxApp && cd $_ && dotnet new reactredux && npm i && cd ..
}

update_all

install_curl
install_node
install_chromium
install_sqlitebrowser

install_git

add_microsoft_key
install_dotnet
install_visual_studio_code

install_docker

docker_pull_dotnet
docker_pull_mssql

create_projects

# docker_run_mssql
# docker_run_mvc
