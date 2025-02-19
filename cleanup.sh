#!/bin/bash
#
# Script de Manutenção e Limpeza do Sistema Ubuntu
# Versão: 2.2.0
# Autor: mafhper
# Última atualização: 2025-02-19

# ASCII Art Logo
LOGO="
    ████████╗██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗
    ╚══██╔══╝██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║   ██║
       ██║   ██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║   ██║
       ██║   ██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║   ██║
       ██║   ╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║   ██║   ╚██████╔╝
       ╚═╝    ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝    ╚═════╝ 
                     Sistema de Manutenção v2.2.0
"

# Configurações
LOG_FILE="/var/log/manutencao_ubuntu.log"
TEMP_THRESHOLD_DAYS=3
CACHE_THRESHOLD_DAYS=7
LOG_THRESHOLD_DAYS=30

# Cores e estilos
COLOR_RESET='\033[0m'
COLOR_BOLD='\033[1m'
COLOR_GREEN='\033[32m'
COLOR_YELLOW='\033[33m'
COLOR_RED='\033[31m'
COLOR_CYAN='\033[36m'
COLOR_BLUE='\033[34m'
COLOR_MAGENTA='\033[35m'

# Animações
SPINNER="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

# Função de log
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} - $*" | tee -a "$LOG_FILE"
}

# Função para mostrar spinner
show_spinner() {
    local pid=$1
    local message=$2
    local i=0
    while ps -p "$pid" > /dev/null; do
        printf "\r${COLOR_CYAN}[%c]${COLOR_RESET} %s" "${SPINNER:i++%${#SPINNER}:1}" "$message"
        sleep 0.1
    done
    printf "\r${COLOR_GREEN}[✔]${COLOR_RESET} %s\n" "$message"
}

# Função para mostrar progresso
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    printf "\r["
    for ((i = 0; i < width; i++)); do
        if [ $i -lt $filled ]; then
            printf "${COLOR_CYAN}▰${COLOR_RESET}"
        else
            printf "▱"
        fi
    done
    printf "] %3d%%  " "$percentage"
}

# Função para mostrar cabeçalho
show_header() {
    clear
    echo -e "${COLOR_CYAN}${LOGO}${COLOR_RESET}"
    echo -e "${COLOR_BOLD}Data: $(date '+%Y-%m-%d %H:%M:%S')${COLOR_RESET}"
    echo -e "${COLOR_BOLD}Usuário: $(whoami)${COLOR_RESET}"
    echo -e "\n${COLOR_CYAN}═══════════════════════════════════════════════════════════════════${COLOR_RESET}\n"
}

# Função para mostrar menu
show_menu() {
    echo -e "${COLOR_BOLD}Opções Disponíveis:${COLOR_RESET}\n"
    echo -e "  ${COLOR_CYAN}[1]${COLOR_RESET} ⚡ Atualização do Sistema"
    echo -e "      └─ Atualiza pacotes e sistema"
    echo
    echo -e "  ${COLOR_CYAN}[2]${COLOR_RESET} 🧹 Limpeza do Sistema"
    echo -e "      └─ Remove arquivos temporários e cache"
    echo
    echo -e "  ${COLOR_CYAN}[3]${COLOR_RESET} 📊 Verificação do Sistema"
    echo -e "      └─ Analisa estado atual do sistema"
    echo
    echo -e "  ${COLOR_CYAN}[4]${COLOR_RESET} 🚀 Todas as Operações"
    echo -e "      └─ Executa todas as tarefas acima"
    echo
    echo -e "  ${COLOR_CYAN}[0]${COLOR_RESET} ❌ Sair"
    echo
    echo -e "${COLOR_CYAN}═══════════════════════════════════════════════════════════════════${COLOR_RESET}\n"
}

# Função para atualizar sistema
update_system() {
    log "${COLOR_CYAN}Iniciando atualização do sistema..."
    
    echo -n "Atualizando lista de pacotes... "
    apt update -y &> /tmp/apt_update.log &
    show_spinner $! "Atualizando lista de pacotes"
    
    echo -n "Instalando atualizações... "
    apt upgrade -y &> /tmp/apt_upgrade.log &
    show_spinner $! "Instalando atualizações"
    
    log "${COLOR_GREEN}Atualização do sistema concluída!"
}

# Função para limpar sistema
clean_system() {
    log "${COLOR_CYAN}Iniciando limpeza do sistema..."
    local steps=4
    local current=0
    
    ((current++))
    echo -n "Limpando cache do APT... "
    apt clean -y &> /dev/null &
    show_spinner $! "Limpando cache do APT"
    show_progress $current $steps
    
    ((current++))
    echo -n "Removendo arquivos temporários... "
    find /tmp -type f -atime +$TEMP_THRESHOLD_DAYS -delete &> /dev/null &
    show_spinner $! "Removendo arquivos temporários"
    show_progress $current $steps
    
    ((current++))
    echo -n "Limpando logs antigos... "
    find /var/log -type f -name "*.log" -mtime +$LOG_THRESHOLD_DAYS -delete &> /dev/null &
    show_spinner $! "Limpando logs antigos"
    show_progress $current $steps
    
    ((current++))
    echo -n "Limpando cache do sistema... "
    apt autoclean -y &> /dev/null &
    show_spinner $! "Limpando cache do sistema"
    show_progress $current $steps
    
    log "${COLOR_GREEN}Limpeza do sistema concluída!"
}

# Função para verificar sistema
check_system() {
    log "${COLOR_CYAN}Iniciando verificação do sistema..."
    
    echo -e "\n${COLOR_BOLD}Uso do Disco:${COLOR_RESET}"
    df -h / | awk 'NR==1{print} NR==2{print}'
    
    echo -e "\n${COLOR_BOLD}Uso de Memória:${COLOR_RESET}"
    free -h | head -n 2
    
    echo -e "\n${COLOR_BOLD}Processos mais pesados:${COLOR_RESET}"
    ps aux --sort=-%mem | head -n 6
    
    log "${COLOR_GREEN}Verificação do sistema concluída!"
}

# Função principal
main() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${COLOR_RED}Este script precisa ser executado como root (sudo)${COLOR_RESET}"
        exit 1
    fi
    
    while true; do
        show_header
        show_menu
        
        read -p "Digite sua escolha [0-4]: " choice
        echo
        
        case $choice in
            1) update_system ;;
            2) clean_system ;;
            3) check_system ;;
            4)
                update_system
                clean_system
                check_system
                ;;
            0)
                echo -e "${COLOR_GREEN}Obrigado por usar o Sistema de Manutenção!${COLOR_RESET}"
                exit 0
                ;;
            *)
                echo -e "${COLOR_RED}Opção inválida!${COLOR_RESET}"
                sleep 2
                ;;
        esac
        
        echo -e "\n${COLOR_CYAN}Pressione ENTER para continuar...${COLOR_RESET}"
        read -r
    done
}

# Iniciar script
main "$@"
