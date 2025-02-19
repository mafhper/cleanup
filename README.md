# 🚀 Ubuntu System Maintenance Script

<p align="center">
  <img src="https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white" />
  <img src="https://img.shields.io/badge/OS-Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" />
</p>

Um script de manutenção interativo para sistemas Ubuntu com interface amigável e feedback visual em tempo real.

```
    ████████╗██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗
    ╚══██╔══╝██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║   ██║
       ██║   ██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║   ██║
       ██║   ██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║   ██║
       ██║   ╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║   ██║   ╚██████╔╝
       ╚═╝    ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝    ╚═════╝ 
```

## 📋 Características

- ⚡ Atualização do sistema
- 🧹 Limpeza de cache e arquivos temporários
- 📊 Verificação do estado do sistema
- 🎨 Interface colorida e intuitiva
- 📈 Barra de progresso em tempo real
- 📝 Sistema de logs detalhado

## 🛠️ Funcionalidades

1. **Atualização do Sistema**
   - Atualização da lista de pacotes
   - Instalação de atualizações disponíveis
   - Remoção de pacotes desnecessários

2. **Limpeza do Sistema**
   - Limpeza de cache do APT
   - Remoção de arquivos temporários
   - Limpeza de logs antigos
   - Otimização do cache do sistema

3. **Verificação do Sistema**
   - Análise do uso do disco
   - Monitoramento da memória
   - Listagem dos processos mais pesados

## 📥 Instalação

1. Clone o repositório:
```bash
git clone https://github.com/mafhper/cleanup.git
```

2. Entre no diretório:
```bash
cd cleanup
```

3. Dê permissão de execução ao script:
```bash
chmod +x cleanup.sh
```

## 💻 Uso

Execute o script com privilégios de superusuário:

```bash
sudo ./cleanup.sh
```

## 🔧 Configurações

O script possui algumas configurações padrão que podem ser ajustadas:

| Configuração | Valor Padrão | Descrição |
|-------------|--------------|-----------|
| TEMP_THRESHOLD_DAYS | 3 | Dias para manter arquivos temporários |
| CACHE_THRESHOLD_DAYS | 7 | Dias para manter arquivos em cache |
| LOG_THRESHOLD_DAYS | 30 | Dias para manter logs antigos |

## 📊 Logs

Os logs são armazenados em:
```
/var/log/manutencao_ubuntu.log
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Reportar bugs
2. Sugerir novas funcionalidades
3. Enviar pull requests

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👤 Autor

**mafhper**

* GitHub: [@mafhper](https://github.com/mafhper)

## ⭐ Mostre seu apoio

Dê uma ⭐️ se este projeto te ajudou!

## 📜 Changelog

### [2.2.0] - 2025-02-19
- Interface gráfica melhorada com ASCII art
- Adicionado feedback visual em tempo real
- Implementado sistema de logs detalhado
- Melhorias na performance e segurança

### [2.1.0] - 2025-02-19
- Adicionada barra de progresso
- Melhorias na interface do usuário
- Correções de bugs

### [2.0.0] - 2025-02-19
- Versão inicial do script
- Funcionalidades básicas de manutenção
