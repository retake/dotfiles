#!/bin/bash -x

ansi_escape=$'\E'
red_color=${ansi_escape}"\[31m"
green_color=${ansi_escape}"\[32m"
yellow_color=${ansi_escape}"\[33m"
purple_color=${ansi_escape}"\[34m"
pink_color=${ansi_escape}"\[35m"
blue_color=${ansi_escape}"\[36m"
end_color=${ansi_escape}"\[m"


function remove_color() {
  sed -E "s/${ansi_escape}\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g"
}

function set_color() {
  sed -E "s/(.*)/${red_color}\1${end_color}/g"
}


echo $1 | remove_color | set_color
