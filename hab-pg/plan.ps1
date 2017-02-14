$pkg_name="postgresql"
$pkg_origin="core"
$pkg_version="9.6.2"
$pkg_license=('PostgreSQL')
$pkg_upstream_url="https://www.postgresql.org/"
$pkg_description="PostgreSQL is a powerful, open source object-relational database system."
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_source="https://get.enterprisedb.com/postgresql/postgresql-$pkg_version-1-windows-x64-binaries.zip"
$pkg_shasum="4eb6e22384505f8d71caad1e21830e2ddde7ae8b7ccfcb245e978df1ad435b1a"
$pkg_bin_dirs=@("bin")
$pkg_lib_dirs=@("lib")
$pkg_include_dirs=@("include")

function Invoke-Unpack {
  Expand-Archive -Path "$HAB_CACHE_SRC_PATH/postgresql-$pkg_version-1-windows-x64-binaries.zip" -DestinationPath "$HAB_CACHE_SRC_PATH/$pkg_dirname"
}

function Invoke-Install {
  Copy-Item "pgsql/bin/*" "$pkg_prefix/bin" -Recurse -Force
  Copy-Item "pgsql/lib/*" "$pkg_prefix/lib" -Recurse -Force
  Copy-Item "pgsql/include/*" "$pkg_prefix/include" -Recurse -Force  
}
