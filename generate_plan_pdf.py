import os
import sys
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable, Preformatted, PageBreak
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        # Top Header (pages > 1)
        if self._pageNumber > 1:
            self.setFont("Helvetica-Bold", 8)
            self.setFillColor(colors.HexColor("#002D62"))
            self.drawString(40, 810, "OTIS SmartFlow IA")
            self.setFont("Helvetica", 8)
            self.setFillColor(colors.HexColor("#64748B"))
            self.drawString(130, 810, "|   Arquitetura & Plano de Implementação: Backend Spring Boot & Python")
            self.setStrokeColor(colors.HexColor("#CBD5E1"))
            self.setLineWidth(0.5)
            self.line(40, 804, 555, 804)

        # Bottom Footer (all pages)
        self.setStrokeColor(colors.HexColor("#E2E8F0"))
        self.setLineWidth(0.5)
        self.line(40, 42, 555, 42)
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))
        self.drawString(40, 30, "OTIS Elevadores S/A — SmartFlow IA • Documento de Arquitetura e Engenharia")
        page_str = f"Página {self._pageNumber} de {page_count}"
        self.drawRightString(555, 30, page_str)
        self.restoreState()

def create_callout(title, text, color_hex="#0284C7", bg_hex="#F0F9FF"):
    style_title = ParagraphStyle(
        'CalloutTitle', fontName='Helvetica-Bold', fontSize=8.5, leading=12,
        textColor=colors.HexColor(color_hex)
    )
    style_text = ParagraphStyle(
        'CalloutText', fontName='Helvetica', fontSize=8, leading=11.5,
        textColor=colors.HexColor("#1E293B")
    )
    content = [
        Paragraph(f"<b>{title}</b>", style_title),
        Spacer(1, 2),
        Paragraph(text, style_text)
    ]
    t = Table([[content]], colWidths=[515])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor(bg_hex)),
        ('LINELEFT', (0, 0), (-1, -1), 3.5, colors.HexColor(color_hex)),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 10),
        ('RIGHTPADDING', (0, 0), (-1, -1), 10),
    ]))
    return t

def build_pdf(filename="Plano_Arquitetura_Backend_SmartFlow.pdf"):
    doc = SimpleDocTemplate(
        filename,
        pagesize=A4,
        leftMargin=40,
        rightMargin=40,
        topMargin=48,
        bottomMargin=50
    )

    styles = getSampleStyleSheet()

    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=colors.HexColor("#002D62"),
        spaceAfter=3
    )

    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=13,
        textColor=colors.HexColor("#475569"),
        spaceAfter=8
    )

    h1_style = ParagraphStyle(
        'Heading1_Custom',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=colors.HexColor("#002D62"),
        spaceBefore=11,
        spaceAfter=5,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'Heading2_Custom',
        parent=styles['Heading3'],
        fontName='Helvetica-Bold',
        fontSize=9.5,
        leading=13.5,
        textColor=colors.HexColor("#0369A1"),
        spaceBefore=7,
        spaceAfter=3,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'Body_Custom',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8.5,
        leading=12,
        textColor=colors.HexColor("#1E293B"),
        spaceAfter=5
    )

    bullet_style = ParagraphStyle(
        'Bullet_Custom',
        parent=body_style,
        leftIndent=12,
        firstLineIndent=-8,
        spaceAfter=2.5
    )

    check_done_style = ParagraphStyle(
        'CheckDone',
        parent=body_style,
        leftIndent=14,
        firstLineIndent=-10,
        textColor=colors.HexColor("#0F172A"),
        spaceAfter=2.5
    )

    code_block_style = ParagraphStyle(
        'CodeBlock',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=7.2,
        leading=9.5,
        textColor=colors.HexColor("#E2E8F0")
    )

    th_style = ParagraphStyle('TH', fontName='Helvetica-Bold', fontSize=8, leading=10.5, textColor=colors.white)
    td_style = ParagraphStyle('TD', fontName='Helvetica', fontSize=7.5, leading=10, textColor=colors.HexColor("#1E293B"))
    td_bold = ParagraphStyle('TDB', fontName='Helvetica-Bold', fontSize=7.5, leading=10, textColor=colors.HexColor("#0F172A"))

    story = []

    # Title & Banner
    story.append(Paragraph("OTIS ELEVADORES — SMARTFLOW IA", subtitle_style))
    story.append(Paragraph("Arquitetura e Plano de Implementação: Backend Spring Boot & Serviço de Relatórios Python", title_style))
    story.append(Paragraph(
        "Este documento descreve a arquitetura técnica, divisão de responsabilidades, estratégia de integração "
        "e o plano detalhado de implementação para o backend do <b>SmartFlow IA (OTIS)</b>, combinando "
        "<b>Java Spring Boot</b> (para regras de negócio, dados e segurança) com <b>Python</b> (para geração de dashboards, "
        "relatórios analíticos, PDFs e planilhas formatadas).",
        body_style
    ))
    story.append(HRFlowable(width="100%", thickness=1.5, color=colors.HexColor("#002D62"), spaceAfter=8))

    # 1. Visão Geral da Arquitetura
    story.append(Paragraph("1. Visão Geral da Arquitetura", h1_style))
    story.append(Paragraph(
        "O sistema adota uma <b>arquitetura em camadas orientada a serviços e microsserviços</b>, "
        "onde o frontend se conecta unicamente à API Spring Boot para operações e downloads, "
        "e o Spring Boot orquestra a geração de documentos pesados delegando ao motor analítico Python:",
        body_style
    ))

    # Architecture Diagram (Representação visual estilizada da arquitetura)
    diag_data = [
        [
            Paragraph("<b>FRONTEND (SPA)</b><br/>React + Vite + TypeScript<br/><font color='#64748B'>Portas 3000 / 5173</font>", td_bold),
            Paragraph("<b>BACKEND CORE (JAVA)</b><br/>Spring Boot 3.3.4 (REST API & Auth)<br/><font color='#64748B'>Porta 8080 • Spring Data JPA</font>", td_bold),
            Paragraph("<b>ENGINE DE RELATÓRIOS (PYTHON)</b><br/>FastAPI • ReportLab • OpenPyXL<br/><font color='#64748B'>Porta 8000 • Pandas</font>", td_bold)
        ],
        [
            Paragraph("• Dashboards Executivos<br/>• Chamados & Operação<br/>• Botões de Exportação", td_style),
            Paragraph("• Regras de Negócio OTIS<br/>• Orquestrador RestClient<br/>• Banco PostgreSQL / H2", td_style),
            Paragraph("• PDFs Executivos de Alta Resolução<br/>• Planilhas Excel com DRE e Fórmulas<br/>• Gráficos & Estatísticas", td_style)
        ]
    ]
    diag_table = Table(diag_data, colWidths=[171, 172, 172])
    diag_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#F1F5F9")),
        ('BACKGROUND', (0, 1), (-1, 1), colors.HexColor("#F8FAFC")),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor("#002D62")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
    ]))
    story.append(diag_table)
    story.append(Spacer(1, 8))

    # Tabela de Responsabilidades
    story.append(Paragraph("<b>Divisão de Responsabilidades por Componente:</b>", h2_style))
    comp_data = [
        [
            Paragraph("Componente", th_style),
            Paragraph("Tecnologia", th_style),
            Paragraph("Papel Principal", th_style)
        ],
        [
            Paragraph("<b>Backend Core</b>", td_bold),
            Paragraph("Java 17<br/>Spring Boot 3.3.x", td_style),
            Paragraph("APIs REST, regras de negócio do SmartFlow, gestão de chamados, técnicos, equipamentos, telemetria, autenticação/autorização (JWT), persistência de dados.", td_style)
        ],
        [
            Paragraph("<b>Reports & Analytics Service</b>", td_bold),
            Paragraph("Python 3.12<br/>FastAPI", td_style),
            Paragraph("Processamento analítico, agregação estatística, formatação de planilhas Excel corporativas (.xlsx com estilos Otis), geração de relatórios executivos em PDF com gráficos visuais e exportações de dashboards.", td_style)
        ],
        [
            Paragraph("<b>Banco de Dados</b>", td_bold),
            Paragraph("PostgreSQL (Prod)<br/>H2 (Dev)", td_style),
            Paragraph("Armazenamento de dados relacionais e transacionais com migrações ou mapeamento JPA.", td_style)
        ],
        [
            Paragraph("<b>Frontend</b>", td_bold),
            Paragraph("React + Vite + TypeScript", td_style),
            Paragraph("Interface visual que consome as APIs do Spring Boot e efetua download direto dos relatórios.", td_style)
        ],
    ]
    comp_table = Table(comp_data, colWidths=[100, 105, 310])
    comp_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#002D62")),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.HexColor("#F8FAFC"), colors.white]),
        ('TOPPADDING', (0, 0), (-1, -1), 4.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4.5),
    ]))
    story.append(comp_table)
    story.append(Spacer(1, 8))

    # 2. Decisões Técnicas e Pontos de Revisão
    story.append(Paragraph("2. Decisões Técnicas e Pontos de Revisão", h1_style))
    story.append(create_callout(
        "IMPORTANTE — Compatibilidade de Versões do Java & Spring Boot:",
        "O ambiente local possui <b>Java 17 (OpenJDK Temurin-17)</b> e <b>Python 3.12.10</b>. O <code>pom.xml</code> original continha versão 4.1.1 e Java 21 inválidos, que foram ajustados para <b>Spring Boot 3.3.4</b> e <b>Java 17</b>, garantindo compilação nativa com o Maven Wrapper (<code>mvnw.cmd</code>).",
        color_hex="#D97706",
        bg_hex="#FFFBEB"
    ))
    story.append(Spacer(1, 4))
    story.append(create_callout(
        "NOTA — Padrão de Comunicação Spring Boot ↔ Python:",
        "A arquitetura adota uma API interna em <b>FastAPI</b> rodando em background na porta 8000. O Spring Boot valida a sessão do usuário, aplica permissões hierárquicas (RBAC: Presidente, Gerente, Supervisor), extrai o escopo de dados e chama o microserviço Python via <code>RestClient</code>. O arquivo gerado é repassado ao cliente via HTTP streaming com cabeçalho <code>Content-Disposition: attachment</code>.",
        color_hex="#0284C7",
        bg_hex="#F0F9FF"
    ))
    story.append(Spacer(1, 8))

    # 3. Estrutura Proposta de Pastas
    story.append(Paragraph("3. Estrutura Proposta de Pastas", h1_style))
    tree_text = """SmartFlowIA/
├── Backend/
│   ├── smartflow-api/                 # Backend Java Spring Boot
│   │   ├── pom.xml                    # Spring Boot 3.3.4, Java 17, JPA, Web, Security, Lombok
│   │   └── src/
│   │       ├── main/
│   │       │   ├── java/br/com/otis/smartflow/
│   │       │   │   ├── SmartflowApiApplication.java
│   │       │   │   ├── config/        # CorsConfig, SecurityConfig, RestClientConfig
│   │       │   │   ├── controller/    # Equipments, Calls, Technicians, ReportsController
│   │       │   │   ├── dto/           # Request e Response DTOs
│   │       │   │   ├── model/         # Entidades JPA (Equipment, Call, Technician, etc.)
│   │       │   │   ├── repository/    # Spring Data JPA Repositories
│   │       │   │   ├── service/       # Regras de negócio e integração com Python
│   │       │   │   └── client/        # PythonReportsClient.java
│   │       │   └── resources/
│   │       │       └── application.yml
│   │
│   └── smartflow-reports/             # Serviço de Relatórios Python
│       ├── requirements.txt           # fastapi, uvicorn, pandas, openpyxl, reportlab, matplotlib
│       ├── main.py                    # Aplicação FastAPI
│       ├── config.py                  # Configurações e tokens internos
│       ├── routers/
│       │   └── reports.py             # Endpoints de geração de relatórios
│       ├── generators/
│       │   ├── executive_pdf.py       # Relatório Executivo Nacional (PDF)
│       │   ├── sla_excel.py           # Cumprimento de SLA por Polo (Excel/CSV)
│       │   ├── financial_dossier.py   # Dossiê Financeiro & DRE (Excel)
│       │   ├── predictive_report.py   # Inventário Preditivo & Falhas (Excel/PDF)
│       │   └── charts.py              # Gráficos embutidos (Matplotlib)
│       └── templates/                 # Estilos, cabeçalhos, logos da OTIS
│
└── FrontEnd/
    └── prototipo/                     # Frontend React já existente"""

    tree_table = Table([[Paragraph(f"<pre>{tree_text}</pre>", code_block_style)]], colWidths=[515])
    tree_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#0F172A")),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor("#334155")),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(tree_table)
    story.append(Spacer(1, 8))

    # PageBreak to ensure clean flow
    story.append(PageBreak())

    # 4. Modelagem de Relatórios & Dashboards Suportados
    story.append(Paragraph("4. Modelagem de Relatórios & Dashboards Suportados", h1_style))
    story.append(Paragraph(
        "Baseado nos relatórios definidos no protótipo (<code>ReportsModule.tsx</code>), o serviço Python fornecerá:",
        body_style
    ))

    reps = [
        ("1. Relatório Executivo Nacional (Presidência)", "PDF diagramado em alta resolução.",
         "Sumário executivo, disponibilidade global da frota (%), taxa de SLA, gráficos comparativos de custos e métricas preditivas."),
        ("2. Relatório de Cumprimento de SLA por Polo", "Excel estilizado (.xlsx) e CSV.",
         "Desempenho por supervisor/região, tempo de deslocamento (TA), tempo de solução (TB), chamados fora do prazo e índice de reincidência."),
        ("3. Dossiê Financeiro & DRE de Contratos", "Excel com abas e fórmulas (.xlsx).",
         "Receita por contrato, consumo de peças, horas técnicas aplicadas, margem operacional de cada contrato e alertas de risco financeiro."),
        ("4. Inventário Preditivo & Padrões de Falha", "PDF / Excel.",
         "Ranking de equipamentos por score de risco (0-100), componentes sob fadiga (portas AT120, drives regenerativos, cabos) e recomendações da IA."),
        ("5. Auditoria de Decisões: Supervisor vs IA", "PDF com tabela de evidências.",
         "Histórico de desvios operacionais entre a indicação do SmartFlow IA e a alocação manual feita pelo supervisor, com justificativas.")
    ]

    for r_title, r_fmt, r_content in reps:
        story.append(Paragraph(f"<b>{r_title}</b>", h2_style))
        story.append(Paragraph(f"• <b>Formato:</b> {r_fmt}", bullet_style))
        story.append(Paragraph(f"• <b>Conteúdo:</b> {r_content}", bullet_style))

    story.append(Spacer(1, 8))

    # 5. Plano de Implementação Passo a Passo
    story.append(Paragraph("5. Plano de Implementação Passo a Passo", h1_style))

    # Fase 1
    story.append(Paragraph("<b>Fase 1: Configuração e Correção do Spring Boot (Java)</b>", h2_style))
    story.append(Paragraph("• [✓] Atualizar <code>pom.xml</code>: Definir <code>spring-boot-starter-parent</code> 3.3.4 e <code>java.version</code> 17.", check_done_style))
    story.append(Paragraph("• [✓] Adicionar dependências essenciais: <code>spring-boot-starter-web</code>, <code>spring-boot-starter-data-jpa</code>, <code>h2</code> (dev), <code>postgresql</code> (prod), <code>lombok</code>, <code>springdoc-openapi-starter-webmvc-ui</code> (Swagger).", check_done_style))
    story.append(Paragraph("• [✓] Configurar <code>application.properties</code> com profile para banco em memória H2 e suporte a PostgreSQL.", check_done_style))
    story.append(Paragraph("• [✓] Compilar e validar a execução do Spring Boot com <code>.\\mvnw.cmd clean test</code>.", check_done_style))

    # Fase 2
    story.append(Paragraph("<b>Fase 2: Implementação de Domínio e REST API no Spring Boot</b>", h2_style))
    story.append(Paragraph("• [✓] Criar entidades de domínio: <code>Equipment</code>, <code>Technician</code>, <code>CallTicket</code>, <code>Contract</code>, <code>ReportRequest</code>.", check_done_style))
    story.append(Paragraph("• [✓] Criar repositórios JPA e serviços de consulta para alimentar as extrações de dados.", check_done_style))
    story.append(Paragraph("• [✓] Configurar <code>RestClient</code> para comunicação HTTP com o serviço Python.", check_done_style))
    story.append(Paragraph("• [✓] Criar <code>ReportsController</code>: <code>GET /api/v1/reports/types</code> e <code>GET /api/v1/reports/download/{reportType}</code>.", check_done_style))

    # Fase 3
    story.append(Paragraph("<b>Fase 3: Criação do Microsserviço de Relatórios em Python</b>", h2_style))
    story.append(Paragraph("• [✓] Criar diretório <code>Backend/smartflow-reports</code> com <code>requirements.txt</code> (fastapi, uvicorn, pandas, openpyxl, reportlab, matplotlib).", check_done_style))
    story.append(Paragraph("• [✓] Implementar geradores de relatórios: Módulo Excel (<code>openpyxl</code>) com paleta OTIS (tons de azul, ardósia, formatação de moeda).", check_done_style))
    story.append(Paragraph("• [✓] Implementar gerador de relatórios executivos em PDF (<code>reportlab</code>) com diagramação limpa, tabelas zebradas e paginação.", check_done_style))
    story.append(Paragraph("• [✓] Criar endpoints FastAPI correspondentes e testar geração autônoma.", check_done_style))

    # Fase 4
    story.append(Paragraph("<b>Fase 4: Integração Frontend ↔ Spring Boot ↔ Python</b>", h2_style))
    story.append(Paragraph("• [✓] Ajustar <code>ReportsModule.tsx</code> no Frontend para disparar download real na API Spring Boot.", check_done_style))
    story.append(Paragraph("• [✓] Adicionar feedback de progresso (loading spinner/toast de progresso) durante o download.", check_done_style))

    story.append(Spacer(1, 8))

    # 6. Plano de Verificação
    story.append(Paragraph("6. Plano de Verificação & Comandos de Execução", h1_style))

    verif_text = """# Testes Automatizados do Spring Boot (Java)
cd Backend/smartflow-api
.\\mvnw.cmd test

# Iniciar Serviço de Relatórios Python (Porta 8000)
cd Backend/smartflow-reports
uvicorn main:app --port 8000 --reload
# Documentação Swagger Python: http://localhost:8000/docs

# Iniciar Backend Java Spring Boot (Porta 8080)
cd Backend/smartflow-api
.\\mvnw.cmd spring-boot:run
# Swagger UI Spring Boot: http://localhost:8080/swagger-ui.html
# Console H2 Database:   http://localhost:8080/h2-console

# Iniciar Frontend React + Vite (Porta 3000 / 5173)
cd FrontEnd/prototipo
npm run dev"""

    cmd_table = Table([[Paragraph(f"<pre>{verif_text}</pre>", code_block_style)]], colWidths=[515])
    cmd_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#0F172A")),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor("#334155")),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
    ]))
    story.append(cmd_table)
    story.append(Spacer(1, 6))

    story.append(Paragraph(
        "<b>Verificação Manual no Navegador:</b>",
        h2_style
    ))
    story.append(Paragraph("1. Acesse o Swagger UI (<code>http://localhost:8080/swagger-ui.html</code>) e execute o endpoint <code>/api/v1/reports/download/executivo-nacional</code>.", bullet_style))
    story.append(Paragraph("2. No Frontend, acerte o módulo de Relatórios e clique em <b>Baixar Relatório</b> para testar o download do arquivo PDF/Excel gerado em tempo real.", bullet_style))

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF gerado com sucesso: {filename}")

if __name__ == '__main__':
    out_name = sys.argv[1] if len(sys.argv) > 1 else "Plano_Arquitetura_Backend_SmartFlow.pdf"
    build_pdf(out_name)
