import io
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

def generate_predictive_excel(data: dict = None) -> bytes:
    wb = Workbook()
    ws = wb.active
    ws.title = "Inventário Preditivo"

    title_font = Font(name="Calibri", size=16, bold=True, color="002D62")
    subtitle_font = Font(name="Calibri", size=10, italic=True, color="64748B")
    header_font = Font(name="Calibri", size=11, bold=True, color="FFFFFF")
    header_fill = PatternFill(start_color="002D62", end_color="002D62", fill_type="solid")
    zebra_fill = PatternFill(start_color="F8FAFC", end_color="F8FAFC", fill_type="solid")
    regular_font = Font(name="Calibri", size=10)
    bold_font = Font(name="Calibri", size=10, bold=True)
    crit_font = Font(name="Calibri", size=10, bold=True, color="DC2626")
    alert_font = Font(name="Calibri", size=10, bold=True, color="EA580C")
    ok_font = Font(name="Calibri", size=10, bold=True, color="16A34A")

    thin_border = Border(
        left=Side(style='thin', color='CBD5E1'),
        right=Side(style='thin', color='CBD5E1'),
        top=Side(style='thin', color='CBD5E1'),
        bottom=Side(style='thin', color='CBD5E1')
    )

    ws["A1"] = "OTIS SMARTFLOW IA — INVENTÁRIO PREDITIVO E PADRÕES DE FALHA"
    ws["A1"].font = title_font
    ws["A2"] = "Classificação de Risco por Telemetria IoT, Ciclos de Porta AT120 e Desgaste de Componentes"
    ws["A2"].font = subtitle_font

    headers = [
        "Tag Equipamento", "Edifício / Cliente", "Cidade/UF", "Modelo", 
        "Ciclos Porta", "Score Risco (0-100)", "Nível Risco", "Diagnóstico IA / Padrão Detectado"
    ]

    row_num = 4
    for col_num, h_text in enumerate(headers, 1):
        cell = ws.cell(row=row_num, column=col_num, value=h_text)
        cell.font = header_font
        cell.fill = header_fill
        cell.alignment = Alignment(horizontal="center", vertical="center")
        cell.border = thin_border
    ws.row_dimensions[row_num].height = 26

    eq_data = [
        ("SP-GEN2-042", "Faria Lima Tower", "São Paulo/SP", "Gen2 Comfort", 184500, 89, "CRÍTICO", "Vibração anômala no rolete AT120. Risco de travamento de porta iminente."),
        ("RJ-SKY-108", "Centro Empresarial Botafogo", "Rio de Janeiro/RJ", "SkyRise HighRise", 321000, 84, "CRÍTICO", "Aquecimento térmico ReGen Drive acima de 68°C em horário de pico."),
        ("BH-HYD-019", "Hospital Mater Dei Contorno", "Belo Horizonte/MG", "HydroFit", 94200, 76, "ALTO", "Flutuação de pressão na válvula proporcional durante nivelamento."),
        ("PR-GEN2-211", "Shopping Mueller Curitiba", "Curitiba/PR", "Gen2 Life", 215000, 71, "ALTO", "Resistividade elétrica nas cintas de tração CSB atingiu 82% do limite."),
        ("SP-ESC-005", "Shopping Eldorado", "São Paulo/SP", "Escada 606N", 450000, 42, "MODERADO", "Desgaste uniforme nos segmentos de pente plástico. Operação normal."),
        ("DF-GEN2-014", "Centro Empresarial Brasília", "Brasília/DF", "Gen2 Premier", 88000, 18, "BAIXO", "Todos os parâmetros de telemetria dentro dos limites nominais.")
    ]

    for item in eq_data:
        row_num += 1
        ws.row_dimensions[row_num].height = 20
        is_zebra = (row_num % 2 == 0)

        for col_num, val in enumerate(item, 1):
            cell = ws.cell(row=row_num, column=col_num, value=val)
            cell.font = regular_font
            cell.border = thin_border
            if is_zebra:
                cell.fill = zebra_fill

            if col_num in (5, 6):
                cell.alignment = Alignment(horizontal="right", vertical="center")
            elif col_num in (1, 3, 4, 7):
                cell.alignment = Alignment(horizontal="center", vertical="center")
            else:
                cell.alignment = Alignment(horizontal="left", vertical="center")

            if col_num == 7:
                if val == "CRÍTICO":
                    cell.font = crit_font
                elif val == "ALTO":
                    cell.font = alert_font
                else:
                    cell.font = ok_font

    for col in ws.columns:
        max_len = max(len(str(cell.value or '')) for cell in col)
        col_letter = get_column_letter(col[0].column)
        ws.column_dimensions[col_letter].width = max(max_len + 4, 14)

    output = io.BytesIO()
    wb.save(output)
    output.seek(0)
    return output.getvalue()
