%define app_install_home  /data/goapp/%{app_name}
%define app_user          goapp
%define app_group         goapp

Name:		%{app_name}
Version:	0.0.1
Release:	1%{?dist}
Summary:	simple http server

# Group:		
License:	Sailvan
# URL:		
Source0:	http://gitlab.valsun.cn/
# 
# BuildRequires:	
# Requires:	

%description
simple http server

%prep
rm -rf *
cp -r %{app_source_dir}/* ./

%build
true

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{app_install_home}/
mkdir -p $RPM_BUILD_ROOT/%{app_install_home}/data
mkdir -p $RPM_BUILD_ROOT/%{app_install_home}/log
cp -r bin  $RPM_BUILD_ROOT/%{app_install_home}/
cp -r admin  $RPM_BUILD_ROOT/%{app_install_home}/
cp -r conf  $RPM_BUILD_ROOT/%{app_install_home}/


%files
%attr(755, %{app_user}, %{app_group}) %{app_install_home}

%pre
/usr/bin/getent group  %{app_group} || /usr/sbin/groupadd -r %{app_group}
/usr/bin/getent passwd %{app_user}  || /usr/sbin/useradd  -g %{app_group}  %{app_user}

%post
echo "installing crontab..."
crontab -u %{app_user} -l | sed '/###goapp_%{app_name}{/,/###goapp_%{app_name}}/ d' | {
cat
echo '###goapp_%{app_name}{'
echo '# the following section is automatically installed by rpm, please do not modify it manually'

# TODO 编辑这里加入需要自动安装的 crontab{
echo '
# monitor the running process
* * * * * %{app_install_home}/admin/check_process.sh
'
# }

echo '###goapp_%{app_name}}'
} | crontab -u %{app_user} -

%preun
echo "stoping the process..."
runuser -l goapp -c %{app_install_home}/admin/stop.sh
echo "uninstalling crontab..."
crontab -u %{app_user} -l | sed '/###goapp_%{app_name}{/,/###goapp_%{app_name}}/ d' | crontab -u %{app_user} -

%changelog

