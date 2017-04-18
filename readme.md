# ASP.NET Core Sample Application for Habitat

This is a multi tier, minimal functionality [ASP.NET Core](https://www.asp.net/core) MVC application. The purpose of this application is to both test and demonstrate how an ASP.NET Core application can be deployed and managed by [Habitat](https://www.habitat.sh/).

## Repository Structure

This repo contains the following key parts:

### ASP.NET Core application

The actual application is in the root of the repo and has the typical folder structure of an MVC application.

### Habitat plan

The `habitat` folder includes the habitat plan, hooks, and necessary configuration that builds the application into a `hart` package.

### MySql Habitat plan

The `hab-mysql` folder includes a habitat plan for building MySql for Windows.

### Habitat for Linux plan

The `hab-linux` folder contains a bash based plan for deploying a linux package on docker.

### Database Migrations plan

The `hab-migrations` folder contains a plan for a linux based package used to simply run database updates and create the initial database. When MySql runs in docker, this is helpful because it is diffucult to run the migration from the host. However, it would be beneficial to build one for windows as well.

## Using this sample with current Habitat binaries

In order to succesfully build and run this application inside habitat today, the following prerequisites exist:

1. You are using `hab.exe` version 0.20.0 or later. Note that 0.18.0  and above is usable but lacks the multi service spervisor if running the mysql and ASP.NET Core services on the same instance.
2. `$env:HAB_WINDOWS_STUDIO` is set to any value. I like `1` but your preferences may vary.
3. Set `$env:HAB_DEPOT_URL` to `https://depot.stevenmurawski.com/v1/depot`

The depot.stevenmurawski.com depot contains all necessary windows habitat packages (supervisor, studio, dotnet-core, etc) and only windows packages.

Eventually these last two prerequisites will no longer be necessary.

## Building the MySql and ASP.NET Core sample

### On Windows

```
git clone https://github.com/habitat-sh/habitat-aspnet-sample
cd habitat-aspnet-sample
hab studio enter
build hab-mysql
build habitat
```

This will pull down this repository, enter a Windows habitat studio and build the MySql and ASP.NET Core sample plans. Note that both of these packages are also available from the windows based depot if you do not want to build them locally.

### On Linux

On linux we can use the mysql plan in core-plans and you do not need to build it. For the ASP.NET Core application, you will want to enter into a docker/Linux based studio and build the plans both in `hab-linux` and `hab-migrator`.

```
git clone https://github.com/habitat-sh/habitat-aspnet-sample
cd habitat-aspnet-sample
hab studio enter
build hab-mysql
build hab-linux
build hab-migrator
```

## Running the application on one machine

While still in the studio:

### Start MySql

**VM:**
```
hab start core/mysql
```

A new window will open and start a habitat supervisor running mysql on port 3306 in the `default` service group.


**Docker:**
```
docker run -e HAB_MYSQL="$(cat hab-mysql/default.toml | Out-String)" -it -p 3306:3306 core/mysql --group dev
```

### Create the Database

You will need to be in the root of the sample application on the same machine running the database:

**VM:**
```
hab pkg install core/dotnet-core-sdk
hab pkg exec core/dotnet-core-sdk dotnet restore
hab pkg exec core/dotnet-core-sdk dotnet ef database update
```

**Docker:**
```
hab studio enter # Enter docker container studio
build hab-migrator
hab pkg export docker core/sample-migrator
exit

docker run -it core/sample-migrator --group dev --peer 172.17.0.2 --bind database:mysql.dev
```

This only needs to be done once for the lifrtime of the VM or container or after changing schema.

### Start the sample app:

**VM:**
```
hab sup load core/habitat-aspnet-sample --bind database:mysql.default --strategy at-once --url https://depot.stevenmurawski.com/v1/depot
```

Note that when adding services to a supervisor already running as we are doing here, we use `hab sup load` to load the service into the supervisor. We should see the ASP.NET Core service starting in our separate supervisor window. We use `--bind` to bind the connection string in the ASP.NET app to the MySql service's configuration. We also turn on the `--strategy at-once` so we can watch the application update itself when we upload new `hart`s to our depot.

**Docker:**
```
docker run -it -p 8090:8090 core/habitat-aspnet-sample --group dev --peer 172.17.0.2 --bind database:mysql.dev
```

## Using the `Vagrantfile` in this repo

The `Vagrantfile` included will start 4 VMs:

* `hab1` - `hab3`: Windows Server 2016 machines. Their firewalls will be configured, and environment variables permanently set. The `Vagrantfile` assumes that you keep `hab.exe` and its dependencies in `c:/habitat` and will sync that to the vm and put it on the path. If you keep this file in a different location, adjust the `Vagrantfile` or copy the files to the above location.

* `haproxy`: An Ubuntu 14.04 vm that installs the current linux version of habitat.

These machines are configured to work with the [demo_script](demo_script.md) in the root of this repo.

## Performing a rolling update accross three or more VMs

You need at least three services running the ASP.NET sample in order to perform a rolling update. If you would like to have each service run on its own VM (containers are coming), there is just one bit of server prep you should perform:

### Configuring the firewall to allow butterfly traffic

```
New-NetFirewallRule -DisplayName "Habitat TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9631,9638
New-NetFirewallRule -DisplayName "Habitat UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 9638
```

Alternatively you can use the [Vagrantfile](Vagrantfile) in this repo to provision these machines with vagrant.

### Starting the services

You only need to start the MySql service on a single vm just as you did above. You will also need to create the sample app database as was done above too. Then start a `habitat-aspnet-sample` service on each VM:

```
hab start core/habitat-aspnet-sample --bind database:mysql.default --peer 192.168.137.95:9638 --strategy rolling --url https://depot.stevenmurawski.com/v1/depot --topology leader
```

Note that this assumes that `192.168.137.95` is the ip of one of the nodes running the service. It can be any one but it has to be running. Since it is likely you have already started the `mysql` service, you can use its ip.

Once the third service is started, all of the services will run the sample application. Now if you upload an updated application to the depot, you can watch each service start one by one.
