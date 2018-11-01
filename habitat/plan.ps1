$pkg_name="habitat-aspnet-sample"
$pkg_origin="mwrock"
$pkg_version="1.4.6"
$pkg_upstream_url="https://github.com/mwrock/habitat-aspnet-sample"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@('MIT')
$pkg_description="A sample ASP.NET Core app"

$pkg_deps=@("core/dotnet-core")
$pkg_build_deps=@("core/dotnet-core-sdk")

$pkg_exports=@{
    "port"="port"
}

$pkg_binds=@{
  "database"="username password port"
}

function Invoke-Build {
  cp $PLAN_CONTEXT/../* $HAB_CACHE_SRC_PATH/$pkg_dirname -recurse -force -Exclude ".vagrant"
  & "$(Get-HabPackagePath dotnet-core-sdk)\bin\dotnet.exe" restore
  & "$(Get-HabPackagePath dotnet-core-sdk)\bin\dotnet.exe" build
  if($LASTEXITCODE -ne 0) {
      Write-Error "dotnet build failed!"
  }
}

function Invoke-Install {
  & "$(Get-HabPackagePath dotnet-core-sdk)\bin\dotnet.exe" publish --output "$pkg_prefix/www"
}
