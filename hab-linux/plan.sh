pkg_name="habitat-aspnet-sample"
pkg_origin="core"
pkg_version="0.2.0"
pkg_source="nosuchfile.tar.gz"
pkg_upstream_url="https://github.com/mwrock/habitat-aspnet-sample"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('MIT')
pkg_description="A sample ASP.NET Core app"

pkg_deps=(
  core/dotnet-core
)

pkg_build_deps=(
  core/dotnet-core-sdk
  core/patchelf  
)
pkg_exports=(
    [port]=port
)

do_download() {
  return 0
}
do_verify() {
  return 0
}
do_unpack() {
  return 0
}

do_build() {
  cp $PLAN_CONTEXT/../*.* $HAB_CACHE_SRC_PATH/$pkg_dirname
  cp -r $PLAN_CONTEXT/../Configuration $HAB_CACHE_SRC_PATH/$pkg_dirname
  cp -r $PLAN_CONTEXT/../Controllers $HAB_CACHE_SRC_PATH/$pkg_dirname
  cp -r $PLAN_CONTEXT/../Migrations $HAB_CACHE_SRC_PATH/$pkg_dirname
  cp -r $PLAN_CONTEXT/../Models $HAB_CACHE_SRC_PATH/$pkg_dirname
  cp -r $PLAN_CONTEXT/../Views $HAB_CACHE_SRC_PATH/$pkg_dirname

  "$(pkg_path_for dotnet-core-sdk)/bin/dotnet" restore
  find /root/.nuget -type f -name '*.so*' \
    -exec patchelf --set-rpath "$LD_RUN_PATH" {} \;
  "$(pkg_path_for dotnet-core-sdk)/bin/dotnet" build
}

do_install() {
  "$(pkg_path_for dotnet-core-sdk)/bin/dotnet" publish --output "$pkg_prefix/www"
}
