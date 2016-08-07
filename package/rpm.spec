%define app_install_home  /data/goapp/%{app_name}
%define app_user          goapp
%define app_group         goapp

Name:		%{app_name}
Version:	0.9.2
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
cp -r bin  $RPM_BUILD_ROOT/%{app_install_home}/bin
cp -r admin  $RPM_BUILD_ROOT/%{app_install_home}/admin
cp -r conf  $RPM_BUILD_ROOT/%{app_install_home}/conf


%files
%attr(755, %{app_user}, %{app_group}) %{app_install_home}/data
%attr(755, %{app_user}, %{app_group}) %{app_install_home}/log
%attr(755, %{app_user}, %{app_group}) %{app_install_home}/bin
%attr(755, %{app_user}, %{app_group}) %{app_install_home}/admin
%attr(755, %{app_user}, %{app_group}) %{app_install_home}/conf
# configuration files, do not replace them if they've been modifyed during upgrade.
%config(noreplace) %{app_install_home}/conf/*

%pre
/usr/bin/getent group  %{app_group} 1>/dev/null 2>/dev/null || {
	# automatically create the group
	echo /usr/sbin/groupadd -r %{app_group}
	/usr/sbin/groupadd -r %{app_group}
}
/usr/bin/getent passwd %{app_user}  1>/dev/null 2>/dev/null || {
	# automatically create the user
	echo /usr/sbin/useradd  -g %{app_group} %{app_user}
	/usr/sbin/useradd  -g %{app_group} %{app_user}
	# install limit for app_user
	echo '%{app_user}       soft    nofile     8192' >> /etc/security/limits.d/%{app_user}.conf
	echo '%{app_user}       hard    nofile     20480' >> /etc/security/limits.d/%{app_user}.conf
}

%post

# TODO 编辑这里加入需要自动安装的 crontab
app_crontab='
# monitor the running process
* * * * * %{app_install_home}/admin/check_process.sh
'

# Uninstall previous crontab, and install new crontab
# The 2>/dev/null is important so that you don't get the no crontab 
# for username message that some *nixes produce if there are currently no crontab entries
echo "installing crontab..."
crontab -u %{app_user} -l 2>/dev/null |  {
	sed  '/###goapp_%{app_name}{/,/###goapp_%{app_name}}/ d'
	echo '###goapp_%{app_name}{'
	echo '# the following section is automatically installed by rpm, please do not modify it manually'
	echo "$app_crontab"
	echo '###goapp_%{app_name}}'
} | crontab -u %{app_user} -


# 1 for install
# 2 for upgrade
if [ "$1" == "2" ]; then
	runuser -l %{app_user} -c %{app_install_home}/admin/upgrade_restart.sh
fi

%preun

# 0 for uninstall
# 1 for upgrade
if [ "$1" == "0" ]; then
	echo "stoping the process... $1"
	runuser -l %{app_user} -c %{app_install_home}/admin/stop.sh
	echo "uninstalling crontab..."
	crontab -u %{app_user} -l | sed '/###goapp_%{app_name}{/,/###goapp_%{app_name}}/ d' | crontab -u %{app_user} -
fi

%changelog

