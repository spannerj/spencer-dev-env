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

# Runs a command in the nicest way, outputting to the console. Using system sometimes causes the console to stop outputting until a key is pressed.
def run_command(cmd)
    exitcode = -1
    Open3.popen2e(cmd) do |stdin, stdout_and_stderr, wait_thr|
        stdout_and_stderr.each_line do |line|
            puts line
        end
        exitcode = wait_thr.value.exitstatus
    end
    return exitcode
end