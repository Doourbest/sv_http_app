package main

import (
	"flag"
	"io/ioutil"
	"encoding/json"
	"github.com/gin-gonic/gin"
	"github.com/doourbest/sv"
)

var config struct {
	Listen  string
	AutoRestart bool
	AutoBuild bool
	GinMode string
}

func main() {

	// read config
	content, e := ioutil.ReadFile(sv.AppConfDir()+"/server.json")
	if e != nil {
		panic(e)
	}
	e = json.Unmarshal(content,&config)
	if e!=nil {
		panic(e)
	}

	var pid_file = flag.String("pid_file", "", "pid file")
	flag.Parse()

	// 写入 pid 文件
	if len(*pid_file)>0 {
		sv.AppWritePidFile(*pid_file)
	}

	// gin
	gin.SetMode(config.GinMode)
	r := gin.New()
	r.Use(gin.Recovery())

	route(r)

	sv.GraceOptions.AutoRestart = config.AutoRestart
	sv.GraceOptions.AutoBuild   = config.AutoBuild
	err := sv.GraceListenAndServe(config.Listen, r)
	if err != nil {
		sv.Log.Info("serve error.", err)
	}
}

