# gtone-qa-mobile

Suite Maestro de testes E2E para o **GT ONE Mobile** (`net.globalthings.gtone`).

App alvo: Expo 52 + RN 0.76.7 + PowerSync + Supabase. Subset do GT ONE Web focado em técnicos em campo (EAM/CMMS).

> **Versão Maestro pinada:** `2.3.0` (ver `.maestro-version`)

---

## TL;DR — rodar local

```bash
## 1. Bootar emulador Pixel_6 API 31 (Android 12)
bash scripts/setup-emulator.sh

## 2. Subir Supabase local (no repo principal effortone) + seed
EFFORTONE_REPO=../effortone bash scripts/seed-supabase.sh

## 3. Instalar APK debug
adb install ../effortone/apps/mobile/android/app/build/outputs/apk/debug/app-debug.apk

## 4. Exportar env + rodar smoke
source scripts/setup-env.sh
npm run test:smoke
```

---

## Estrutura

```
flows/
├── 00_smoke/                 → smoke (cold-start, app não crasha)
├── 01_auth/                  → login/logout/biometria
├── 02_work_orders/           → criar/listar/executar/batch/assinar OS
├── 03_service_requests/      → criar SR / converter em OS
├── 04_checklist/             → executar checklist / foto evidência
├── 05_assets/                → buscar / criar / mapa / álbum
├── 06_locations/             → CRUD localizações
├── 07_inspection_rounds/     → iniciar / completar com leituras
├── 08_meter_readings/        → leitura manual de medidores
├── 09_inventory/             → buscar / consumir
├── 10_navigation/            → tabs / deep link
├── 11_dashboard/             → KPIs visíveis
├── 12_settings/              → idioma / tema / perfil
├── 13_copilot/               → chat / tool bubbles
├── 14_tracking/              → permissions / background
├── 15_iot/                   → sensores / alertas / chart
└── 99_perf/                  → cold start / hot reload
shared/
├── config.yaml               → appId raiz
├── _login_helper.yaml        → reutilizável (login + tenant + biometria)
├── _navigate_to_wo.yaml      → vai pra tab OS
└── _seed_data_helper.yaml    → re-launch app
scripts/
├── setup-env.sh              → exporta env vars + adb reverse
├── setup-emulator.sh         → boota Pixel_6 e espera boot
├── seed-supabase.sh          → reset DB + seeds + reset senha
└── run-all.sh                → roda suite com tag opcional
fixtures/                     → payloads JSON estáticos
.github/workflows/e2e.yml     → CI matrix API 31
```

---

## Tags (subsets executáveis)

| Tag | Conteúdo | Quando rodar |
|---|---|---|
| `smoke` | Cold-start, login, tabs | Cada commit |
| `critical` | P0/P1 — auth, criar/executar OS, SR | A cada PR |
| `regression` | P2/P3 — features completas | Nightly |
| `tracking` | Location lifecycle | Job dedicado (lento) |
| `slow` | Permissions, biometria, copilot | Job dedicado |
| `device` | Apenas device físico (sem clearState) | Manual |
| `perf` | Cold start, hot reload | Nightly |

Exemplo:
```bash
npm run test:smoke
npm run test:critical
npm run test:regression
```

---

## Env vars necessárias

Variáveis **não vão no repo**. Use `.env.local` (gitignored):

```bash
cp .env.example .env.local
## edite .env.local com suas credenciais reais
source scripts/setup-env.sh
```

Variáveis exigidas (ver `.env.example` para template completo):

| Variável | Origem |
|---|---|
| `MAESTRO_TEST_EMAIL` | User de teste criado no Supabase local |
| `MAESTRO_TEST_PASSWORD` | Senha desse user (gerada por você ou via `seed-supabase.sh`) |
| `MAESTRO_TEST_TENANT_SLUG` | Slug do tenant de teste (INSERT manual) |
| `MAESTRO_TEST_COMPANY_ID` | UUID da company de teste (INSERT manual) |

O script `scripts/setup-env.sh` valida que todas estão setadas — falha se faltar alguma.

---

## Pré-requisitos

- macOS / Linux
- Java 17
- Android SDK + emulador **Pixel_6 (API 31)** *(evitar API 36 — bug do Gboard)*
- Maestro 2.3.0 (`curl -fsSL "https://get.maestro.mobile.dev" | bash`)
- Docker + Supabase CLI (pra rodar backend local)
- Repo principal `effortone` clonado (pra APK + seeds)

---

## CI

Workflow em `.github/workflows/e2e.yml`. Matrix com API 31, x86_64, google_apis.

**Secrets necessários no repo:**
- `MAESTRO_TEST_EMAIL`
- `MAESTRO_TEST_PASSWORD`

**Vars necessárias no repo:**
- `MAESTRO_TEST_TENANT_SLUG`
- `MAESTRO_TEST_COMPANY_ID`

**TODO antes do CI ficar verde:** plugar etapa de download do APK (release storage, EAS build, ou artefato cross-repo).

---

## Bugs conhecidos (Maestro × app)

1. **`inputText` trava em Android 16 (API 36)** — `DEADLINE_EXCEEDED` no Gboard. Usar Pixel_6/API 31.
2. **`clearState: true` não limpa AsyncStorage** — onboarding fica como visto. Mitigação: `adb shell pm clear net.globalthings.gtone`.
3. **PowerSync first launch ~10-15s** — usar `extendedWaitUntil` generoso.
4. **Senha do seed quebra após reset** — bcrypt do seed não bate; ver `seed-supabase.sh` que força senha.
5. **`btn-logout` (Pressable) não dispara via Maestro** em RN 0.76 Bridgeless+Fabric. Funciona manual. Retestar em versões futuras.
6. **`btn-save-wo` no footer** pode não disparar pelo mesmo motivo. Asserção final do create.yaml usa `wo-detail-screen` (testID único na tela alvo) pra provar navegação.

---

## Adicionar novo flow

1. Escolha a pasta correta em `flows/`
2. Use template padrão:
   ```yaml
   ## Flow XX — Descrição
   ## Tags: smoke|critical|regression|slow|device|perf
   appId: net.globalthings.gtone
   tags: [critical]
   env:
     EMAIL: ${MAESTRO_TEST_EMAIL}
     PASSWORD: ${MAESTRO_TEST_PASSWORD}
   ---
   - runFlow: ../01_auth/login_happy.yaml
   ## ...
   ```
3. Sempre usar `testID` > `text` > `coordenadas`
4. `optional: true` em passos que podem não aparecer (onboarding, biometria, tenant picker)
5. `extendedWaitUntil` com timeout generoso (PowerSync = ~15s)
