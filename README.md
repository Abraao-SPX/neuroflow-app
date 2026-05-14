<div align="center">

<br/>

```
 ███╗   ██╗███████╗██╗   ██╗██████╗  ██████╗ ███████╗██╗      ██████╗ ██╗    ██╗
 ████╗  ██║██╔════╝██║   ██║██╔══██╗██╔═══██╗██╔════╝██║     ██╔═══██╗██║    ██║
 ██╔██╗ ██║█████╗  ██║   ██║██████╔╝██║   ██║█████╗  ██║     ██║   ██║██║ █╗ ██║
 ██║╚██╗██║██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝  ██║     ██║   ██║██║███╗██║
 ██║ ╚████║███████╗╚██████╔╝██║  ██║╚██████╔╝██║     ███████╗╚██████╔╝╚███╔███╔╝
 ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝
```

### **Sensory Management System**
*A inteligência de dados a favor da regulação sensorial.*

<br/>

[![MySQL](https://img.shields.io/badge/Database-MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Node.js](https://img.shields.io/badge/Backend-Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Sequelize](https://img.shields.io/badge/ORM-Sequelize-52B0E7?style=for-the-badge&logo=sequelize&logoColor=white)](https://sequelize.org/)
[![JWT](https://img.shields.io/badge/Auth-JWT-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=white)](https://jwt.io/)

</div>

---

## ✦ Sobre o Projeto

O **NeuroFlow** é uma plataforma de suporte à regulação sensorial, desenvolvida para auxiliar indivíduos neurodivergentes no mapeamento e compreensão de sobrecarga sensorial.

O sistema rastreia a **"bateria mental"** do usuário ao longo do tempo, correlacionando-a com gatilhos ambientais — como níveis de barulho, intensidade de luz e outros estímulos — a fim de gerar insights que promovam o **autocuidado e a regulação emocional**.

---

## 🛠️ Arquitetura Técnica

```
┌─────────────────────────────────────────────────────────────┐
│                        NEUROFLOW                            │
│                                                             │
│   ┌──────────────┐    ┌──────────────┐    ┌─────────────┐   │
│   │   Flutter    │◄──►│  Node.js API  │◄──►│    MySQL    │  │
│   │   (Mobile)   │    │  (Backend)    │    │  (Database) │  │
│   │              │    │               │    │             │  │
│   │  Clean Arch  │    │  RESTful +    │    │  Sequelize  │  │
│   │  Cognitiva   │    │  JWT Auth     │    │  ORM + N:N  │  │
│   └──────────────┘    └──────────────┘    └─────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

| Camada | Tecnologia | Responsabilidade |
|--------|-----------|-----------------|
| 📱 **Interface** | Flutter | UI com foco em acessibilidade cognitiva e Clean Architecture |
| ⚙️ **Serviço** | Node.js | API RESTful com autenticação via JWT |
| 🗄️ **Dados** | MySQL + Sequelize ORM | Estrutura relacional normalizada com Migrations e relacionamentos N:N |

---

## 📂 Estrutura do Projeto

```
neuroflow/
│
├── 📂 backend/               # API e lógica de negócio
│   └── 📂 database/          # Configurações do Sequelize, Migrations e Models
│
├── 📂 tremer/                # Código-fonte do aplicativo Flutter
│
└── 📂 docs/                  # Documentação técnica e ativos visuais
```

---

## 🚀 Guia de Implantação Local

### Pré-requisitos

- **MySQL** em execução com credenciais configuradas em `.env` ou `config/config.json`
- **Node.js** v18+
- **Flutter SDK** instalado

---

### 1 · Banco de Dados

```bash
cd backend

# Instalar dependências
npm install

# Criar o banco e as tabelas via Migrations
npx sequelize-cli db:migrate

# Popular os gatilhos iniciais via Seeds
npx sequelize-cli db:seed:all
```

### 2 · Servidor Backend

```bash
npm start
```

### 3 · Aplicativo Mobile

```bash
cd ../tremer

flutter pub get
flutter run
```

---

## 📡 Especificação da API

### 🔐 Autenticação & Segurança

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `POST` | `/auth/register` | Registro de novo utilizador com criptografia de senha |
| `POST` | `/auth/login` | Validação de credenciais e emissão de Token de acesso |

### 🧠 Monitoramento Sensorial *(Rotas Privadas)*

> Todas as rotas abaixo requerem o header `Authorization: Bearer <token>`

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/gatilhos` | Recuperação do catálogo de estímulos *(Barulho, Luz, etc.)* |
| `POST` | `/checkin` | Registro de bateria mental e vínculo de gatilhos *(Pivot N:N)* |
| `GET` | `/historico` | Recuperação cronológica de registros do utilizador autenticado |

---

## 👥 Equipe Técnica

<div align="center">

| Área | Responsáveis |
|------|-------------|
| 🗄️ **Banco de Dados** | Iara Matias · Abraão Paixão |
| ⚙️ **Backend Architecture** | Abraão Paixão · Pedro Souza |
| 📱 **Mobile Engineering** | Kíria Goís · Maria Luiza · Daniel Arévalo |

</div>

<div align="center">

*Construído com cuidado para quem sente o mundo de forma intensa.*

</div>

<p align="center">Desenvolvido como projeto MVP - 2026</p>
