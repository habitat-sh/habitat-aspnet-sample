$pkg_name="sample-migrator"
$pkg_origin="core"
$pkg_version="0.1.0"
$pkg_upstream_url="https://github.com/mwrock/habitat-aspnet-sample"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@('MIT')
$pkg_description="A sample ASP.NET Core app"
$pkg_svc_run="cd $HAB_PKG_PATH\$pkg_origin\$pkg_name\$pkg_version\$pkg_release\bin;rm appsettings.json;cp $pkg_svc_config_path/appsettings.json .;dotnet restore;dotnet ef database update;write-host 'migrated db';while(1 -eq 1){Start-Sleep 2}"

$pkg_deps=@("core/dotnet-core-sdk")

$pkg_bin_dirs=@("bin")

$pkg_binds=@{
    "database"="username password port"
  }
  
function Invoke-Build {
  cp $PLAN_CONTEXT/../*.* $HAB_CACHE_SRC_PATH/$pkg_dirname
  cp $PLAN_CONTEXT/../Configuration $HAB_CACHE_SRC_PATH/$pkg_dirname -Recurse
  cp $PLAN_CONTEXT/../Controllers $HAB_CACHE_SRC_PATH/$pkg_dirname -Recurse
  cp $PLAN_CONTEXT/../Migrations $HAB_CACHE_SRC_PATH/$pkg_dirname -Recurse
  cp $PLAN_CONTEXT/../Models $HAB_CACHE_SRC_PATH/$pkg_dirname -Recurse
  cp $PLAN_CONTEXT/../Views $HAB_CACHE_SRC_PATH/$pkg_dirname -Recurse
      
  & dotnet restore
  & dotnet build
  if($LASTEXITCODE -ne 0) {
      Write-Error "dotnet build failed!"
  }
}

function Invoke-Install {
  cp $HAB_CACHE_SRC_PATH/$pkg_dirname/* "$pkg_prefix/bin" -Recurse
}
