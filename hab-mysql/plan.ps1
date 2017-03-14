$pkg_name="mysql"
$pkg_origin="core"
$pkg_version="5.7.17"
$pkg_license=('GPL-2.0')
$pkg_upstream_url="https://www.mysql.com/"
$pkg_description="mysql, a database"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_source="https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-$pkg_version-winx64.zip"
$pkg_shasum="53b2e9eec6d7c986444926dd59ae264d156cea21a1566d37547f3e444c0b80c8"
$pkg_bin_dirs=@("bin")
$pkg_lib_dirs=@("lib")
$pkg_include_dirs=@("include")
$pkg_exports=@{
    "port"="port"
    "password"="app_password"
    "username"="app_username"
}

function Invoke-Unpack {
  Expand-Archive -Path "$HAB_CACHE_SRC_PATH/mysql-$pkg_version-winx64.zip" -DestinationPath "$HAB_CACHE_SRC_PATH/$pkg_dirname"
}

function Invoke-Install {
  Copy-Item "mysql-$pkg_version-winx64/bin/*" "$pkg_prefix/bin" -Recurse -Force
  Copy-Item "mysql-$pkg_version-winx64/lib/*" "$pkg_prefix/lib" -Recurse -Force
  Copy-Item "mysql-$pkg_version-winx64/include/*" "$pkg_prefix/include" -Recurse -Force
  Copy-Item "mysql-$pkg_version-winx64/share" "$pkg_prefix" -Recurse -Force
}
