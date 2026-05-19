# NeuroFlow

Sensory Management System para registro de humor, tarefas e gatilhos sensoriais.

O projeto e composto por uma API Node.js/Express, banco MySQL com Sequelize e um aplicativo Flutter. A API usa JWT com access token, refresh token persistido em hash e rotas privadas por usuario.

## Stack

| Camada | Tecnologia | Responsabilidade |
| --- | --- | --- |
| Mobile | Flutter | Interface do aplicativo |
| API | Node.js, Express | Rotas REST, JWT, regras de negocio |
| Banco | MySQL, Sequelize | Persistencia relacional e migrations |
| Email | Nodemailer | Recuperacao de senha |

## Estrutura

```text
neuroflow-app/
  backend/
    database/                  # schema SQL para bootstrap via Docker
    src/
      config/                  # Sequelize, CORS, JWT e ambiente
      controllers/             # Entrada HTTP e respostas
      database/
        migrations/            # Evolucao versionada do banco
        seeders/               # Dados iniciais
      middlewares/             # Auth, admin, rate limit
      models/                  # Models Sequelize e wrappers de dominio
      routes/                  # Definicao REST
      services/                # Email e integracoes
      utils/                   # Validacoes compartilhadas
    test/                      # Testes automatizados
  docs/
    API.md                     # Exemplos de requests
    ARCHITECTURE.md            # Decisoes tecnicas
    DATABASE.md                # Modelagem e migrations
    OPENAPI.yaml               # Especificacao OpenAPI 3.0
  Flutter/
    lib/                       # App Flutter
```

## Requisitos

- Node.js 20+
- npm
- MySQL 8+
- Flutter SDK
- Docker e Docker Compose, opcional

## Configuracao do backend

Crie o arquivo `backend/.env` a partir de `backend/.env.example`.

```bash
cd backend
cp .env.example .env
```

Preencha os segredos com valores reais. `JWT_SECRET` e `REFRESH_TOKEN_SECRET` precisam ter pelo menos 32 caracteres, nao podem ser iguais e nao podem usar os placeholders do exemplo.

Variaveis principais:

| Variavel | Uso |
| --- | --- |
| `PORT` | Porta HTTP da API |
| `DB_HOST` | Host do MySQL |
| `DB_PORT` | Porta do MySQL |
| `DB_USER` | Usuario do MySQL |
| `DB_PASSWORD` | Senha do MySQL |
| `DB_NAME` | Nome do banco |
| `DB_TEST_NAME` | Nome do banco usado por testes de integracao |
| `DB_SSL` | Habilita SSL na conexao MySQL |
| `DB_SSL_REJECT_UNAUTHORIZED` | Valida ou ignora autoridade do certificado SSL |
| `JWT_SECRET` | Segredo do access token |
| `TOKEN_EXPIRATION` | Expiracao do access token |
| `REFRESH_TOKEN_SECRET` | Segredo do refresh token |
| `REFRESH_TOKEN_EXPIRATION` | Expiracao do refresh token |
| `CORS_ORIGINS` | Origens permitidas separadas por virgula. Aceita porta curinga com `:*`, por exemplo `http://localhost:*` |
| `MAIL_*` | Configuracao SMTP para recuperacao de senha |

## Rodando localmente

```bash
cd backend
npm install
npm run migrate
npm run seed
npm start
```

Em PowerShell com politica de scripts bloqueando `npm.ps1`, use:

```powershell
npm.cmd install
npm.cmd run migrate
npm.cmd run seed
npm.cmd start
```

A API sobe por padrao em:

```text
http://localhost:3000
```

## Docker

O Compose exige segredos via variaveis de ambiente. Exemplo:

```bash
DB_PASSWORD="senha-forte-do-mysql" \
JWT_SECRET="access-token-secret-com-mais-de-32-caracteres" \
REFRESH_TOKEN_SECRET="refresh-token-secret-diferente-com-32-caracteres" \
CORS_ORIGINS="http://localhost:*,http://127.0.0.1:*,http://10.0.2.2:3000,http://18.229.149.163:*" \
docker compose up --build
```

Depois que os containers estiverem ativos, rode migrations e seeders dentro do backend se necessario:

```bash
docker compose exec backend npm run migrate
docker compose exec backend npm run seed
```

## Scripts do backend

| Comando | Descricao |
| --- | --- |
| `npm start` | Inicia a API com Node |
| `npm run dev` | Inicia com Nodemon |
| `npm test` | Executa testes com `node:test` |
| `npm run check` | Verifica sintaxe dos arquivos JavaScript |
| `npm run verify` | Executa sintaxe e testes |
| `npm run migrate` | Executa migrations do Sequelize |
| `npm run seed` | Popula gatilhos iniciais |

## API

Base URL local:

```text
http://localhost:3000/api
```

Rotas de autenticacao:

| Metodo | Endpoint | Autenticacao |
| --- | --- | --- |
| `POST` | `/auth/register` | Publica |
| `POST` | `/auth/login` | Publica |
| `POST` | `/auth/refresh` | Publica com refresh token |
| `POST` | `/auth/logout` | Publica com refresh token |
| `POST` | `/auth/forgot-password` | Publica |
| `POST` | `/auth/reset-password` | Publica |
| `GET` | `/auth/me` | Bearer token |

Rotas privadas:

| Metodo | Endpoint | Observacao |
| --- | --- | --- |
| `GET` | `/tasks` | Lista tarefas do usuario |
| `POST` | `/tasks` | Cria tarefa |
| `GET` | `/tasks/:id` | Busca tarefa do usuario |
| `PUT` | `/tasks/:id` | Substitui tarefa completa |
| `PATCH` | `/tasks/:id` | Atualiza tarefa parcialmente |
| `DELETE` | `/tasks/:id` | Remove tarefa |
| `GET` | `/checkins` | Lista check-ins do usuario |
| `POST` | `/checkins` | Cria check-in com gatilhos existentes |
| `GET` | `/checkins/:id` | Busca check-in do usuario |
| `PUT` | `/checkins/:id` | Substitui check-in completo |
| `PATCH` | `/checkins/:id` | Atualiza check-in parcialmente |
| `DELETE` | `/checkins/:id` | Remove check-in |
| `GET` | `/triggers` | Lista gatilhos |
| `GET` | `/triggers/:id` | Busca gatilho |

Rotas de admin:

| Metodo | Endpoint | Observacao |
| --- | --- | --- |
| `GET` | `/admin/users` | Apenas `role=admin` |
| `DELETE` | `/admin/users/:id` | Apenas `role=admin` |
| `POST` | `/triggers` | Apenas `role=admin` |
| `PUT` | `/triggers/:id` | Apenas `role=admin` |
| `PATCH` | `/triggers/:id` | Apenas `role=admin` |
| `DELETE` | `/triggers/:id` | Apenas `role=admin` |

Exemplos completos estao em [docs/API.md](docs/API.md). A especificacao OpenAPI esta em [docs/OPENAPI.yaml](docs/OPENAPI.yaml).

## Testes

```bash
cd backend
npm run verify
```

Os testes atuais cobrem validacoes compartilhadas e regras de configuracao segura para JWT. O comando `verify` tambem roda checagem de sintaxe dos arquivos JavaScript.

## Banco de dados

O schema e gerenciado por migrations em `backend/src/database/migrations`. O arquivo `backend/database/schema.sql` existe para bootstrap inicial do MySQL no Docker, mas a fonte de verdade para evolucao do banco sao as migrations.

Resumo da modelagem:

- `Usuarios` possui muitas `Tarefas`.
- `Usuarios` possui muitos `checkins`.
- `checkins` e `Gatilhos` se relacionam por `CheckinGatilhos`.
- `RefreshTokens` guarda hash do refresh token e vinculo com usuario.

Detalhes em [docs/DATABASE.md](docs/DATABASE.md).

## Segurança

- Senhas sao armazenadas com bcrypt.
- Access tokens e refresh tokens usam JWT HS256.
- Refresh tokens sao persistidos apenas como hash.
- Codigos de reset de senha sao persistidos como HMAC/hash e nao retornam na resposta HTTP.
- Rotas privadas usam `Authorization: Bearer <token>`.
- Rotas administrativas exigem `role=admin`.
- Endpoints sensiveis de auth possuem rate limit.
- CORS usa allowlist via `CORS_ORIGINS`. Para Flutter Web em desenvolvimento, inclua `http://localhost:*` porque a porta do navegador pode mudar.

## Flutter

```bash
cd Flutter
flutter pub get
flutter run
```

Configure a URL da API em `Flutter/lib/core/constants/api_constants.dart`.

## Documentacao tecnica

- [API examples](docs/API.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Database](docs/DATABASE.md)
- [OpenAPI](docs/OPENAPI.yaml)

## Equipe

| Area | Responsaveis |
| --- | --- |
| Banco de Dados | Iara Matias, Abraao Paixao |
| Backend | Abraao Paixao, Pedro Souza |
| Frontend | Kiria Gois, Maria Luiza, Daniel Arevalo |
