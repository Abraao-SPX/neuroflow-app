# Database

O banco oficial e MySQL 8. O schema e controlado por Sequelize migrations em:

```text
backend/src/database/migrations
```

O arquivo `backend/database/schema.sql` existe para bootstrap inicial do MySQL no Docker. Depois disso, evolucoes devem ser feitas por migrations.

## Comandos

```bash
cd backend
npm run migrate
npm run seed
```

## Tabelas

### Usuarios

Armazena contas de usuario.

Campos principais:

- `id`
- `username`
- `email`
- `password`
- `role`
- `reset_token`
- `reset_token_expires`
- `created_at`
- `updated_at`

### Tarefas

Tarefas pertencem a um usuario.

Relacionamento:

```text
Usuarios 1:N Tarefas
```

Campos principais:

- `id`
- `usuario_id`
- `titulo`
- `descricao`
- `concluida`
- `created_at`
- `updated_at`

### checkins

Check-ins pertencem a um usuario.

Relacionamento:

```text
Usuarios 1:N checkins
```

Campos principais:

- `id`
- `usuario_id`
- `humor`
- `data_checkin`
- `created_at`
- `updated_at`

### Gatilhos

Catalogo de gatilhos sensoriais.

Campos principais:

- `id`
- `nome`
- `icone`

### CheckinGatilhos

Tabela pivot entre check-ins e gatilhos.

Relacionamento:

```text
checkins N:N Gatilhos
```

Campos:

- `checkin_id`
- `gatilho_id`

### RefreshTokens

Persistencia de sessoes por refresh token.

Campos principais:

- `id`
- `usuario_id`
- `token_hash`
- `expires_at`
- `revoked_at`
- `created_at`
- `updated_at`

## Indices

Indices relevantes:

- `Usuarios.email` unico
- `Usuarios.username` unico
- `Tarefas.usuario_id`
- `checkins.usuario_id`
- `checkins.usuario_id, data_checkin`
- `Gatilhos.nome` unico
- `RefreshTokens.token_hash` unico
- `RefreshTokens.usuario_id`
- `CheckinGatilhos.gatilho_id`

## Regras de Integridade

- Tarefas sao apagadas em cascata quando o usuario e removido.
- Check-ins sao apagados em cascata quando o usuario e removido.
- Relações em `CheckinGatilhos` sao apagadas em cascata quando o check-in ou gatilho e removido.
- Refresh tokens sao apagados em cascata quando o usuario e removido.

## Seeders

O seeder `20260517195500-seed-gatilhos.js` popula gatilhos iniciais usados pelo app Flutter e pela API.
