#!/bin/bash
# # Script de Manutenção e Limpeza do Sistema Ubuntu (manutencao_ubuntu.sh)
#
# Este script Bash foi criado para automatizar tarefas comuns de manutenção e limpeza em sistemas Ubuntu. Ele oferece um menu interativo no terminal para que você possa selecionar quais tarefas deseja executar, agrupadas por categorias.
#
# ## Funcionalidades
#
# O script permite realizar as seguintes tarefas de manutenção, agrupadas em categorias:
#
# 1.  **Tarefas de Atualização do Sistema:**
#     *   Atualiza a lista de pacotes disponíveis nos repositórios (`apt update`).
#     *   Atualiza os pacotes instalados para as versões mais recentes (`apt upgrade`).
#
# 2.  **Tarefas de Limpeza de Cache:**
#     *   Limpa o cache do APT, removendo pacotes desnecessários e arquivos de pacotes antigos (`apt autoremove`, `apt autoclean`, `apt clean`).
#     *   Limpa arquivos temporários antigos nos diretórios `/tmp` e `/var/tmp`.
#     *   Limpa o cache de navegadores web (Firefox, Chrome/Chromium) do perfil do usuário que executa o script (opcional, configurável).
#     *   Limpa o cache de miniaturas de imagens em `~/.cache/thumbnails/`.
#
# 3.  **Tarefas de Limpeza de Logs:**
#     *   Remove arquivos de log antigos do diretório `/var/log` (logs com mais de 30 dias por padrão, configurável).
#
# 4.  **Verificação de Espaço em Disco:**
#     *   Exibe o uso do espaço em disco usando o comando `df -h`, com os resultados detalhados registrados no arquivo de log.
#
# 5.  **Executar TODAS as Tarefas:**
#     *   Permite executar todas as categorias de tarefas de manutenção em sequência.
#
# ## Pré-requisitos
#
# *   Sistema operacional Ubuntu (ou similar baseado em Debian, compatível com `apt`).
# *   Privilégios de administrador (necessário para executar a maioria das tarefas de manutenção). O script verifica se está sendo executado com `sudo`.
#
# ## Como Usar
#
# ### 1. Salvar o script
#
# 1.  Copie o conteúdo do script `manutencao_ubuntu.sh` (abaixo neste arquivo) para um arquivo de texto.
# 2.  Salve o arquivo com o nome `manutencao_ubuntu.sh` em um local de sua escolha no seu sistema Ubuntu (por exemplo, na sua pasta pessoal, ou em `/usr/local/bin` para acesso global - veja abaixo).
#
# ### 2. Tornar o script executável
#
# Para executar o script, ele precisa ter permissão de execução. Abra o terminal e navegue até o diretório onde você salvou o arquivo `manutencao_ubuntu.sh`. Execute o seguinte comando para dar permissão de execução:
#
# ```bash
# chmod +x manutencao_ubuntu.sh
# ```
#
# ### 3. Executar o script pelo terminal
#
# Para executar o script, utilize o comando `sudo` seguido do caminho para o script, pois ele requer privilégios de administrador.
#
# **Se o script estiver no diretório atual:**
#
# ```bash
# sudo ./manutencao_ubuntu.sh
# ```
#
# **Se você moveu o script para um diretório em seu `PATH` (como `/usr/local/bin` - veja abaixo), você pode executá-lo globalmente:**
#
# ```bash
# sudo manutencao_ubuntu.sh
# ```
#
# ### 4. Menu Interativo
#
# Ao executar o script, um menu interativo será exibido no terminal.
#
# ```
# =======================================================
# MENU DE MANUTENÇÃO DO SISTEMA - AGRUPADO
# =======================================================
#
# Selecione as categorias desejadas digitando os números separados por espaço:
#
# 1 - Tarefas de Atualização do Sistema
#     (Atualizar lista de pacotes e pacotes instalados)
# 2 - Tarefas de Limpeza de Cache
#     (APT, Temporários, Navegadores, Miniaturas)
# 3 - Tarefas de Limpeza de Logs
#     (Arquivos de log antigos)
# 4 - Verificação de Espaço em Disco
#     (Exibir uso do disco)
# 5 - Executar TODAS as Tarefas de Manutenção (1, 2, 3 e 4)
# 0 - Sair sem executar nenhuma manutenção
#
# Categorias selecionadas (ex: 1 2 ou 5 para tudo, 0 para sair):
# ```
#
# *   Digite os números das categorias que deseja executar, separados por espaços (ex: `1 2 3`).
# *   Para executar todas as tarefas, digite `5`.
# *   Para sair sem executar nenhuma tarefa, digite `0`.
# *   Pressione Enter para confirmar sua seleção.
#
# O script então executará as tarefas selecionadas, exibindo mensagens de progresso coloridas no terminal.
#
# ### 5. Arquivo de Log
#
# Os detalhes de cada execução do script, incluindo mensagens de log e a saída dos comandos, são registrados no arquivo:
#
# `/var/log/manutencao_ubuntu.log`
#
# Você pode verificar este arquivo para acompanhar o que foi feito e se houve algum problema.
#
# ## Como tornar o script executável globalmente pelo Bash
#
# Para executar o script de qualquer diretório no terminal, sem precisar especificar o caminho completo, você pode torná-lo "globalmente executável" seguindo estes passos:
#
# 1.  **Mova o script para um diretório no seu `PATH`:**
#     Diretórios como `/usr/local/bin` e `/usr/bin` já estão incluídos na variável de ambiente `PATH` do sistema. É recomendável usar `/usr/local/bin` para scripts locais.
#
#     Use o comando `sudo mv` para mover o arquivo `manutencao_ubuntu.sh` para `/usr/local/bin`:
#
#     ```bash
#     sudo mv manutencao_ubuntu.sh /usr/local/bin/
#     ```
#
# 2.  **Verifique se está no `PATH` (opcional):**
#     Você pode verificar se `/usr/local/bin` está no seu `PATH` executando:
#
#     ```bash
#     echo $PATH
#     ```
#
#     A saída deve listar `/usr/local/bin` entre os diretórios separados por `:`.
#
# Agora, após mover e tornar o script executável (passo 2 em "Como Usar"), você pode executá-lo de qualquer diretório no terminal simplesmente digitando:
#
# ```bash
# sudo manutencao_ubuntu.sh
# ```
#
# O Bash encontrará o script no diretório `/usr/local/bin` e o executará.
#
# ## Configurações e Personalização
#
# As seguintes configurações podem ser personalizadas no início do script `manutencao_ubuntu.sh`:
#
# *   `LOG_FILE="/var/log/manutencao_ubuntu.log"`: Caminho do arquivo de log.
# *   `TEMP_THRESHOLD_DAYS=3`: Número de dias para considerar arquivos temporários como "antigos" e elegíveis para limpeza.
# *   `CACHE_THRESHOLD_DAYS=7`: Número de dias para considerar pacotes em cache do APT como "antigos".
# *   `LOG_THRESHOLD_DAYS=30`: Número de dias para considerar arquivos de log como "antigos" e elegíveis para limpeza.
# *   `CACHE_NAVEGADOR=true`: Define se a limpeza do cache de navegadores está ativada por padrão (`true`) ou desativada (`false`). Esta opção pode ser alterada diretamente no script.
#
# Você pode editar o script com um editor de texto para ajustar essas configurações conforme suas necessidades.
#
# ## Advertências e Boas Práticas
#
# *   **Execute com cuidado:**  Este script executa operações de sistema que podem afetar seu sistema. Leia e entenda o script antes de executá-lo.
# *   **Teste em ambiente de teste:**  Se você fizer alterações no script, especialmente nas partes de limpeza, é altamente recomendável testá-lo em um sistema Ubuntu de teste (máquina virtual) antes de usar no seu sistema principal.
# *   **Cuidado com a limpeza de logs e cache:**  Pondere sobre a necessidade de limpar logs e cache, e ajuste os limiares de tempo e opções conforme necessário. Logs podem ser importantes para diagnóstico, e limpar cache de navegadores pode afetar temporariamente o desempenho de navegação.
# *   **Backup:**  Antes de executar qualquer script de manutenção, especialmente se você estiver fazendo alterações significativas, é sempre uma boa prática fazer backup de dados importantes.
#
# ## Versão
#
# 1.0
#
# ---
