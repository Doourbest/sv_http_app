#!/bin/bash

# perform restart during package upgrade

source $(dirname ${BASH_SOURCE[0]})/common.bashrc

graceful_restart_process

