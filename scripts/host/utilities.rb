#!/usr/bin/env ruby

def colorize_lightblue(str)
    "\e[36m#{str}\e[0m"
end

def colorize_red(str)
    "\e[31m#{str}\e[0m"
end

def colorize_yellow(str)
    "\e[33m#{str}\e[0m"
end

def colorize_green(str)
    "\e[32m#{str}\e[0m"
end

def colorize_pink(str)
    "\e[35m#{str}\e[0m"
end