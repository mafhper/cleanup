# Script de Manutenção e Limpeza do Sistema Ubuntu (manutencao_ubuntu.sh)

Este script Bash foi criado para automatizar tarefas comuns de manutenção e limpeza em sistemas Ubuntu. Ele oferece um menu interativo no terminal para que você possa selecionar quais tarefas deseja executar, agrupadas por categorias.

## Funcionalidades

O script permite realizar as seguintes tarefas de manutenção, agrupadas em categorias:

1.  **Tarefas de Atualização do Sistema:**
    *   Atualiza a lista de pacotes disponíveis nos repositórios (`apt update`).
    *   Atualiza os pacotes instalados para as versões mais recentes (`apt upgrade`).

2.  **Tarefas de Limpeza de Cache:**
    *   Limpa o cache do APT, removendo pacotes desnecessários e arquivos de pacotes antigos (`apt autoremove`, `apt autoclean`, `apt clean`).
    *   Limpa arquivos temporários antigos nos diretórios `/tmp` e `/var/tmp`.
    *   Limpa o cache de navegadores web (Firefox, Chrome/Chromium) do perfil do usuário que executa o script (opcional, configurável).
    *   Limpa o cache de miniaturas de imagens em `~/.cache/thumbnails/`.

3.  **Tarefas de Limpeza de Logs:**
    *   Remove arquivos de log antigos do diretório `/var/log` (logs com mais de 30 dias por padrão, configurável).

4.  **Verificação de Espaço em Disco:**
    *   Exibe o uso do espaço em disco usando o comando `df -h`, com os resultados detalhados registrados no arquivo de log.

5.  **Executar TODAS as Tarefas:**
    *   Permite executar todas as categorias de tarefas de manutenção em sequência.

## Pré-requisitos

*   Sistema operacional Ubuntu (ou similar baseado em Debian, compatível com `apt`).
*   Privilégios de administrador (necessário para executar a maioria das tarefas de manutenção). O script verifica se está sendo executado com `sudo`.

## Como Usar

### 1. Salvar o script

1.  Obtenha o script `manutencao_ubuntu.sh` (fornecido separadamente).
2.  Salve o arquivo com o nome `manutencao_ubuntu.sh` em um local de sua escolha no seu sistema Ubuntu (por exemplo, na sua pasta pessoal, ou em `/usr/local/bin` para acesso global - veja abaixo).

### 2. Tornar o script executável

Para executar o script, ele precisa ter permissão de execução. Abra o terminal e navegue até o diretório onde você salvou o arquivo `manutencao_ubuntu.sh`. Execute o seguinte comando para dar permissão de execução:

```bash
chmod +x manutencao_ubuntu.sh
