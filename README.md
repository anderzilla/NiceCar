# NiceCar

SaaS de gestão para oficinas de estética automotiva: web de gestão, app da oficina (PWA) e portal do cliente.

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `apps/backend` | API NestJS + Prisma + PostgreSQL |
| `apps/web` | Next.js — gestão (`/(gestao)`) e portal do cliente (`/(portal)`) |
| `apps/app-oficina` | PWA da oficina (Vite + React, empacotável com Capacitor) |
| `packages/shared` | Tipos, enums, DTOs e `rbac/RBAC_PERMISSIONS.json` |
| `packages/ui` | Componentes compartilhados |
| `infra` | Docker Compose, Dockerfiles, scripts de deploy |
| `scripts` | Scripts de desenvolvimento (`verify.sh`) |

## Começando

```bash
pnpm install
cp apps/backend/.env.example apps/backend/.env
docker compose -f infra/docker-compose.yml up -d   # Postgres, Redis, MinIO
pnpm db:migrate && pnpm db:seed
pnpm dev
```

## Verificação

```bash
pnpm verify        # lint + typecheck + testes dos pacotes alterados
pnpm verify:full   # tudo + e2e (antes de merge em main/demo)
```

## Commits

Conventional Commits, citando a regra de negócio quando houver: `feat(os): bloqueia finalização com extra pendente [RN-17]`.
