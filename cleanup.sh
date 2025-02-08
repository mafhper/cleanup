#!/bin/bash



# Script de Manutenção e Limpeza do Sistema Ubuntu - Interativo, Verboso, Menu Agrupado e Output Colorido



# *** Configurações ***

LOG_FILE="/var/log/manutencao_ubuntu.log"

TEMP_THRESHOLD_DAYS=3

CACHE_THRESHOLD_DAYS=7

LOG_THRESHOLD_DAYS=30

CACHE_NAVEGADOR=true # Limpar cache do navegador por padrão



# *** Códigos de Cores ANSI ***

COLOR_RESET='\033[0m' # Resetar cor

COLOR_BOLD='\033[1m' # Negrito

COLOR_GREEN='\033[32m' # Verde

COLOR_YELLOW='\033[33m' # Amarelo

COLOR_RED='\033[31m' # Vermelho

COLOR_CYAN='\033[36m' # Ciano

COLOR_BLUE='\033[34m' # Azul



# *** Separadores ***

SEPARATOR_LINE="${COLOR_CYAN}-------------------------------------------------------${COLOR_RESET}"

SEPARATOR_SECTION="${COLOR_BLUE}=======================================================${COLOR_RESET}"

SEPARATOR_SUBTASK="${COLOR_YELLOW}--------------------${COLOR_RESET}"





# *** Funções Utilitárias ***

log() {

local color="$1"

shift

local message="$*"

if [[ -n "$color" ]]; then

echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${color}${message}${COLOR_RESET}" >> "$LOG_FILE"

echo -e "${color}${message}${COLOR_RESET}"

else

echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" >> "$LOG_FILE"

echo "$message"

fi

}



check_root() {

if [[ "$EUID" -ne 0 ]]; then

log "$COLOR_RED""ERRO: Este script precisa ser executado com privilégios de root (sudo).""$COLOR_RESET"

exit 1

fi

}



# *** Funções de Manutenção ***



atualizar_pacotes() {

log "$COLOR_GREEN"" -> Iniciando atualização dos pacotes do sistema (apt update e upgrade)...""$COLOR_RESET"

apt update -y &>> "$LOG_FILE"

apt upgrade -y &>> "$LOG_FILE"

log "$COLOR_GREEN"" -> Concluído: Atualização dos pacotes do sistema.""$COLOR_RESET"

}



limpar_apt() {

log "$COLOR_GREEN"" -> Iniciando limpeza do APT (autoremove, autoclean, clean)...""$COLOR_RESET"

apt autoremove -y &>> "$LOG_FILE"

apt autoclean -y &>> "$LOG_FILE"

apt clean -y &>> "$LOG_FILE"

log "$COLOR_GREEN"" -> Concluído: Limpeza do APT.""$COLOR_RESET"

}



limpar_temporarios() {

log "$COLOR_GREEN"" -> Iniciando limpeza de arquivos temporários em /tmp e /var/tmp (mais de $TEMP_THRESHOLD_DAYS dias)...""$COLOR_RESET"

find /tmp /var/tmp -type f -atime +"$TEMP_THRESHOLD_DAYS" -delete

log "$COLOR_GREEN"" -> Concluído: Limpeza de arquivos temporários.""$COLOR_RESET"

}



limpar_logs() {

log "$COLOR_GREEN"" -> Iniciando limpeza de arquivos de log antigos em /var/log (mais de $LOG_THRESHOLD_DAYS dias)...""$COLOR_RESET"

find /var/log -type f -name "*.log" -mtime +"$LOG_THRESHOLD_DAYS" -delete

log "$COLOR_GREEN"" -> Concluído: Limpeza de arquivos de log.""$COLOR_RESET"

}



limpar_cache_navegador() {

if [[ "$CACHE_NAVEGADOR" == true ]]; then

log "$COLOR_GREEN"" -> Iniciando limpeza de cache de navegadores (Firefox e Chrome/Chromium)...""$COLOR_RESET"

rm -rf ~/.cache/mozilla/firefox/*/cache2 2>/dev/null

rm -rf ~/.cache/google-chrome/*/Cache 2>/dev/null

rm -rf ~/.config/chromium/*/Cache 2>/dev/null

rm -rf ~/.cache/chromium/*/Cache 2>/dev/null

log "$COLOR_GREEN"" -> Concluído: Limpeza de cache de navegadores.""$COLOR_RESET"

else

log "$COLOR_YELLOW"" -> AVISO: Limpeza de cache de navegadores desativada (configuração).""$COLOR_RESET"

fi

}



limpar_cache_miniaturas() {

log "$COLOR_GREEN"" -> Iniciando limpeza do cache de miniaturas (~/.cache/thumbnails)...""$COLOR_RESET"

rm -rf ~/.cache/thumbnails/* 2>/dev/null

log "$COLOR_GREEN"" -> Concluído: Limpeza do cache de miniaturas.""$COLOR_RESET"

}



verificar_espaco_disco() {

log "$COLOR_GREEN"" -> Iniciando verificação de espaço em disco (df -h)...""$COLOR_RESET"

df -h &>> "$LOG_FILE"

log "$COLOR_GREEN"" -> Concluído: Verificação de espaço em disco. Resultados detalhados no log.""$COLOR_RESET"

}



# *** Função para exibir o menu agrupado e obter a seleção do usuário ***

mostrar_menu_e_obter_selecao() {

echo ""

echo -e "${SEPARATOR_SECTION}"

echo -e "${COLOR_BOLD}${COLOR_CYAN}MENU DE MANUTENÇÃO DO SISTEMA - AGRUPADO${COLOR_RESET}"

echo -e "${SEPARATOR_SECTION}"

echo ""

echo "Selecione as categorias desejadas digitando os números separados por espaço:"

echo ""

echo -e "${COLOR_BOLD}1 - Tarefas de Atualização do Sistema${COLOR_RESET}"

echo " (Atualizar lista de pacotes e pacotes instalados)"

echo -e "${COLOR_BOLD}2 - Tarefas de Limpeza de Cache${COLOR_RESET}"

echo " (APT, Temporários, Navegadores, Miniaturas)"

echo -e "${COLOR_BOLD}3 - Tarefas de Limpeza de Logs${COLOR_RESET}"

echo " (Arquivos de log antigos)"

echo -e "${COLOR_BOLD}4 - Verificação de Espaço em Disco${COLOR_RESET}"

echo " (Exibir uso do disco)"

echo -e "${COLOR_BOLD}5 - Executar TODAS as Tarefas de Manutenção (1, 2, 3 e 4)${COLOR_RESET}"

echo -e "${COLOR_BOLD}0 - Sair sem executar nenhuma manutenção${COLOR_RESET}"

echo ""

read -p "Categorias selecionadas (ex: 1 2 ou 5 para tudo, 0 para sair): " escolhas



# Validar a entrada (agora de 0 a 5)

if [[ -z "$escolhas" ]]; then

log "$COLOR_YELLOW""Nenhuma opção selecionada. Saindo.""$COLOR_RESET"

exit 0

fi



for escolha in $escolhas; do

if ! [[ "$escolha" =~ ^[0-5]+$ ]]; then

log "$COLOR_RED""ERRO: Opção inválida detectada: '$escolha'. Use apenas números de 0 a 5 e espaços.""$COLOR_RESET"

mostrar_menu_e_obter_selecao # Recursividade

return 1 # Indica erro

fi

if [[ "$escolha" -lt 0 || "$escolha" -gt 5 ]]; then

log "$COLOR_RED""ERRO: Opção '$escolha' fora do intervalo válido (0-5).""$COLOR_RESET"

mostrar_menu_e_obter_selecao # Recursividade

return 1 # Indica erro

fi

done



echo ""

return 0 # Indica sucesso

}





# *** Execução Principal ***



check_root



log "$COLOR_CYAN""--- INÍCIO DO SCRIPT DE MANUTENÇÃO DO UBUNTU ---""$COLOR_RESET"



mostrar_menu_e_obter_selecao



if [[ $? -eq 0 ]]; then # Se mostrar_menu_e_obter_selecao retornou sucesso (0)

IFS=' ' read -r -a OPCOES <<< "$escolhas" # Transforma a string de escolhas em array



log "$SEPARATOR_SECTION"

log "$COLOR_BOLD""--- INICIANDO TAREFAS SELECIONADAS ---""$COLOR_RESET"

log "$SEPARATOR_SECTION"



for opcao in "${OPCOES[@]}"; do

case "$opcao" in

1)

log "$SEPARATOR_SUBTASK"

log "$COLOR_BOLD""-- Iniciando Tarefas de Atualização do Sistema --""$COLOR_RESET"

log "$SEPARATOR_SUBTASK"

atualizar_pacotes

log "$SEPARATOR_SUBTASK"

log "$COLOR_BOLD""-- Concluído Tarefas de Atualização do Sistema --""$COLOR_RESET"

log "$SEPARATOR_SUBTASK"

;;

2)

log "$SEPARATOR_SUBTASK"

log "$COLOR_BOLD""-- Iniciando Tarefas de Limpeza de Cache --""$COLOR_RESET"

log "$SEPARATOR_SUBTASK"

limpar_apt

limpar_temporarios

limpar_cache_navegador

limpar_cache_miniaturas

log "$SEPARATOR_SUBTASK"

log "$COLOR_BOLD""-- Concluído Tarefas de Limpeza de Cache --""$COLOR_RESET"

log "$SEPARATOR_SUBTASK"

;;

3)

log "$SEPARATOR_SUBTASK"

log "$COLOR_BOLD""-- Iniciando Tarefas de Limpeza de Logs --""$COLOR_RESET"

log "$SEPARATOR_SUBTASK"

limpar_logs

log "$SEPARATOR_SUBTASK"

log "$COLOR_BOLD""-- Concluído Tarefas de Limpeza de Logs --""$COLOR_RESET"

log "$SEPARATOR_SUBTASK"

;;

4)

log "$SEPARATOR_SUBTASK"

log "$COLOR_BOLD""-- Iniciando Verificação de Espaço em Disco --""$COLOR_RESET"

log "$SEPARATOR_SUBTASK"

verificar_espaco_disco

log "$SEPARATOR_SUBTASK"

log "$COLOR_BOLD""-- Concluído Verificação de Espaço em Disco --""$COLOR_RESET"

log "$SEPARATOR_SUBTASK"

;;

5)

log "$SEPARATOR_SUBTASK"

log "$COLOR_BOLD""-- Iniciando TODAS as Tarefas de Manutenção --""$COLOR_RESET"

log "$SEPARATOR_SUBTASK"

atualizar_pacotes

limpar_apt

limpar_temporarios

limpar_cache_navegador

limpar_cache_miniaturas

limpar_logs

verificar_espaco_disco

log "$SEPARATOR_SUBTASK"

log "$COLOR_BOLD""-- Concluído TODAS as Tarefas de Manutenção --""$COLOR_RESET"

log "$SEPARATOR_SUBTASK"

;;

0) log "$COLOR_YELLOW""Saindo do script conforme solicitado.""$COLOR_RESET"; exit 0 ;;

*) log "$COLOR_RED""Opção inválida (erro interno do script).""$COLOR_RESET"; ;; # Não deve acontecer devido à validação

esac

done



log "$SEPARATOR_SECTION"

log "$COLOR_BOLD""--- TAREFAS SELECIONADAS CONCLUÍDAS ---""$COLOR_RESET"

log "$SEPARATOR_SECTION"

fi





log "$COLOR_CYAN""--- FIM DO SCRIPT DE MANUTENÇÃO DO UBUNTU ---""$COLOR_RESET"



exit 0
