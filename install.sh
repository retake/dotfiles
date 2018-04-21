#!/bin/bash
set -x

cd $( dirname ${0} )

sh -x install_env.sh && sh -x install_app.sh

