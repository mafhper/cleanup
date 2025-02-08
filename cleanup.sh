#!/bin/bash

# Script de Manutenção e Limpeza do Sistema Ubuntu - Interativo, Verboso, Menu Agrupado e Output Colorido
# Versão com Resumo de Execução - CORRIGIDA e MELHORADA (Resumo Formatado com Métricas)

# *** Configurações ***
LOG_FILE="/var/log/manutencao_ubuntu.log"
TEMP_THRESHOLD_DAYS=3
CACHE_THRESHOLD_DAYS=7
LOG_THRESHOLD_DAYS=30
CACHE_NAVEGADOR=true # Limpar cache do navegador por padrão

# *** Códigos de Cores ANSI ***
COLOR_RESET='\033[0m'       # Resetar cor
COLOR_BOLD='\033[1m'        # Negrito
COLOR_GREEN='\033[32m'       # Verde
COLOR_YELLOW='\033[33m'      # Amarelo
COLOR_RED='\033[31m'         # Vermelho
COLOR_CYAN='\033[36m'        # Ciano
COLOR_BLUE='\033[34m'        # Azul

# *** Separadores ***
SEPARATOR_LINE="${COLOR_CYAN}-------------------------------------------------------${COLOR_RESET}"
SEPARATOR_SECTION="${COLOR_BLUE}=======================================================${COLOR_RESET}"
SEPARATOR_SUBTASK="${COLOR_YELLOW}--------------------${COLOR_RESET}"

# *** Variáveis para Resumo e Métricas ***
START_TIME=$(date '+%Y-%m-%d %H:%M:%S')
TASKS_EXECUTED_ARRAY=() # Array para as tarefas executadas
DOWNLOADED_MB=0        # Para rastrear o tamanho do download do APT
TOTAL_FREED_SPACE_MB=0  # Para rastrear o espaço total liberado

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
  local output
  log "$COLOR_GREEN""  -> Iniciando atualização dos pacotes do sistema (apt update e upgrade)...""$COLOR_RESET"
  output=$(apt update -y 2>&1) # Captura a saída do apt update
  echo "$output" &>> "$LOG_FILE" # Loga a saída completa
  download_update=$(echo "$output" | grep "Baixados" | awk '{print $2}' | sed 's/M//g') # Extrai o tamanho do download
  if [[ -n "$download_update" ]]; then
    DOWNLOADED_MB=$(echo "$DOWNLOADED_MB + $download_update" | bc) # Acumula o tamanho do download
  fi
  output=$(apt upgrade -y 2>&1) # Captura a saída do apt upgrade
  echo "$output" &>> "$LOG_FILE" # Loga a saída completa
  download_upgrade=$(echo "$output" | grep "Baixados" | awk '{print $2}' | sed 's/M//g') # Extrai o tamanho do download
   if [[ -n "$download_upgrade" ]]; then
    DOWNLOADED_MB=$(echo "$DOWNLOADED_MB + $download_upgrade" | bc) # Acumula o tamanho do download
  fi
  log "$COLOR_GREEN""  -> Concluído: Atualização dos pacotes do sistema.""$COLOR_RESET"
  TASKS_EXECUTED_ARRAY+=("Atualização de pacotes do sistema (apt update & upgrade)")
}

limpar_apt() {
  local freed_space_apt_start freed_space_apt_end freed_space_apt_mb
  log "$COLOR_GREEN""  -> Iniciando limpeza do APT (autoremove, autoclean, clean)...""$COLOR_RESET"
  freed_space_apt_start=$(du -sb /var/cache/apt | awk '{print $1}') # Mede espaço inicial
  apt autoremove -y &>> "$LOG_FILE"
  apt autoclean -y &>> "$LOG_FILE"
  apt clean -y &>> "$LOG_FILE"
  freed_space_apt_end=$(du -sb /var/cache/apt | awk '{print $1}')   # Mede espaço final
  freed_space_apt_bytes=$((freed_space_apt_start - freed_space_apt_end))
  freed_space_apt_mb=$(echo "scale=2; $freed_space_apt_bytes / (1024*1024)" | bc) # Converte para MB
  TOTAL_FREED_SPACE_MB=$(echo "$TOTAL_FREED_SPACE_MB + $freed_space_apt_mb" | bc) # Acumula espaço liberado
  log "$COLOR_GREEN""  -> Concluído: Limpeza do APT. Espaço liberado: ${freed_space_apt_mb} MB.""$COLOR_RESET"
  TASKS_EXECUTED_ARRAY+=("Limpeza do APT (autoremove, autoclean, clean)")
}

limpar_temporarios() {
  local freed_space_temp_start freed_space_temp_end freed_space_temp_mb
  log "$COLOR_GREEN""  -> Iniciando limpeza de arquivos temporários em /tmp e /var/tmp (mais de $TEMP_THRESHOLD_DAYS dias)...""$COLOR_RESET"
  freed_space_temp_start=$(du -sb /tmp /var/tmp | awk '{print $1}') # Mede espaço inicial
  find /tmp /var/tmp -type f -atime +"$TEMP_THRESHOLD_DAYS" -delete &>> "$LOG_FILE"
  freed_space_temp_end=$(du -sb /tmp /var/tmp | awk '{print $1}')   # Mede espaço final
  freed_space_temp_bytes=$((freed_space_temp_start - freed_space_temp_end))
  freed_space_temp_mb=$(echo "scale=2; $freed_space_temp_bytes / (1024*1024)" | bc) # Converte para MB
  TOTAL_FREED_SPACE_MB=$(echo "$TOTAL_FREED_SPACE_MB + $freed_space_temp_mb" | bc) # Acumula espaço liberado
  log "$COLOR_GREEN""  -> Concluído: Limpeza de arquivos temporários. Espaço liberado: ${freed_space_temp_mb} MB.""$COLOR_RESET"
  TASKS_EXECUTED_ARRAY+=("Limpeza de arquivos temporários (/tmp, /var/tmp com mais de ${TEMP_THRESHOLD_DAYS} dias)")
}

limpar_logs() {
  local freed_space_logs_start freed_space_logs_end freed_space_logs_mb
  log "$COLOR_GREEN""  -> Iniciando limpeza de arquivos de log antigos em /var/log (mais de $LOG_THRESHOLD_DAYS dias)...""$COLOR_RESET"
  freed_space_logs_start=$(du -sb /var/log | awk '{print $1}') # Mede espaço inicial
  find /var/log -type f -name "*.log" -mtime +"$LOG_THRESHOLD_DAYS" -delete &>> "$LOG_FILE"
  freed_space_logs_end=$(du -sb /var/log | awk '{print $1}')   # Mede espaço final
  freed_space_logs_bytes=$((freed_space_logs_start - freed_space_logs_end))
  freed_space_logs_mb=$(echo "scale=2; $freed_space_logs_bytes / (1024*1024)" | bc) # Converte para MB
  TOTAL_FREED_SPACE_MB=$(echo "$TOTAL_FREED_SPACE_MB + $freed_space_logs_mb" | bc) # Acumula espaço liberado
  log "$COLOR_GREEN""  -> Concluído: Limpeza de arquivos de log. Espaço liberado: ${freed_space_logs_mb} MB.""$COLOR_RESET"
  TASKS_EXECUTED_ARRAY+=("Limpeza de arquivos de log antigos em /var/log (mais de ${LOG_THRESHOLD_DAYS} dias)")
}

limpar_cache_navegador() {
  local freed_space_browser_start freed_space_browser_end freed_space_browser_mb
  if [[ "$CACHE_NAVEGADOR" == true ]]; then
    log "$COLOR_GREEN""  -> Iniciando limpeza de cache de navegadores (Firefox e Chrome/Chromium)...""$COLOR_RESET"
    freed_space_browser_start=$(du -sb ~/.cache/mozilla ~/.cache/google-chrome ~/.config/chromium ~/.cache/chromium 2>/dev/null | awk '{print $1}') # Mede espaço inicial
    rm -rf ~/.cache/mozilla/firefox/*/cache2 2>/dev/null
    rm -rf ~/.cache/google-chrome/*/Cache 2>/dev/null
    rm -rf ~/.config/chromium/*/Cache 2>/dev/null
    rm -rf ~/.cache/chromium/*/Cache 2>/dev/null
    freed_space_browser_end=$(du -sb ~/.cache/mozilla ~/.cache/google-chrome ~/.config/chromium ~/.cache/chromium 2>/dev/null | awk '{print $1}')   # Mede espaço final
    freed_space_browser_bytes=$((freed_space_browser_start - freed_space_browser_end))
    freed_space_browser_mb=$(echo "scale=2; $freed_space_browser_bytes / (1024*1024)" | bc) # Converte para MB
    TOTAL_FREED_SPACE_MB=$(echo "$TOTAL_FREED_SPACE_MB + $freed_space_browser_mb" | bc) # Acumula espaço liberado
    log "$COLOR_GREEN""  -> Concluído: Limpeza de cache de navegadores. Espaço liberado: ${freed_space_browser_mb} MB.""$COLOR_RESET"
    TASKS_EXECUTED_ARRAY+=("Limpeza de cache dos navegadores (Firefox, Chrome/Chromium)")
  else
    log "$COLOR_YELLOW""  -> AVISO: Limpeza de cache de navegadores desativada (configuração).""$COLOR_RESET"
    TASKS_EXECUTED_ARRAY+=("Limpeza de cache dos navegadores (DESATIVADA)")
  fi
}

limpar_cache_miniaturas() {
  local freed_space_thumbnails_start freed_space_thumbnails_end freed_space_thumbnails_mb
  log "$COLOR_GREEN""  -> Iniciando limpeza do cache de miniaturas (~/.cache/thumbnails)...""$COLOR_RESET"
  freed_space_thumbnails_start=$(du -sb ~/.cache/thumbnails 2>/dev/null | awk '{print $1}') # Mede espaço inicial
  rm -rf ~/.cache/thumbnails/* 2>/dev/null &>> "$LOG_FILE"
  freed_space_thumbnails_end=$(du -sb ~/.cache/thumbnails 2>/dev/null | awk '{print $1}')   # Mede espaço final
  freed_space_thumbnails_bytes=$((freed_space_thumbnails_start - freed_space_thumbnails_end))
  freed_space_thumbnails_mb=$(echo "scale=2; $freed_space_thumbnails_bytes / (1024*1024)" | bc) # Converte para MB
  TOTAL_FREED_SPACE_MB=$(echo "$TOTAL_FREED_SPACE_MB + $freed_space_thumbnails_mb" | bc) # Acumula espaço liberado
  log "$COLOR_GREEN""  -> Concluído: Limpeza do cache de miniaturas. Espaço liberado: ${freed_space_thumbnails_mb} MB.""$COLOR_RESET"
  TASKS_EXECUTED_ARRAY+=("Limpeza do cache de miniaturas (~/.cache/thumbnails)")
}

verificar_espaco_disco() {
  log "$COLOR_GREEN""  -> Iniciando verificação de espaço em disco (df -h)...""$COLOR_RESET"
  df -h &>> "$LOG_FILE"
  log "$COLOR_GREEN""  -> Concluído: Verificação de espaço em disco. Resultados detalhados no log.""$COLOR_RESET"
  TASKS_EXECUTED_ARRAY+=("Verificação de espaço em disco (comando df -h)")
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
  echo "    (Atualizar lista de pacotes e pacotes instalados)"
  echo -e "${COLOR_BOLD}2 - Tarefas de Limpeza de Cache${COLOR_RESET}"
  echo "    (APT, Temporários, Navegadores, Miniaturas)"
  echo -e "${COLOR_BOLD}3 - Tarefas de Limpeza de Logs${COLOR_RESET}"
  echo "    (Arquivos de log antigos)"
  echo -e "${COLOR_BOLD}4 - Verificação de Espaço em Disco${COLOR_RESET}"
  echo "    (Exibir uso do disco)"
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

# *** Função para Exibir o Resumo das Tarefas Executadas ***
exibir_resumo() {
  END_TIME=$(date '+%Y-%m-%d %H:%M:%S')
  echo ""
  echo -e "${SEPARATOR_SECTION}"
  echo -e "${COLOR_BOLD}${COLOR_CYAN}RESUMO DA MANUTENÇÃO DO SISTEMA${COLOR_RESET}"
  echo -e "${SEPARATOR_SECTION}"
  echo ""
  echo -e "${COLOR_BOLD}Período de Execução:${COLOR_RESET} ${START_TIME} - ${END_TIME}"
  echo ""
  echo -e "${COLOR_BOLD}Métricas de Manutenção:${COLOR_RESET}"
  echo "  - Pacotes Atualizados/Baixados: ${DOWNLOADED_MB} MB"
  echo "  - Espaço Total Liberado: ${TOTAL_FREED_SPACE_MB} MB"
  echo ""
  echo -e "${COLOR_BOLD}Tarefas Executadas:${COLOR_RESET}"
  if [[ ${#TASKS_EXECUTED_ARRAY[@]} -eq 0 ]]; then
    echo "  Nenhuma tarefa de manutenção foi executada."
  else
    for tarefa in "${TASKS_EXECUTED_ARRAY[@]}"; do
      echo "  - $tarefa"
    done
  fi
  echo ""
  echo -e "${COLOR_BOLD}Status do Disco:${COLOR_RESET} Detalhes no arquivo de log."
  echo -e "${COLOR_YELLOW}Mais detalhes podem ser encontrados no arquivo de log: ${LOG_FILE}${COLOR_RESET}"
  echo -e "${SEPARATOR_SECTION}"
  echo ""
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

exibir_resumo # Exibe o resumo na tela antes de finalizar

log "$COLOR_CYAN""--- FIM DO SCRIPT DE MANUTENÇÃO DO UBUNTU ---""$COLOR_RESET"

exit 0
