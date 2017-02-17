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

## Using this sample with current Habitat binaries

In order to succesfully build and run this application inside habitat today, the following prerequisites exist:

1. You are using a `hab.exe` binary compiled from the `win_hack_core` [habitat branch](https://github.com/habitat-sh/habitat/tree/win_hack_core).
2. `$env:HAB_WINDOWS_STUDIO` is set to any value. I like `1` but your preferences may vary.
3. Set `$env:HAB_DEPOT_URL` to `https://depot.stevenmurawski.com/v1/depot`

I try to keep `win_hack_core` rebased against current master and it includes 2 small hacks (view the diff in github if you are curious) that makes accessing packages from a depot possible on Windows.

The depot.stevenmurawski.com depot contains all necessary windows habitat packages (supervisor, studio, dotnet-core, etc) and only windows packages.

Eventually these prerequisites will no longer be necessary.

## Building the MySql and ASP.NET Core sample

```
git clone https://github.com/mwrock/habitat-aspnet-sample
cd habitat-aspnet-sample
hab studio enter
build hab-mysql
build .
```

This will pull down this repository, enter a Windows habitat studio and build the MySql and ASP.NET Core sample plans.

## Running the application on one machine

While still in the studio:

```
hab start core/mysql
```

A new window will open and start a habitat supervisor running mysql on port 3306 in the `default` service group.

Now start the sample app:

```
hab start core/habitat-aspnet-sample --bind database:mysql.default --peer 127.0.0.1:9638 --listen-gossip 0.0.0.0:9639 --listen-http 0.0.0.0:9632 --strategy at-once --url https://depot.stevenmurawski.com/v1/depot
```

Note that because we are running two supervisors on one host, we need to specify different `--listen-gossip` and `--listen-http` endpoints for the second supervisor. We use `--bind` to bind the connection string in the ASP.NET app to the MySql service's configuration. We also turn on the `--strategy at-once` so we can watch the application update itself when we upload new `hart`s to our depot.
