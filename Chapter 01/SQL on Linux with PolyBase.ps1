## STEP 1 - Get SQL Server on Linux
# Get the latest version of SQL Server 2019 on Linux.
docker pull mcr.microsoft.com/mssql/server:2019-latest-ubuntu
# Choose your own password.  You can also change the port if you need to.
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=SqlPbPwd!10" -p 1433:1433 --name PolyBaseDemo -d mcr.microsoft.com/mssql/server:2019-latest-ubuntu

## STEP 2 - Connect to your container using SSMS or Azure Data Studio and create a database.
# I'll call mine PolyBaseRevealed.

## STEP 3 - Install components for PolyBase
# Enter the container to begin follow-up configuration.
docker exec -it PolyBaseDemo /bin/bash
# NOTE:  at this point, we're in a bash shell.
# Grab Microsoft's apt key.  We're root, so no sudo needed.
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# Update software, add the Microsoft repo, and refresh apt.
apt-get update -y && apt-get upgrade -y
apt-get install -y software-properties-common
add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-preview.list)"
apt-get update -y && apt-get upgrade -y
# Install the PolyBase executable
apt-get install mssql-server-polybase -y
# Now return back to PowerShell
exit

## STEP 4 - Restart our container
docker stop PolyBaseDemo
docker restart PolyBaseDemo
