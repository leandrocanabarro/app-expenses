# App Expenses

Um aplicativo Flutter de controle de gastos com comando de voz, seguindo as melhores práticas de mercado e Clean Architecture.

## 🌟 Recursos

- ✅ Gerenciamento de gastos e categorias
- 🎤 Comandos de voz em português (pt-BR)
- 📱 Suporte para Android, iOS e Web
- 💾 Persistência local com SQLite
- 📊 Relatórios e gráficos (em desenvolvimento)
- 🎨 Material Design 3 com tema claro/escuro
- 🏗️ Clean Architecture com Riverpod

## 🎯 Comandos de Voz

O aplicativo reconhece os seguintes comandos em português:

### Criar Categoria
- "criar categoria alimentação"
- "nova categoria transporte"

### Adicionar Gasto
- "adicionar gasto 50 almoço"
- "gastei 25,90 em café"
- "lançar 100 supermercado"
- "adicionar gasto 50 almoço na categoria alimentação"

## 🏛️ Arquitetura

O projeto segue os princípios da Clean Architecture:

```
lib/
├── core/              # Utilitários e constantes
├── data/              # Camada de dados
│   ├── datasources/   # Fontes de dados (SQLite)
│   ├── models/        # Modelos de dados
│   ├── repositories/  # Implementações dos repositórios
│   └── services/      # Serviços (voz, parsing)
├── domain/            # Camada de domínio
│   ├── entities/      # Entidades de negócio
│   ├── repositories/  # Contratos dos repositórios
│   └── usecases/      # Casos de uso
└── presentation/      # Camada de apresentação
    ├── providers/     # Providers (Riverpod)
    ├── screens/       # Telas do aplicativo
    └── widgets/       # Widgets reutilizáveis
```

## 🚀 Como Executar

### Opção 1: GitHub Codespaces (Recomendado)

1. Abra o repositório no GitHub
2. Clique em **Code** → **Codespaces** → **Create codespace on main**
3. Aguarde a configuração automática do ambiente
4. Execute o aplicativo:
```bash
flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0
```

### Opção 2: Docker (Local)

1. Clone o repositório:
```bash
git clone https://github.com/leandrocanabarro/app-expenses.git
cd app-expenses
```

2. Execute com Docker Compose:
```bash
# Executar a aplicação
docker-compose up app

# Ou para desenvolvimento interativo
docker-compose run --rm dev
```

3. Acesse a aplicação em `http://localhost:3000`

### Opção 3: Instalação Local

#### Pré-requisitos
- Flutter 3.24.5 ou superior
- Dart 3.1.0 ou superior
- Android Studio / VS Code
- Git

#### Instalação

1. Clone o repositório:
```bash
git clone https://github.com/leandrocanabarro/app-expenses.git
cd app-expenses
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
# Android/iOS
flutter run

# Web
flutter run -d chrome
```

## 🧪 Testes

Execute os testes com:

```bash
# Todos os testes
flutter test

# Testes unitários
flutter test test/unit/

# Testes de integração
flutter test test/integration/

# Testes de widget
flutter test test/widget/
```

## 🛠️ Comandos Úteis

```bash
# Formatação de código
flutter format .

# Análise estática
flutter analyze

# Build para produção
flutter build apk --release        # Android
flutter build ios --release        # iOS
flutter build web --release        # Web

# Gerar coverage
flutter test --coverage
```

## 📱 Funcionalidades

### ✅ Implementadas

- [x] Cadastro e listagem de gastos
- [x] Cadastro e listagem de categorias
- [x] Comando de voz para criar categorias
- [x] Comando de voz para adicionar gastos
- [x] Filtros por mês e categoria
- [x] Persistência local (SQLite)
- [x] Material Design 3
- [x] Navegação com GoRouter
- [x] Validação de formulários
- [x] Tratamento de erros

### 🚧 Em Desenvolvimento

- [ ] Gráficos e relatórios (fl_chart)
- [ ] Filtro avançado por categoria
- [ ] Edição de gastos e categorias
- [ ] Exportação de dados
- [ ] Backup em nuvem

## 📦 Dependências Principais

- `flutter_riverpod`: Gerenciamento de estado
- `go_router`: Navegação
- `sqflite`: Banco de dados local
- `speech_to_text`: Reconhecimento de voz
- `intl`: Formatação de moeda e datas
- `fl_chart`: Gráficos (futuro)

## 🔧 Desenvolvimento

### Ambientes de Desenvolvimento

Este projeto oferece múltiplas opções para desenvolvimento:

#### 🌐 GitHub Codespaces
- **Configuração automática**: Ambiente pré-configurado com Flutter 3.24.5
- **Acesso via browser**: Desenvolva diretamente no navegador
- **Extensões incluídas**: Dart, Flutter, e ferramentas essenciais
- **Porta exposta**: 3000 para desenvolvimento web

#### 🐳 Docker
- **Dockerfile**: Imagem personalizada com Flutter
- **docker-compose.yml**: Configuração simplificada
- **Volume persistente**: Cache do pub para builds rápidos
- **Serviços separados**: `app` para execução e `dev` para desenvolvimento

#### 💻 Local
- **Flutter SDK**: 3.24.5 ou superior
- **Suporte completo**: Android, iOS, Web
- **Hot reload**: Desenvolvimento rápido

### Estrutura de Commits

O projeto segue commits atômicos e descritivos:

1. `scaffold`: Estrutura inicial
2. `feat(db)`: Implementação do banco
3. `feat(domain)`: Camada de domínio
4. `feat(data)`: Camada de dados
5. `feat(presentation)`: Camada de apresentação
6. `feat(voice)`: Funcionalidades de voz
7. `feat(charts)`: Gráficos e relatórios
8. `test`: Implementação de testes
9. `ci`: Pipeline de CI/CD
10. `docs`: Documentação

### Padrões de Código

- Clean Architecture
- SOLID principles
- Repository pattern
- Use cases pattern
- State management com Riverpod
- Material Design 3

## 📋 Roadmap

### Próximas Versões

- **v1.1**: Gráficos e relatórios completos
- **v1.2**: Edição e exclusão de itens
- **v1.3**: Filtros avançados
- **v1.4**: Orçamentos e metas
- **v2.0**: Sincronização em nuvem
- **v2.1**: Múltiplas contas
- **v2.2**: Exportação para Excel/CSV

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Autor

**Leandro Canabarro**

- GitHub: [@leandrocanabarro](https://github.com/leandrocanabarro)

---

*Desenvolvido com ❤️ e Flutter*
