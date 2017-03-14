#!/bin/sh
#
ln -sf "{{pkg.path}}/bin" "{{pkg.svc_var_path}}"

cd "{{pkg.svc_var_path}}/bin" || exit
cp -f "{{pkg.svc_config_path}}/appsettings.json" .
dotnet restore 2>&1

csc=$(find /hab/pkgs/core/dotnet-core-sdk/1.0.1 -name RunCsc.sh)
rm $csc
cat << EOF >$csc
#!/bin/sh
exit 0
EOF
chmod a+x $csc

dotnet ef database update 2>&1
