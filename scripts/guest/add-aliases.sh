# Aliases for common commands
alias dc="docker-compose"
alias stop="docker-compose stop"
alias start="docker-compose start"
alias restart="docker-compose restart"
alias rebuild="docker-compose up --build -d "
alias remove="docker-compose rm -v -f "
alias logs="docker-compose logs"
alias exec="docker-compose exec"
alias status="docker-compose ps"
alias psql="docker-compose exec postgres psql -h postgres -U root -d "

function bashin(){
    docker exec -it ${@:1} bash
}

function unit-test(){
    docker-compose exec ${1} python3 manage.py unittest ${2}
}

function integration-test(){
    docker-compose exec ${1} python3 manage.py integrationtest
}

function manage(){
    docker-compose exec ${1} python3 manage.py ${@:2}
}

function devenv-help(){
  cat <<EOF
    If typing a docker-compose command you can use the alias dc instead. For example "dc ps" rather than "docker-compose ps".

    status                                           -     to view the status of all running containers
    stop <name of container>                         -     to stop a container
    start <name of container>                        -     to start a container
    restart <name of container>                      -     to restart a container
    logs <name of container>                         -     to view the logs of a container
    exec <name of container> <command to execute>    -     to execute a command in a running container
    remove <name of container>                       -     to remove a container
    rebuild <name of container>                      -     to rebuild a container and run it in the background
    bashin <name of container>                       -     to bash in to a container
    unit-test <name of container>                    -     to run the unit tests for an application (this expects there
                                                           to a be a manage.py with a unittest command)
    integration-test <name of container>             -     to run the integration tests for an application (this expects
                                                           there to a be a manage.py with a integrationtest command)
    psql <name of database>                          -     to run psql in the postgres container
    manage <name of container> <command>             -     to run manage.py commands in a container
EOF
}

# Automatically add completion for all aliases to commands having completion functions
function alias_completion {
    local namespace="alias_completion"

    # parse function based completion definitions, where capture group 2 => function and 3 => trigger
    local compl_regex='complete( +[^ ]+)* -F ([^ ]+) ("[^"]+"|[^ ]+)'
    # parse alias definitions, where capture group 1 => trigger, 2 => command, 3 => command arguments
    local alias_regex="alias ([^=]+)='(\"[^\"]+\"|[^ ]+)(( +[^ ]+)*)'"

    # create array of function completion triggers, keeping multi-word triggers together
    eval "local completions=($(complete -p | sed -Ene "/$compl_regex/s//'\3'/p"))"
    (( ${#completions[@]} == 0 )) && return 0

    # create temporary file for wrapper functions and completions
    rm -f "/tmp/${namespace}-*.tmp" # preliminary cleanup
    local tmp_file; tmp_file="$(mktemp "/tmp/${namespace}-${RANDOM}XXX.tmp")" || return 1

    local completion_loader; completion_loader="$(complete -p -D 2>/dev/null | sed -Ene 's/.* -F ([^ ]*).*/\1/p')"

    # read in "<alias> '<aliased command>' '<command args>'" lines from defined aliases
    local line; while read line; do
        eval "local alias_tokens; alias_tokens=($line)" 2>/dev/null || continue # some alias arg patterns cause an eval parse error
        local alias_name="${alias_tokens[0]}" alias_cmd="${alias_tokens[1]}" alias_args="${alias_tokens[2]# }"

        # skip aliases to pipes, boolean control structures and other command lists
        # (leveraging that eval errs out if $alias_args contains unquoted shell metacharacters)
        eval "local alias_arg_words; alias_arg_words=($alias_args)" 2>/dev/null || continue
        # avoid expanding wildcards
        read -a alias_arg_words <<< "$alias_args"

        # skip alias if there is no completion function triggered by the aliased command
        if [[ ! " ${completions[*]} " =~ " $alias_cmd " ]]; then
            if [[ -n "$completion_loader" ]]; then
                # force loading of completions for the aliased command
                eval "$completion_loader $alias_cmd"
                # 124 means completion loader was successful
                [[ $? -eq 124 ]] || continue
                completions+=($alias_cmd)
            else
                continue
            fi
        fi
        local new_completion="$(complete -p "$alias_cmd")"

        # create a wrapper inserting the alias arguments if any
        if [[ -n $alias_args ]]; then
            local compl_func="${new_completion/#* -F /}"; compl_func="${compl_func%% *}"
            # avoid recursive call loops by ignoring our own functions
            if [[ "${compl_func#_$namespace::}" == $compl_func ]]; then
                local compl_wrapper="_${namespace}::${alias_name}"
                    echo "function $compl_wrapper {
                        (( COMP_CWORD += ${#alias_arg_words[@]} ))
                        COMP_WORDS=($alias_cmd $alias_args \${COMP_WORDS[@]:1})
                        (( COMP_POINT -= \${#COMP_LINE} ))
                        COMP_LINE=\${COMP_LINE/$alias_name/$alias_cmd $alias_args}
                        (( COMP_POINT += \${#COMP_LINE} ))
                        $compl_func
                    }" >> "$tmp_file"
                    new_completion="${new_completion/ -F $compl_func / -F $compl_wrapper }"
            fi
        fi

        # replace completion trigger by alias
        new_completion="${new_completion% *} $alias_name"
        echo "$new_completion" >> "$tmp_file"
    done < <(alias -p | sed -Ene "s/$alias_regex/\1 '\2' '\3'/p")
    source "$tmp_file" && rm -f "$tmp_file"
}; alias_completion
