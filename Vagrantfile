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

$wrapper = @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class LsaWrapper
{
// Import the LSA functions
 
[DllImport("advapi32.dll", PreserveSig = true)]
private static extern UInt32 LsaOpenPolicy(
    ref LSA_UNICODE_STRING SystemName,
    ref LSA_OBJECT_ATTRIBUTES ObjectAttributes,
    Int32 DesiredAccess,
    out IntPtr PolicyHandle
    );
 
[DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
private static extern long LsaAddAccountRights(
    IntPtr PolicyHandle,
    IntPtr AccountSid,
    LSA_UNICODE_STRING[] UserRights,
    long CountOfRights);
 
[DllImport("advapi32")]
public static extern void FreeSid(IntPtr pSid);
 
[DllImport("advapi32.dll", CharSet = CharSet.Auto, SetLastError = true, PreserveSig = true)]
private static extern bool LookupAccountName(
    string lpSystemName, string lpAccountName,
    IntPtr psid,
    ref int cbsid,
    StringBuilder domainName, ref int cbdomainLength, ref int use);
 
[DllImport("advapi32.dll")]
private static extern bool IsValidSid(IntPtr pSid);
 
[DllImport("advapi32.dll")]
private static extern long LsaClose(IntPtr ObjectHandle);
 
[DllImport("kernel32.dll")]
private static extern int GetLastError();
 
[DllImport("advapi32.dll")]
private static extern long LsaNtStatusToWinError(long status);
 
// define the structures
 
private enum LSA_AccessPolicy : long
{
    POLICY_VIEW_LOCAL_INFORMATION = 0x00000001L,
    POLICY_VIEW_AUDIT_INFORMATION = 0x00000002L,
    POLICY_GET_PRIVATE_INFORMATION = 0x00000004L,
    POLICY_TRUST_ADMIN = 0x00000008L,
    POLICY_CREATE_ACCOUNT = 0x00000010L,
    POLICY_CREATE_SECRET = 0x00000020L,
    POLICY_CREATE_PRIVILEGE = 0x00000040L,
    POLICY_SET_DEFAULT_QUOTA_LIMITS = 0x00000080L,
    POLICY_SET_AUDIT_REQUIREMENTS = 0x00000100L,
    POLICY_AUDIT_LOG_ADMIN = 0x00000200L,
    POLICY_SERVER_ADMIN = 0x00000400L,
    POLICY_LOOKUP_NAMES = 0x00000800L,
    POLICY_NOTIFICATION = 0x00001000L
}
 
[StructLayout(LayoutKind.Sequential)]
private struct LSA_OBJECT_ATTRIBUTES
{
    public int Length;
    public IntPtr RootDirectory;
    public readonly LSA_UNICODE_STRING ObjectName;
    public UInt32 Attributes;
    public IntPtr SecurityDescriptor;
    public IntPtr SecurityQualityOfService;
}
 
[StructLayout(LayoutKind.Sequential)]
private struct LSA_UNICODE_STRING
{
    public UInt16 Length;
    public UInt16 MaximumLength;
    public IntPtr Buffer;
}
/// 
//Adds a privilege to an account
 
/// Name of an account - "domain\account" or only "account"
/// Name ofthe privilege
/// The windows error code returned by LsaAddAccountRights
public long SetRight(String accountName, String privilegeName)
{
    long winErrorCode = 0; //contains the last error
 
    //pointer an size for the SID
    IntPtr sid = IntPtr.Zero;
    int sidSize = 0;
    //StringBuilder and size for the domain name
    var domainName = new StringBuilder();
    int nameSize = 0;
    //account-type variable for lookup
    int accountType = 0;
 
    //get required buffer size
    LookupAccountName(String.Empty, accountName, sid, ref sidSize, domainName, ref nameSize, ref accountType);
 
    //allocate buffers
    domainName = new StringBuilder(nameSize);
    sid = Marshal.AllocHGlobal(sidSize);
 
    //lookup the SID for the account
    bool result = LookupAccountName(String.Empty, accountName, sid, ref sidSize, domainName, ref nameSize,
                                    ref accountType);
 
    //say what you're doing
    Console.WriteLine("LookupAccountName result = " + result);
    Console.WriteLine("IsValidSid: " + IsValidSid(sid));
    Console.WriteLine("LookupAccountName domainName: " + domainName);
 
    if (!result)
    {
        winErrorCode = GetLastError();
        Console.WriteLine("LookupAccountName failed: " + winErrorCode);
    }
    else
    {
        //initialize an empty unicode-string
        var systemName = new LSA_UNICODE_STRING();
        //combine all policies
        var access = (int) (
                                LSA_AccessPolicy.POLICY_AUDIT_LOG_ADMIN |
                                LSA_AccessPolicy.POLICY_CREATE_ACCOUNT |
                                LSA_AccessPolicy.POLICY_CREATE_PRIVILEGE |
                                LSA_AccessPolicy.POLICY_CREATE_SECRET |
                                LSA_AccessPolicy.POLICY_GET_PRIVATE_INFORMATION |
                                LSA_AccessPolicy.POLICY_LOOKUP_NAMES |
                                LSA_AccessPolicy.POLICY_NOTIFICATION |
                                LSA_AccessPolicy.POLICY_SERVER_ADMIN |
                                LSA_AccessPolicy.POLICY_SET_AUDIT_REQUIREMENTS |
                                LSA_AccessPolicy.POLICY_SET_DEFAULT_QUOTA_LIMITS |
                                LSA_AccessPolicy.POLICY_TRUST_ADMIN |
                                LSA_AccessPolicy.POLICY_VIEW_AUDIT_INFORMATION |
                                LSA_AccessPolicy.POLICY_VIEW_LOCAL_INFORMATION
                            );
        //initialize a pointer for the policy handle
        IntPtr policyHandle = IntPtr.Zero;
 
        //these attributes are not used, but LsaOpenPolicy wants them to exists
        var ObjectAttributes = new LSA_OBJECT_ATTRIBUTES();
        ObjectAttributes.Length = 0;
        ObjectAttributes.RootDirectory = IntPtr.Zero;
        ObjectAttributes.Attributes = 0;
        ObjectAttributes.SecurityDescriptor = IntPtr.Zero;
        ObjectAttributes.SecurityQualityOfService = IntPtr.Zero;
 
        //get a policy handle
        uint resultPolicy = LsaOpenPolicy(ref systemName, ref ObjectAttributes, access, out policyHandle);
        winErrorCode = LsaNtStatusToWinError(resultPolicy);
 
        if (winErrorCode != 0)
        {
            Console.WriteLine("OpenPolicy failed: " + winErrorCode);
        }
        else
        {
            //Now that we have the SID an the policy,
            //we can add rights to the account.
 
            //initialize an unicode-string for the privilege name
            var userRights = new LSA_UNICODE_STRING[1];
            userRights[0] = new LSA_UNICODE_STRING();
            userRights[0].Buffer = Marshal.StringToHGlobalUni(privilegeName);
            userRights[0].Length = (UInt16) (privilegeName.Length*UnicodeEncoding.CharSize);
            userRights[0].MaximumLength = (UInt16) ((privilegeName.Length + 1)*UnicodeEncoding.CharSize);
 
            //add the right to the account
            long res = LsaAddAccountRights(policyHandle, sid, userRights, 1);
            winErrorCode = LsaNtStatusToWinError(res);
            if (winErrorCode != 0)
            {
                Console.WriteLine("LsaAddAccountRights failed: " + winErrorCode);
            }
 
            LsaClose(policyHandle);
        }
        FreeSid(sid);
    }
 
    return winErrorCode;
}
}
'@
 
Add-Type $wrapper -PassThru

$lsa_wrapper = New-Object -type LsaWrapper
$lsa_wrapper.SetRight("vagrant", "SeAssignPrimaryTokenPrivilege")

secedit /export /cfg $env:temp/export.cfg
((get-content $env:temp/export.cfg) -replace ('PasswordComplexity = 1', 'PasswordComplexity = 0')) | Out-File $env:temp/export.cfg
((get-content $env:temp/export.cfg) -replace ('MinimumPasswordLength = 8', 'MinimumPasswordLength = 0')) | Out-File $env:temp/export.cfg
secedit /configure /db $env:windir/security/new.sdb /cfg $env:temp/export.cfg /areas SECURITYPOLICY

net user /add hab hab
net localgroup administrators hab /add
$lsa_wrapper.SetRight("hab", "SeServiceLogonRight")

New-NetFirewallRule -DisplayName "Habitat TCP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9631,9638,3306,8090
New-NetFirewallRule -DisplayName "Habitat UDP" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 9638

Add-Path "C:/habitat"

[Environment]::SetEnvironmentVariable("HAB_WINDOWS_STUDIO", "1", "Machine")

mkdir "/hab/cache" -ErrorAction SilentlyContinue

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
