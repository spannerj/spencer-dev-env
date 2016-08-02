# Aliases for common commands
alias stop="docker-compose stop"
alias start="docker-compose start"
alias restart="docker-compose restart"
alias rebuild="docker-compose up --build -d "
alias remove="docker-compose rm -v -f "

function bashin(){
    docker exec -it ${@:1} bash
}