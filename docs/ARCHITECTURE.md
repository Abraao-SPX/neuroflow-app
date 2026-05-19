# Architecture

## Visao Geral

NeuroFlow usa uma arquitetura simples de API REST:

```text
Flutter app -> Express routes -> Controllers -> Models/Services -> MySQL
```

O backend e organizado por responsabilidade:

| Pasta | Responsabilidade |
| --- | --- |
| `src/routes` | Declara endpoints e middlewares |
| `src/controllers` | Traduz HTTP para operacoes de dominio |
| `src/models` | Models Sequelize e adaptadores de persistencia |
| `src/middlewares` | Autenticacao, autorizacao e rate limit |
| `src/config` | Ambiente, CORS, Sequelize e JWT |
| `src/services` | Integracoes externas, como email |
| `src/utils` | Validacoes e helpers puros |
| `src/database/migrations` | Schema versionado |
| `src/database/seeders` | Dados iniciais |
| `test` | Testes automatizados |

## Autenticacao

- `POST /api/auth/register` cria usuario com senha bcrypt.
- `POST /api/auth/login` valida credenciais e emite access token e refresh token.
- Access token e refresh token usam JWT HS256.
- Refresh tokens sao persistidos apenas como SHA-256 hash.
- Reset de senha usa codigo de 6 digitos persistido como HMAC/hash.
- Rotas privadas usam `authMiddleware`.
- Rotas administrativas usam `authMiddleware` e `isAdminMiddleware`.

## Dados

Sequelize e a estrategia principal de acesso ao banco. O uso direto de `mysql2` fica isolado em `src/config/db.js` para compatibilidade, mas os fluxos principais usam models Sequelize.

Tarefas sao expostas pelo wrapper `TaskModel`, que preserva o contrato em ingles da API (`title`, `description`, `completed`) enquanto o banco usa nomes historicos em portugues (`titulo`, `descricao`, `concluida`).

Check-ins se relacionam com gatilhos via tabela pivot `CheckinGatilhos`, evitando armazenamento redundante em JSON.

## Erros

Controllers retornam JSON padronizado:

```json
{
  "success": false,
  "message": "Descricao do erro"
}
```

Deletes bem-sucedidos retornam `204 No Content`.

## Decisoes Importantes

- Migrations sao a fonte de verdade do schema.
- `sequelize.sync()` nao e usado no startup.
- CORS e configurado por allowlist.
- Rate limit protege endpoints sensiveis de auth.
- Payloads sao validados antes de tocar o banco.
