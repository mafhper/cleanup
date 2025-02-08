# Script de Manutenção do Sistema Ubuntu (cleanup.sh)

[![Licença MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Este script Bash abrangente foi projetado para simplificar a manutenção e limpeza de sistemas Ubuntu, oferecendo uma interface interativa e funcionalidades robustas para manter seu sistema otimizado.

## Funcionalidades Principais

* **Menu Interativo Agrupado:** Navegue facilmente pelas opções de manutenção através de um menu interativo e organizado por categorias.
* **Saída Verbosa e Colorida:** Receba feedback detalhado sobre cada etapa da manutenção com mensagens coloridas para melhor visualização e acompanhamento.
* **Resumo Detalhado da Execução:** Ao final da manutenção, visualize um resumo conciso no terminal, incluindo:
    * Período de execução do script.
    * Métricas de espaço liberado e pacotes baixados (quando aplicável).
    * Lista de tarefas de manutenção executadas.
    * Referência ao arquivo de log para detalhes completos.
* **Métricas de Limpeza:** Acompanhe o espaço em disco liberado pelas tarefas de limpeza e o volume de dados baixados durante as atualizações do sistema.
* **Limpeza Abrangente:** Inclui as seguintes tarefas de manutenção:
    * Atualização de pacotes do sistema (`apt update` e `apt upgrade`).
    * Limpeza do APT (`autoremove`, `autoclean`, `clean`).
    * Limpeza de arquivos temporários em `/tmp` e `/var/tmp` (configurável por idade).
    * Limpeza de logs antigos em `/var/log` (configurável por idade).
    * Limpeza de cache de navegadores (Firefox, Chrome/Chromium) - opcional e configurável.
    * Limpeza de cache de miniaturas (`~/.cache/thumbnails`).
    * Verificação do espaço em disco (`df -h`).
* **Arquivo de Log Detalhado:** Todas as ações e saídas do script são registradas em `/var/log/manutencao_ubuntu.log` para auditoria e referência futura.
* **Configurações Personalizáveis:** Ajuste variáveis no início do script para personalizar o comportamento, como:
    * Dias limite para arquivos temporários e logs.
    * Habilitar/desabilitar limpeza de cache de navegadores.

## Como Usar

1.  **Baixe o script:**
    Você pode baixar o script `cleanup.sh` diretamente do seu repositório GitHub ou usando `wget`:

    \`\`\`bash
    wget [URL_DIRETO_PARA_O_ARQUIVO_CLEANUP.SH] -O cleanup.sh
    \`\`\`

    *(Substitua `[URL_DIRETO_PARA_O_ARQUIVO_CLEANUP.SH]` pelo link direto para o arquivo `cleanup.sh` no seu repositório GitHub)*

2.  **Torne o script executável:**
    Dê permissão de execução para o script:

    \`\`\`bash
    chmod +x cleanup.sh
    \`\`\`

3.  **Execute o script como root:**
    O script requer privilégios de root para executar todas as tarefas de manutenção. Execute-o com `sudo`:

    \`\`\`bash
    sudo ./cleanup.sh
    \`\`\`

    Ou, se você moveu o script para um diretório em seu PATH, como `/usr/local/bin`:

    \`\`\`bash
    sudo cleanup.sh
    \`\`\`

4.  **Siga o menu interativo:**
    O script exibirá um menu no terminal. Selecione as opções de manutenção desejadas digitando os números correspondentes separados por espaços e pressione `Enter`. Para executar todas as tarefas, selecione a opção `5`. Para sair sem executar nenhuma manutenção, selecione `0`.

5.  **Analise o Resumo:**
    Após a execução, um resumo das tarefas realizadas, métricas e período de execução será exibido no terminal.

6.  **Consulte o Log Detalhado:**
    Para um registro completo de todas as ações, verifique o arquivo de log em `/var/log/manutencao_ubuntu.log`.

## Configuração

As seguintes variáveis podem ser configuradas no início do script para personalizar seu comportamento:

* `LOG_FILE="/var/log/manutencao_ubuntu.log"`:  Define o caminho e nome do arquivo de log.
* `TEMP_THRESHOLD_DAYS=3`: Define o número de dias de idade para arquivos temporários em `/tmp` e `/var/tmp` serem considerados para limpeza.
* `CACHE_THRESHOLD_DAYS=7`:  *(Atualmente não utilizado diretamente, mas pode ser usado para futuras implementações de limpeza de cache baseada em idade)*
* `LOG_THRESHOLD_DAYS=30`: Define o número de dias de idade para arquivos de log em `/var/log` serem considerados para limpeza.
* `CACHE_NAVEGADOR=true`:  Define se a limpeza de cache dos navegadores (Firefox e Chrome/Chromium) deve ser habilitada por padrão (`true`) ou desabilitada (`false`).

## Métricas e Resumo

O script fornece um resumo ao final da execução, exibindo:

* **Período de Execução:** Tempo total que o script levou para ser executado.
* **Métricas de Manutenção:**
    * Pacotes Atualizados/Baixados: Quantidade de dados baixados durante a atualização de pacotes (em MB).
    * Espaço Total Liberado: Espaço total em disco liberado pelas tarefas de limpeza (em MB).
* **Tarefas Executadas:** Lista das tarefas de manutenção que foram selecionadas e executadas.
* **Status do Disco:**  Um lembrete para verificar o arquivo de log para detalhes completos sobre o status do disco (saída do comando `df -h`).

## Arquivo de Log

Um log detalhado de todas as operações é gravado em `/var/log/manutencao_ubuntu.log`. Este arquivo contém timestamps, mensagens informativas, erros (se ocorrerem) e a saída completa de comandos como `apt update`, `apt upgrade` e `df -h`.

## Dependências

* **Bash:** O script é escrito em Bash e requer um interpretador Bash para ser executado.
* **Ubuntu ou sistemas baseados em Debian:**  O script foi desenvolvido e testado em sistemas Ubuntu. Pode funcionar em outras distribuições baseadas em Debian, mas a compatibilidade total não é garantida. Depende de utilitários padrão como `apt`, `find`, `rm`, `df`, `du`, `grep`, `awk`, `sed`, e `bc`.
* **Privilégios de Root:**  É necessário executar o script com `sudo` pois muitas tarefas de manutenção exigem privilégios administrativos.

## Avisos Importantes

* **Execute com cautela:**  Este script executa comandos que podem modificar seu sistema. **Revise o código cuidadosamente** antes de executar e certifique-se de entender o que cada tarefa faz.
* **Backup Recomendado:**  É sempre recomendável fazer backup de dados importantes antes de executar scripts de manutenção do sistema, especialmente em ambientes de produção.
* **Responsabilidade:** O uso deste script é por sua conta e risco. O autor não se responsabiliza por quaisquer problemas que possam ocorrer devido ao uso incorreto ou falhas no script.

## Licença

Este script é distribuído sob a [Licença MIT](https://opensource.org/licenses/MIT). Consulte o arquivo `LICENSE` para mais detalhes.
