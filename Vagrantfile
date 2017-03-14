# -*- mode: ruby -*-
# vi: set ft=ruby :

# This should be put into the root of the chef repo

$win_script = <<SCRIPT
function Add-Path($path) {
  if(!$env:path.Contains($path)) {
    $new_path = "$env:PATH;$path"
    $env:PATH=$new_path
    [Environment]::SetEnvironmentVariable("path", $new_path, "Machine")
  }
}

New-NetFirewallRule -DisplayName "Habitat TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9631,9632,9638,9639,3306,8090
New-NetFirewallRule -DisplayName "Habitat UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 9638,9639

Add-Path "C:/habitat"

[Environment]::SetEnvironmentVariable("HAB_WINDOWS_STUDIO", "1", "Machine")
[Environment]::SetEnvironmentVariable("HAB_DEPOT_URL", "https://depot.stevenmurawski.com/v1/depot", "Machine")

mkdir "/hab/cache" -ErrorAction SilentlyContinue
mkdir "/hab/pkgs/core" -ErrorAction SilentlyContinue

Copy-Item "/vagrant-hab/cache/keys" "/hab/cache" -Recurse -Force

SCRIPT

$haproxy_script = <<SCRIPT
  sudo wget "https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh"
  sudo chmod u+x install.sh
  sudo ./install.sh
  sudo adduser --system hab || true
  sudo addgroup --system hab || true
SCRIPT

Vagrant.configure(2) do |config|
  (1..3).each do |i|
    config.vm.define "hab#{i}" do |hab|
      hab.vm.box = "mwrock/Windows2016"
      hab.vm.provision "shell", inline: $win_script
      hab.vm.guest = :windows

      hab.vm.synced_folder "/habitat", "/habitat"
      hab.vm.synced_folder ".", "/habitat-aspnet-sample"
      hab.vm.synced_folder "/hab", "/vagrant-hab"

      hab.vm.provider "hyperv" do |hv|
        hv.vmname = "hab#{i}"
        hv.ip_address_timeout = 240
        hv.memory = 1024
      end

      hab.vm.provider :virtualbox do |vb|
        vb.gui = true
        vb.memory = 1024
        vb.network "forwarded_port", guest: 5985, host: 55985
      end
    end
  end

  config.vm.define "haproxy" do |haproxy|
    haproxy.vm.box = "ericmann/trusty64"
    haproxy.vm.provision "shell", inline: $haproxy_script
    haproxy.vm.provider "hyperv" do |hv|
      hv.memory = "512"
      hv.vmname = "haproxy"
    end
  end
end
