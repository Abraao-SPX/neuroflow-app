# 🧠 NeuroFlow: Sensory Management System

> **A inteligência de dados a favor da regulação sensorial.**

[![MySQL](https://img.shields.io/badge/Database-MySQL-blue?style=flat-square&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Node.js](https://img.shields.io/badge/Backend-Node.js-green?style=flat-square&logo=node.js&logoColor=white)](https://nodejs.org/)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter-info?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)

O **NeuroFlow** auxilia indivíduos neurodivergentes no mapeamento de sobrecarga sensorial, rastreando a "bateria mental" e correlacionando-a com gatilhos ambientais para suporte à regulação emocional.

---

### 🛠️ Arquitetura Técnica

* **Camada de Dados (MySQL):** Estrutura normalizada com relacionamento **Muitos-para-Muitos (N:N)** via tabela pivot para registros de gatilhos.
* **Camada de Serviço (Node.js):** API RESTful com autenticação via **JWT** e persistência segura.
* **Interface (Flutter):** Mobile focado em acessibilidade e Clean Architecture.

---

### 📂 Estrutura de Pastas

* `📂 /backend`: API e lógica de negócio.
* `📂 /backend/database`: Scripts SQL (`schema.sql`) e conexão.
* `📂 /tremer`: Código-fonte do aplicativo Flutter.
* `📂 /docs`: Documentação e ativos visuais.

---

### 🚀 Guia de Setup

1. **Banco de Dados:** Execute o arquivo `backend/database/schema.sql` no MySQL.
2. **Backend:** No diretório `/backend`, execute `npm install` e `npm start`.
3. **Mobile:** No diretório `/tremer`, execute `flutter pub get` e `flutter run`.

---

### 📡 Especificação da API (Endpoints)

#### 🔐 Autenticação
* `POST /auth/register` - Persistência de novo usuário.
* `POST /auth/login` - Validação de credenciais e emissão de Token JWT.

#### 🧠 Monitoramento Sensorial (Privado)
* `GET /gatilhos` - Recuperação do catálogo de estímulos sensoriais.
* `POST /checkin` - Registro de bateria e vínculo de gatilhos (N:N).
* `GET /historico` - Linha do tempo de registros do usuário logado.

---

### 👥 Equipe Técnica

* **Banco de Dados:** Iara Matias e Abraão Paixão
* **Backend:** Abraão Paixão e Pedro Henrique
* **Frontend:** Kíria Goís, Maria Luiza e Daniel Arévalo

---
<p align="center">Desenvolvido como projeto MVP - 2026</p>
