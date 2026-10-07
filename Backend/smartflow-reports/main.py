import os
from datetime import datetime
from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Dict, Any

from generators.executive_pdf import generate_executive_pdf
from generators.sla_excel import generate_sla_excel
from generators.financial_dossier import generate_financial_excel
from generators.predictive_inventory import generate_predictive_excel
from generators.audit_report import generate_audit_pdf

app = FastAPI(
    title="OTIS SmartFlow IA - Reports & Analytics Engine",
    description="Motor de geração de relatórios executivos em PDF e planilhas gerenciais em Excel.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

REPORT_CATALOG = {
    "executivo-nacional": {
        "id": "executivo-nacional",
        "title": "Relatório Executivo Nacional (Presidência)",
        "description": "Consolidado executivo com disponibilidade da frota, SLA global, margens contratuais e economia apurada.",
        "format": "PDF",
        "mime_type": "application/pdf",
        "file_prefix": "relatorio_executivo_nacional"
    },
    "sla-polos": {
        "id": "sla-polos",
        "title": "Relatório de Cumprimento de SLA por Polo",
        "description": "Desempenho dos supervisores, tempo médio de atendimento (TA/TB), horas técnicas e desvios.",
        "format": "EXCEL",
        "mime_type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "file_prefix": "relatorio_sla_polos"
    },
    "dossie-financeiro": {
        "id": "dossie-financeiro",
        "title": "Dossiê Financeiro & DRE de Contratos",
        "description": "Receita vs peças vs mão de obra vs deslocamento por cliente e alertas analíticos de margem.",
        "format": "EXCEL",
        "mime_type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "file_prefix": "dossie_financeiro_dre"
    },
    "inventario-preditivo": {
        "id": "inventario-preditivo",
        "title": "Inventário Preditivo & Padrões de Falha",
        "description": "Score de risco preditivo da frota cadastrada, telemetria de portas e histórico de intervenções.",
        "format": "EXCEL",
        "mime_type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "file_prefix": "inventario_preditivo_falhas"
    },
    "auditoria-decisoes": {
        "id": "auditoria-decisoes",
        "title": "Auditoria de Decisões: Supervisor vs IA",
        "description": "Aderência às recomendações do SmartFlow IA e justificativas operacionais registradas.",
        "format": "PDF",
        "mime_type": "application/pdf",
        "file_prefix": "auditoria_decisoes_supervisor_ia"
    }
}

class GenerateReportRequest(BaseModel):
    report_type: str
    filters: Optional[Dict[str, Any]] = None
    data: Optional[Dict[str, Any]] = None

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "smartflow-reports-engine",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/reports/types")
def list_report_types():
    return list(REPORT_CATALOG.values())

@app.get("/reports/download/{report_id}")
@app.post("/reports/generate")
def generate_report(report_id: Optional[str] = None, payload: Optional[GenerateReportRequest] = None):
    target_type = report_id or (payload.report_type if payload else None)
    if not target_type:
        raise HTTPException(status_code=400, detail="Identificador do relatório não informado.")

    key = target_type.lower().strip().replace(" ", "-").replace("_", "-")
    matched_key = None
    for k in REPORT_CATALOG.keys():
        if k in key or key in k:
            matched_key = k
            break

    if not matched_key:
        matched_key = "executivo-nacional"

    meta = REPORT_CATALOG[matched_key]
    timestamp = datetime.now().strftime("%Y%m%d_%H%M")
    
    if matched_key == "auditoria-decisoes":
        file_bytes = generate_audit_pdf(payload.data if payload else None)
        filename = f"{meta['file_prefix']}_{timestamp}.pdf"
    elif meta["format"] == "PDF":
        file_bytes = generate_executive_pdf(payload.data if payload else None)
        filename = f"{meta['file_prefix']}_{timestamp}.pdf"
    elif matched_key == "sla-polos":
        file_bytes = generate_sla_excel(payload.data if payload else None)
        filename = f"{meta['file_prefix']}_{timestamp}.xlsx"
    elif matched_key == "dossie-financeiro":
        file_bytes = generate_financial_excel(payload.data if payload else None)
        filename = f"{meta['file_prefix']}_{timestamp}.xlsx"
    elif matched_key == "inventario-preditivo":
        file_bytes = generate_predictive_excel(payload.data if payload else None)
        filename = f"{meta['file_prefix']}_{timestamp}.xlsx"
    else:
        file_bytes = generate_executive_pdf()
        filename = f"relatorio_{timestamp}.pdf"

    headers = {
        "Content-Disposition": f'attachment; filename="{filename}"',
        "Content-Type": meta["mime_type"],
        "Access-Control-Expose-Headers": "Content-Disposition"
    }

    return Response(
        content=file_bytes,
        media_type=meta["mime_type"],
        headers=headers
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
