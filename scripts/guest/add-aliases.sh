# Aliases for common commands
alias stop="docker-compose stop"
alias start="docker-compose start"
alias restart="docker-compose restart"
alias rebuild="docker-compose up --build -d "
alias remove="docker-compose rm -v -f "
alias logs="docker-compose logs"
alias exec="docker-compose exec"

function bashin(){
    docker exec -it ${@:1} bash
}
