package main

import (
	"github.com/gin-gonic/gin"
	"github.com/doourbest/sv"
)


type serveConf struct {
	Listen  string
	AutoRestart bool
	AutoBuild bool
	GinMode string
	PidFile string
}

func (this*App) CmdServe(options struct{
	Flag_pid_file string
	Server serveConf `src:"conf/server.toml"`
}) {


	conf := &options.Server
	gin.SetMode(conf.GinMode)
	r := gin.New()
	r.Use(gin.Recovery())

	route(r)

	sv.GraceOptions.AutoRestart = conf.AutoRestart
	sv.GraceOptions.AutoBuild   = conf.AutoBuild
	// write pid file before begin
	beforeBegin := func(addr string) {
		if len(options.Flag_pid_file)>0 {
			sv.AppWritePidFile(options.Flag_pid_file)
		}
	}
	if err:=sv.GraceListenAndServe(conf.Listen, r, beforeBegin); err!=nil {
		sv.Log.Info("serve error.", err)
	}
}


