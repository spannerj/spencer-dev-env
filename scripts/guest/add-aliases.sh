# Aliases for common commands
alias dc="docker-compose"
alias stop="docker-compose stop"
alias start="docker-compose start"
alias restart="docker-compose restart"
alias rebuild="docker-compose up --build -d"
alias remove="docker-compose rm -v -f"
alias logs="docker-compose logs"
alias exec="docker-compose exec"
alias status="docker-compose ps"
alias run="docker-compose run --rm"
alias psql="docker-compose exec postgres psql -h postgres -U root -d"
alias db2="docker exec -u db2inst1 db2 bash -c '~/sqllib/bin/db2'"

function bashin(){
    docker exec -it ${@:1} bash
}

function unit-test(){
    reportflag=off
    app_name=${1}

    # Check if there's a -r argument (the only one supported) and set a flag if so
    shift
    while [ $# -gt 0 ]
    do
       case "$1" in
           -r)  reportflag=on;;
           *)
               echo >&2 "usage: unit-test <container_name> [-r]"
    	        return;;
       esac
       shift
    done

    # If the report flag is set generate report output otherwise just run the tests
    if [ "$reportflag" = on ] ; then
       docker-compose exec $app_name make report="true" unittest
    else
       docker-compose exec $app_name make unittest
    fi
}

function integration-test(){
    docker-compose exec ${1} make integrationtest
}

function acceptance-test(){
    docker-compose run --rm acceptance-tests ./run_tests.sh
}

function manage(){
    docker-compose exec ${1} python3 manage.py ${@:2}
}

function alembic(){
    docker-compose exec ${1} bash -c 'cd /src && export SQL_USE_ALEMBIC_USER=yes && export SQL_PASSWORD=superroot && python3 manage.py db '"${@:2}"''
}

function devenv-help(){
  cat <<EOF
    If typing a docker-compose command you can use the alias dc instead. For example "dc ps" rather than "docker-compose ps".

    status                                           -     view the status of all running containers
    stop <name of container>                         -     stop a container
    start <name of container>                        -     start a container
    restart <name of container>                      -     restart a container
    logs <name of container>                         -     view the logs of a container
    exec <name of container> <command to execute>    -     execute a command in a running container
    run <options> <name of container> <command>      -     creates a new container and runs the command in it
    remove <name of container>                       -     remove a container
    rebuild <name of container>                      -     rebuild a container and run it in the background
    bashin <name of container>                       -     bash in to a container
    unit-test <name of container> [-r]               -     run the unit tests for an application (this expects there to a be a Makefile with a unittest command).
                                                           if you add -r it will output reports to the test-output folder.
    integration-test <name of container>             -     run the integration tests for an application (this expects there to a be a Makefile with a integrationtest command)
    acceptance-test                                  -     run the acceptance tests. It expects the repo to be called acceptance-tests and there to be a run_tests.sh
    psql <name of database>                          -     run psql in the postgres container
    db2                                              -     run db2 command line in the db2 container
    manage <name of container> <command>             -     run manage.py commands in a container
    alembic <name of container> <command>            -     run an alembic db command in a container, with the appropriate environment variables preset
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
