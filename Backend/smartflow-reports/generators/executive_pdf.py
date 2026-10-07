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
            self.drawString(130, 810, "|   Relatório Executivo Nacional (Presidência)")
            self.setStrokeColor(colors.HexColor("#CBD5E1"))
            self.setLineWidth(0.5)
            self.line(40, 804, 555, 804)

        self.setStrokeColor(colors.HexColor("#E2E8F0"))
        self.setLineWidth(0.5)
        self.line(40, 42, 555, 42)
        self.setFont("Helvetica", 8)
        self.setFillColor(colors.HexColor("#64748B"))
        self.drawString(40, 30, "OTIS Elevadores S/A — SmartFlow IA Analytics • Confidencial")
        page_str = f"Página {self._pageNumber} de {page_count}"
        self.drawRightString(555, 30, page_str)
        self.restoreState()

def generate_executive_pdf(data: dict = None) -> bytes:
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

    story.append(Paragraph("OTIS ELEVADORES — SMARTFLOW IA", subtitle_style))
    story.append(Paragraph("Relatório Executivo Nacional da Presidência", title_style))
    story.append(Paragraph("Consolidado de Disponibilidade Operacional, Cumprimento de SLA e Análise de Contratos", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=1.5, color=colors.HexColor("#002D62"), spaceAfter=10))

    # KPI Summary Cards
    kpis = [
        [
            Paragraph("<b>DISPONIBILIDADE GLOBAL</b><br/><font size='13' color='#002D62'><b>99.4%</b></font><br/><font color='#16A34A'>+0.3% vs meta</font>", body_style),
            Paragraph("<b>TAXA DE SLA GLOBAL</b><br/><font size='13' color='#002D62'><b>98.2%</b></font><br/><font color='#16A34A'>Meta: 95.0%</font>", body_style),
            Paragraph("<b>CHAMADOS ATENDIDOS</b><br/><font size='13' color='#002D62'><b>1.482</b></font><br/><font color='#64748B'>Neste mês</font>", body_style),
            Paragraph("<b>ECONOMIA PREVENTIVA IA</b><br/><font size='13' color='#002D62'><b>R$ 384.500</b></font><br/><font color='#16A34A'>Evitação de paradas</font>", body_style)
        ]
    ]
    kpi_table = Table(kpis, colWidths=[128, 128, 128, 128])
    kpi_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor("#F1F5F9")),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#E2E8F0")),
        ('PADDING', (0, 0), (-1, -1), 7),
    ]))
    story.append(kpi_table)
    story.append(Spacer(1, 10))

    story.append(Paragraph("1. Desempenho por Polo Regional", h1_style))
    polo_rows = [
        [Paragraph("Polo Regional", th_style), Paragraph("Total Equipamentos", th_style), Paragraph("Chamados Mês", th_style), Paragraph("SLA (%)", th_style), Paragraph("Tempo Médio Chegada (TA)", th_style), Paragraph("Status", th_style)],
        [Paragraph("São Paulo - Capital & ABC", td_bold), Paragraph("1.850", td_style), Paragraph("542", td_style), Paragraph("98.6%", td_style), Paragraph("28 min", td_style), Paragraph("<font color='#16A34A'><b>EXCELENTE</b></font>", td_style)],
        [Paragraph("Rio de Janeiro - Metropolitana", td_bold), Paragraph("920", td_style), Paragraph("315", td_style), Paragraph("97.8%", td_style), Paragraph("34 min", td_style), Paragraph("<font color='#16A34A'><b>CONFORME</b></font>", td_style)],
        [Paragraph("Belo Horizonte & Sul de MG", td_bold), Paragraph("640", td_style), Paragraph("198", td_style), Paragraph("98.9%", td_style), Paragraph("25 min", td_style), Paragraph("<font color='#16A34A'><b>EXCELENTE</b></font>", td_style)],
        [Paragraph("Curitiba & Região Sul", td_bold), Paragraph("710", td_style), Paragraph("224", td_style), Paragraph("99.1%", td_style), Paragraph("22 min", td_style), Paragraph("<font color='#16A34A'><b>EXCELENTE</b></font>", td_style)],
        [Paragraph("Brasília & Centro-Oeste", td_bold), Paragraph("430", td_style), Paragraph("121", td_style), Paragraph("96.5%", td_style), Paragraph("39 min", td_style), Paragraph("<font color='#CA8A04'><b>ATENÇÃO</b></font>", td_style)],
        [Paragraph("Nordeste (Salvador / Recife)", td_bold), Paragraph("580", td_style), Paragraph("182", td_style), Paragraph("97.2%", td_style), Paragraph("32 min", td_style), Paragraph("<font color='#16A34A'><b>CONFORME</b></font>", td_style)]
    ]
    t_polo = Table(polo_rows, colWidths=[140, 75, 70, 60, 105, 64])
    t_polo.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#002D62")),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.HexColor("#F8FAFC"), colors.white]),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(t_polo)
    story.append(Spacer(1, 10))

    story.append(Paragraph("2. Equipamentos Críticos em Monitoramento Preditivo", h1_style))
    eq_rows = [
        [Paragraph("Tag / Modelo", th_style), Paragraph("Cliente / Edifício", th_style), Paragraph("Score Risco", th_style), Paragraph("Componente em Fadiga", th_style), Paragraph("Ação Preditiva Recomendada", th_style)],
        [Paragraph("SP-GEN2-042 (Gen2 Comfort)", td_bold), Paragraph("Condomínio Faria Lima Tower", td_style), Paragraph("<font color='#DC2626'><b>89/100</b></font>", td_style), Paragraph("Operador de Portas AT120", td_style), Paragraph("Substituição de Roletes na preventiva de amanhã", td_style)],
        [Paragraph("RJ-SKY-108 (SkyRise HighRise)", td_bold), Paragraph("Centro Empresarial Botafogo", td_style), Paragraph("<font color='#DC2626'><b>84/100</b></font>", td_style), Paragraph("Inversor ReGen Drive", td_style), Paragraph("Inspeção de harmônicos e capacitores de potência", td_style)],
        [Paragraph("BH-HYD-019 (HydroFit)", td_bold), Paragraph("Hospital Mater Dei Contorno", td_style), Paragraph("<font color='#EA580C'><b>76/100</b></font>", td_style), Paragraph("Válvula Proporcional Hidráulica", td_style), Paragraph("Coleta de amostra de fluido e calibração", td_style)]
    ]
    t_eq = Table(eq_rows, colWidths=[120, 120, 55, 110, 109])
    t_eq.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor("#0369A1")),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.HexColor("#F8FAFC"), colors.white]),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    story.append(t_eq)

    doc.build(story, canvasmaker=NumberedCanvas)
    buffer.seek(0)
    return buffer.getvalue()
