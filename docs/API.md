# API Examples

Base URL local:

```text
http://localhost:3000/api
```

Todas as rotas privadas usam:

```http
Authorization: Bearer <accessToken>
```

## Auth

### Register

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "maria",
    "email": "maria@example.com",
    "password": "senha12345"
  }'
```

Resposta `201`:

```json
{
  "success": true,
  "message": "Usuario cadastrado com sucesso!",
  "accessToken": "<jwt>",
  "refreshToken": "<jwt>",
  "user": {
    "id": 1,
    "username": "maria",
    "name": "maria",
    "email": "maria@example.com",
    "role": "user"
  }
}
```

### Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "maria@example.com",
    "password": "senha12345"
  }'
```

### Refresh Token

```bash
curl -X POST http://localhost:3000/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{ "refreshToken": "<refreshToken>" }'
```

### Logout

```bash
curl -X POST http://localhost:3000/api/auth/logout \
  -H "Content-Type: application/json" \
  -d '{ "refreshToken": "<refreshToken>" }'
```

### Forgot Password

```bash
curl -X POST http://localhost:3000/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{ "email": "maria@example.com" }'
```

Por seguranca, o codigo de recuperacao nao e retornado no JSON. Ele e enviado por email quando SMTP esta configurado.

### Reset Password

```bash
curl -X POST http://localhost:3000/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "token": "123456",
    "newPassword": "novaSenha123"
  }'
```

## Tasks

### Create Task

```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <accessToken>" \
  -d '{
    "title": "Organizar rotina",
    "description": "Separar atividades do dia"
  }'
```

### List Tasks

```bash
curl http://localhost:3000/api/tasks \
  -H "Authorization: Bearer <accessToken>"
```

### Replace Task

```bash
curl -X PUT http://localhost:3000/api/tasks/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <accessToken>" \
  -d '{
    "title": "Organizar rotina",
    "description": "Atualizada",
    "completed": false
  }'
```

### Patch Task

```bash
curl -X PATCH http://localhost:3000/api/tasks/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <accessToken>" \
  -d '{ "completed": true }'
```

### Delete Task

```bash
curl -X DELETE http://localhost:3000/api/tasks/1 \
  -H "Authorization: Bearer <accessToken>"
```

Sucesso retorna `204 No Content`.

## Check-ins

Check-ins usam gatilhos ja cadastrados em `Gatilhos`. O payload aceita nomes ou ids.

### Create Check-in

```bash
curl -X POST http://localhost:3000/api/checkins \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <accessToken>" \
  -d '{
    "humor": "ansioso",
    "gatilhos": ["Ruídos e Barulhos", "Excesso de tarefas"],
    "dataCheckin": "2026-05-19"
  }'
```

### List Check-ins

```bash
curl http://localhost:3000/api/checkins \
  -H "Authorization: Bearer <accessToken>"
```

### Patch Check-in

```bash
curl -X PATCH http://localhost:3000/api/checkins/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <accessToken>" \
  -d '{ "humor": "calmo" }'
```

## Triggers

### List Triggers

```bash
curl http://localhost:3000/api/triggers \
  -H "Authorization: Bearer <accessToken>"
```

### Create Trigger, Admin

```bash
curl -X POST http://localhost:3000/api/triggers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <adminAccessToken>" \
  -d '{
    "nome": "Ambiente cheio",
    "icone": "groups"
  }'
```

## Admin

### List Users

```bash
curl http://localhost:3000/api/admin/users \
  -H "Authorization: Bearer <adminAccessToken>"
```

### Delete User

```bash
curl -X DELETE http://localhost:3000/api/admin/users/2 \
  -H "Authorization: Bearer <adminAccessToken>"
```

Sucesso retorna `204 No Content`.

## Error Format

Erros seguem o formato:

```json
{
  "success": false,
  "message": "Mensagem do erro."
}
```

Status comuns:

| Status | Uso |
| --- | --- |
| `400` | Payload invalido |
| `401` | Token ausente ou credenciais invalidas |
| `403` | Token invalido, expirado ou usuario sem permissao |
| `404` | Recurso nao encontrado |
| `409` | Conflito de unicidade |
| `429` | Rate limit |
| `500` | Erro interno |
