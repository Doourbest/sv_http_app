package main

import (
	"github.com/gin-gonic/gin"
	"github.com/doourbest/sv"
)

func route(r *gin.Engine) {
	sv.GinRouteStructMethods(r, &Test{})
}

type Test struct {
}

func (*Test) Foo(ctx* gin.Context) {
	ctx.JSON(200,map[string]string{
			"message": "Hello world",
		})
}

