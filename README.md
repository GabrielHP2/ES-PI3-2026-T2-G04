# Mescla Invest - Projeto Integrador 3

> Aplicativo mobile para simulação de compra e venda de tokens de Startups e Empresas Juniores do Mescla - PUC Campinas.

Este projeto foi desenvolvido como parte do currículo do curso de **Engenharia de Software** da **PUC-Campinas**

<br>

## Sobre o Projeto

O Mescla Invest permite que usuários simulem o investimento em empresas nos estágios iniciais, utilizando uma interface mobile para gerenciar uma carteira virtual de tokens.

### Principais Funcionalidades

- Autenticação de usuário com autenticação multifator (2FA) opcional
- Cadastro de usuário com validação de CPF e telefone
- Recuperação de senha por e-mail
- Catálogo de Startups com filtros
- Visualização detalhada de cada startup (perguntas, informações, histórico)
- Mercado de tokens com book de ordens (balcão)
- Compra e venda de tokens via ordem limitada ou a mercado
- Confirmação de ordens e histórico de negociações
- Dashboard de portfólio com acompanhamento de valorização
- Carteira virtual com depósito e saque
- Perfil de usuário

<br>

## Arquitetura

O projeto é dividido em dois módulos principais:

- **`lib/`** — Frontend mobile em Flutter, organizado em `pages`, `components`, `models`, `services`, `controllers` e `utils`
- **`functions/`** — Backend em Firebase Cloud Functions (TypeScript/Node.js), com módulos independentes para autenticação, startups, exchange, orders e balcão

```
ES-PI3-2026-T2-G04/
├── lib/                        # Frontend Flutter
│   ├── pages/                  # Telas do aplicativo
│   ├── components/             # Widgets reutilizáveis
│   ├── models/                 # Entidades de dados
│   ├── services/               # Comunicação com Firebase/API
│   ├── controllers/            # Lógica de estado (GetX)
│   └── utils/                  # Formatadores e utilitários
│
├── functions/src/              # Backend Cloud Functions
│   ├── auth/                   # Autenticação e 2FA
│   ├── startups/               # CRUD de startups
│   ├── exchange/               # Motor de troca de tokens
│   ├── orders/                 # Gestão de ordens
│   ├── balcony/                # Negociações de balcão
│   ├── orderBook_engine/       # Engine do book de ordens
│   └── shared/                 # Tipos e utilitários compartilhados
│
├── assets/                     # Recursos estáticos (ícones, imagens)
├── android/ & ios/             # Configurações nativas de plataforma
└── documents/                  # Documentação do projeto (requisitos, modelagem, user journey)
```

<br>

## Stack utilizada no projeto

### Mobile Frontend

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

### Backend e API

![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase_Functions-FF6F00?style=for-the-badge&logo=firebase&logoColor=white)

### Banco de dados e Infraestrutura

![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Firestore](https://img.shields.io/badge/Cloud_Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)

<br>

## Autores do projeto

| [<img src="https://github.com/Jp-mainieri.png" width=115><br>](https://github.com/Jp-mainieri) | [<img src="https://github.com/GabrielHP2.png" width=115><br>](https://github.com/GabrielHP2) | [<img src="https://github.com/GabrielHpuc.png" width=115><br>](https://github.com/GabrielHpuc) | [<img src="https://github.com/LeonelLucky.png" width=115><br>](https://github.com/LeonelLucky) |
| :--------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------: |

<br>

## Como Executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.11.0`)
- [Node.js](https://nodejs.org/) `v24`
- [Firebase CLI](https://firebase.google.com/docs/cli) instalado globalmente (`npm install -g firebase-tools`)
- Conta no Firebase com o projeto configurado

---

### 1. Clone o repositório

```bash
git clone https://github.com/GabrielHP2/ES-PI3-2026-T2-G04.git
cd ES-PI3-2026-T2-G04
```

---

### 2. Backend — Firebase Cloud Functions

```bash
cd functions
npm install
npm run build
```

Para rodar o emulador localmente:

```bash
firebase emulators:start --only functions,firestore,auth
```

Para fazer deploy das functions:

```bash
npm run deploy
```

---

### 3. Frontend — Flutter

Na raiz do projeto:

```bash
flutter pub get
flutter run
```

> **Nota:** O arquivo `google-services.json` (Android) e `GoogleService-Info.plist` (iOS) devem estar configurados com as credenciais do Firebase do projeto. Esses arquivos não são versionados no repositório por questões de segurança.

---

---

## Fluxo Principal da Aplicação

1. **Cadastro / Login** — o usuário cria uma conta com e-mail, CPF e telefone, ou autentica com e-mail e senha. O 2FA pode ser habilitado opcionalmente.
2. **Catálogo** — após autenticado, o usuário navega pelo catálogo de startups disponíveis, com filtros por categoria.
3. **Detalhe da Startup** — ao selecionar uma startup, o usuário acessa informações detalhadas, perguntas da empresa e o histórico de negociações do token.
4. **Negociação** — o usuário pode colocar ordens de compra ou venda no book de ordens (balcão) e confirmar a transação.
5. **Carteira e Portfolio** — o saldo virtual e os tokens detidos são acompanhados na carteira e no dashboard de portfólio, com gráficos de valorização.

<br>

---

## Documentos

Os documentos do projeto estão disponíveis na pasta [`documents/`](documents/):

| Documento | Descrição |
|---|---|
| [Levantamento de Requisitos](documents/LevantamentoRequisitos%20PI03.docx) | Requisitos funcionais e não funcionais do sistema |
| [Modelagem](documents/Modelagem-PI3.docx) | Diagramas e modelagem do sistema |
| [User Journey](documents/UserJourneyPI03-Grupo04.pdf) | Jornada do usuário mapeada |
| [Mapa Mental](documents/MapaMentalPI3.pdf) | Mapa mental do projeto |
| [Especificação Mobile](documents/PI3-2026-Mobile-MesclaInvest.pdf) | Especificação técnica do app mobile |

<br>

---

## Contribuindo

O projeto segue um modelo de branches baseado em **feature** e **fix** branches com pull requests para a `main`.

### Convenção de branches

```
feature/<descricao>   # nova funcionalidade
fix/<descricao>       # correção de bug
```

### Fluxo

1. Crie uma branch a partir da `main` seguindo a convenção acima
2. Desenvolva e faça commits na sua branch
3. Abra um Pull Request para a `main`
4. Aguarde revisão e aprovação antes de fazer o merge
