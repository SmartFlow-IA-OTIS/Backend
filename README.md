# OTIS SmartFlow IA — Backend & Analytics Platform

Repositório oficial do backend e motor analítico da plataforma **OTIS SmartFlow IA**.

---

## 📄 Documentação e Plano de Arquitetura

- 📘 **Plano de Arquitetura em Markdown:** [`PLANO_ARQUITETURA.md`](./PLANO_ARQUITETURA.md)
- 📑 **Plano de Arquitetura Oficial em PDF:** [`Plano_Arquitetura_Backend_SmartFlow.pdf`](./Plano_Arquitetura_Backend_SmartFlow.pdf)

---

## 🏛️ Visão Geral da Arquitetura

O sistema adota uma arquitetura em camadas orientada a serviços:

1. **Backend Core (Java 17 + Spring Boot 3.3.4):**
   - Localizado em `Backend/smartflow-api/`.
   - APIs REST para gestão de equipamentos, chamados, técnicos e telemetria.
   - Banco de dados em memória H2 (dev) e suporte a PostgreSQL.
   - Swagger / OpenAPI disponível em: `http://localhost:8080/swagger-ui.html`.
   - Console H2 disponível em: `http://localhost:8080/h2-console`.

2. **Reports & Analytics Engine (Python 3.12 + FastAPI):**
   - Localizado em `Backend/smartflow-reports/`.
   - Geração de relatórios executivos em PDF com diagramação OTIS (ReportLab).
   - Geração de planilhas Excel avançadas com fórmulas e DRE (OpenPyXL).
   - Documentação FastAPI disponível em: `http://localhost:8000/docs`.

3. **Frontend (React + Vite + TypeScript):**
   - Localizado em `FrontEnd/prototipo/`.
   - Dashboards interativos e download integrado de relatórios.

---

## 🚀 Como Executar

### 1. Iniciar o Serviço de Relatórios Python (Porta 8000)
```powershell
cd Backend/smartflow-reports
uvicorn main:app --port 8000 --reload
```

### 2. Iniciar o Backend Spring Boot (Porta 8080)
```powershell
cd Backend/smartflow-api
.\mvnw.cmd spring-boot:run
```

### 3. Iniciar o Frontend React (Porta 3000 / 5173)
```powershell
cd FrontEnd/prototipo
npm run dev
```

---

## 🧪 Testes

Executar testes automatizados do Spring Boot:
```powershell
cd Backend/smartflow-api
.\mvnw.cmd test
```
