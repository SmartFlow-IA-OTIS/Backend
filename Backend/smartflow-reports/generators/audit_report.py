import os
from io import BytesIO
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable
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
        if self._pageNumber > 1:
            self.setFont("Helvetica-Bold", 8)
            self.setFillColor(colors.HexColor("#002D62"))
            self.drawString(40, 810, "OTIS SmartFlow IA")
            self.setFont("Helvetica", 8)
            self.setFillColor(colors.HexColor("#64748B"))
            self.drawString(130, 810, "|   Auditoria de Decisões: Supervisor vs IA")
            self.setStrokeColor(colors.HexColor("#CBD5E1"))
            self.setLineWidth(0.5)
            self.line(40, 804, 555, 804)

        self.setStrokeColor(colors.HexColor("#E2E8F0"))
        self.setLineWidth(0.5)
        self.line(40, 42, 555, 42)
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))
        self.drawString(40, 30, "OTIS Elevadores S/A — Governança Operacional • Confidencial")
        page_str = f"Página {self._pageNumber} de {page_count}"
        self.drawRightString(555, 30, page_str)
        self.restoreState()

def generate_audit_pdf(data: dict = None) -> bytes:
    buffer = BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=A4,
        leftMargin=40,
        rightMargin=40,
        topMargin=50,
        bottomMargin=55
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
        'H1',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=15,
        textColor=colors.HexColor("#002D62"),
        spaceBefore=10,
        spaceAfter=5
    )

    body_style = ParagraphStyle('Body', fontName='Helvetica', fontSize=8.5, leading=12, textColor=colors.HexColor("#1E293B"))
    th_style = ParagraphStyle('TH', fontName='Helvetica-Bold', fontSize=8, leading=10, textColor=colors.white)
    td_style = ParagraphStyle('TD', fontName='Helvetica', fontSize=7.5, leading=10, textColor=colors.HexColor("#1E293B"))
    td_bold = ParagraphStyle('TDB', fontName='Helvetica-Bold', fontSize=7.5, leading=10, textColor=colors.HexColor("#0F172A"))

    story = []

    story.append(Paragraph("OTIS ELEVADORES — SMARTFLOW IA GOVERNANÇA", subtitle_style))
    story.append(Paragraph("Auditoria de Decisões: Supervisor vs SmartFlow IA", title_style))
    story.append(Paragraph("Evidências de Aderência às Recomendações da IA, Desvios Operacionais e Justificativas", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=colors.HexColor("#002D62"), spaceAfter=10))

    # Metrics Summary
    summary_data = [
        [
            Paragraph("<b>TAXA DE ADERÊNCIA IA</b><br/><font size='13' color='#002D62'><b>94.6%</b></font><br/><font color='#16A34A'>Decisões acatadas</font>", body_style),
            Paragraph("<b>DESVIOS JUSTIFICADOS</b><br/><font size='13' color='#002D62'><b>5.4%</b></font><br/><font color='#64748B'>Com registro auditado</font>", body_style),
            Paragraph("<b>TEMPO ECONOMIZADO</b><br/><font size='13' color='#002D62'><b>-18 min</b></font><br/><font color='#16A34A'>Média por despacho</font>", body_style),
            Paragraph("<b>REINCIDÊNCIA ZERO</b><br/><font size='13' color='#002D62'><b>99.1%</b></font><br/><font color='#16A34A'>Quando IA foi acatada</font>", body_style)
        ]
    ]
    t_summary = Table(summary_data, colWidths=[128, 128, 128, 128])
    t_summary.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F1F5F9")),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('PADDING', (0, 0), (-1, -1), 7),
    ]))
    story.append(t_summary)
    story.append(Spacer(1, 10))

    story.append(Paragraph("Histórico Recente de Intervenções e Justificativas de Desvio", h1_style))

    rows = [
        [Paragraph("Chamado", th_style), Paragraph("Equipamento / Polo", th_style), Paragraph("Recomendação IA", th_style), Paragraph("Decisão do Supervisor", th_style), Paragraph("Justificativa Auditada", th_style)],
        [
            Paragraph("CH-2026-0098", td_bold),
            Paragraph("SP-GEN2-042<br/>São Paulo - ABC", td_style),
            Paragraph("Despachar Lucas Mendes (Técnico Portas AT120 a 4km)", td_style),
            Paragraph("<font color='#16A34A'><b>ACATADA</b></font><br/>Lucas Mendes", td_style),
            Paragraph("Atendimento concluído em 22 min. Troca de sapata efetuada.", td_style)
        ],
        [
            Paragraph("CH-2026-0102", td_bold),
            Paragraph("RJ-SKY-108<br/>Rio - Metropolitana", td_style),
            Paragraph("Despachar Rodrigo Santoro (Especialista ReGen)", td_style),
            Paragraph("<font color='#EA580C'><b>ALTERADA</b></font><br/>Thiago Morais", td_style),
            Paragraph("Rodrigo estava em rota com ferramentas de outro chamado de emergência no Centro.", td_style)
        ],
        [
            Paragraph("CH-2026-0115", td_bold),
            Paragraph("BH-HYD-019<br/>Belo Horizonte", td_style),
            Paragraph("Prioridade ALTA sugerida pela telemetria de pressão", td_style),
            Paragraph("<font color='#DC2626'><b>ELEVADA P/ CRÍTICO</b></font><br/>Renata Figueiredo", td_style),
            Paragraph("Hospital notificou que se tratava do elevador cirúrgico principal.", td_style)
        ]
    ]

    t_audit = Table(rows, colWidths=[70, 95, 125, 95, 130])
    t_audit.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#002D62")),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.HexColor("#F8FAFC"), colors.white]),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
    ]))
    story.append(t_audit)

    doc.build(story, canvasmaker=NumberedCanvas)
    buffer.seek(0)
    return buffer.getvalue()
