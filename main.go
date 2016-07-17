package main

import (
	"fmt"
	"os"
	"github.com/doourbest/sv"
)


type App struct{}

var ThisApp = &App{}

func main() {
	// 注入配置，执行 Cmd
	err := sv.AppRun(ThisApp, os.Args)
	if err != nil {
		panic(fmt.Errorf("AppRun failed, %s",err.Error()).Error())
		return
	}
	return
}


