# golang http 应用程序模板

## 特性

- 标准化包目录结构，自动生成用于一键部署的 RPM 包
- 支持自动安装 crontab
- 支持进程异常退出监控和自动重新拉起异常退出的进程
- 模板默认使用 [gin web 框架](https://github.com/gin-gonic/gin) 并封装了 [go-sv 库](http://gitlab.valsun.cn/mayuanpeng/go-sv) 实现 HTTP Server 平滑重启，自动重启（可选），自动编译代码（可选）的功能。


## 使用

### 新建项目并生成 RPM 包

复制模板 `cp sv_http_template $your_dir/$you_app_name`。重新配置 git，`cd $your_dir/$you_app_name && rm -rf .gi && git init` ...

执行 `./build.sh` 生成 RPM 包。

打正式包前请编辑 `package/build.spec`，确认你的配置正确（比如 `Version` 版本号，`Summary` 说明这些）

生成的 RPM 包的典型目录结构：

```text
[mayuanpeng@201-123 sv_http_template]$ rpm -qpvl ~/rpmbuild/RPMS/x86_64/sv_http_template-0.0.1-1.el6.x86_64.rpm 
drwxr-xr-x    2 goapp   goapp                       0 May 30 11:18 /data/goapp/sv_http_template
drwxr-xr-x    2 goapp   goapp                       0 May 30 11:18 /data/goapp/sv_http_template/admin
-rwxr-xr-x    1 goapp   goapp                     965 May 30 11:18 /data/goapp/sv_http_template/admin/check_process.sh
-rwxr-xr-x    1 goapp   goapp                    1549 May 30 11:18 /data/goapp/sv_http_template/admin/restart.sh
-rwxr-xr-x    1 goapp   goapp                    1290 May 30 11:18 /data/goapp/sv_http_template/admin/start.sh
-rwxr-xr-x    1 goapp   goapp                    1478 May 30 11:18 /data/goapp/sv_http_template/admin/stop.sh
drwxr-xr-x    2 goapp   goapp                       0 May 30 11:18 /data/goapp/sv_http_template/bin
-rwxr-xr-x    1 goapp   goapp                 9184073 May 30 11:18 /data/goapp/sv_http_template/bin/sv_http_template
drwxr-xr-x    2 goapp   goapp                       0 May 30 11:18 /data/goapp/sv_http_template/conf
-rwxr-xr-x    1 goapp   goapp                     105 May 30 11:18 /data/goapp/sv_http_template/conf/server.json
drwxr-xr-x    2 goapp   goapp                       0 May 30 11:18 /data/goapp/sv_http_template/data
drwxr-xr-x    2 goapp   goapp                       0 May 30 11:18 /data/goapp/sv_http_template/log
```

### 新的 crontab 任务

增加文件 `cmd/hello.go`，代码自己写

在 `package/build.spec` 中找到这段代码

```
# TODO 编辑这里加入需要自动安装的 crontab{
echo '
# monitor the running process
* * * * * %{app_install_home}/admin/check_process.sh
'
# }
```

然后再 check_process.sh 之后增加一行配置 `* * * * * %{app_install_home}/bin/hello` 即可。

