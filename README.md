# Sistema de Agendamentos de Salas - Coworking

Um aplicativo multiplataforma para gerenciamento de salas e agendamentos em espaços de coworking, desenvolvido com **Flutter** e **SQLite**, com persistência robusta de dados e sistema completo de auditoria.

## 📋 Funcionalidades

### Gerenciamento de Salas
- ✅ Criar novas salas com validação de nome único
- ✅ Listar todas as salas cadastradas
- ✅ Editar informações de salas
- ✅ Deletar salas (com proteção contra exclusão de salas com agendamentos futuros)

### Gerenciamento de Agendamentos
- ✅ Agendar salas com data e horário de início/fim
- ✅ Visualizar todos os agendamentos
- ✅ Editar agendamentos existentes
- ✅ Cancelar agendamentos
- ✅ Validação de sobreposição de horários
- ✅ Histórico de operações auditado

### Sistema de Log
- ✅ Registro automático de todas as operações (INSERT, UPDATE, DELETE)
- ✅ Rastreamento completo de modificações no banco de dados
- ✅ Timestamps precisos de cada operação
- ✅ Informações sobre tabela afetada e tipo de operação

## 🛠️ Tecnologias Utilizadas

- **Flutter 3.x** - Framework multiplataforma
- **Dart** - Linguagem de programação
- **SQLite** - Banco de dados local
- **Material Design 3** - Design System

## 📦 Requisitos

- Flutter SDK 3.0 ou superior
- Dart SDK 3.0 ou superior
- Windows, macOS ou Linux

## 🚀 Como Executar
 
### 1. Clone o repositório
```bash
git clone https://github.com/seu-usuario/flutter-agendamentos.git
cd flutter-agendamentos
```
 
### 2. Instale as dependências
```bash
flutter pub get
```
 
### 3. Execute a aplicação
```bash
flutter run -d windows  # Para Windows Desktop
flutter run -d macos    # Para macOS Desktop
flutter run -d linux    # Para Linux Desktop
```
