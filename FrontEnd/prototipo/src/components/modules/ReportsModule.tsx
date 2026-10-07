import React, { useState } from 'react';
import { useApp } from '../../context/AppContext';
import { Download, FileText, Loader2 } from 'lucide-react';

export const ReportsModule: React.FC = () => {
  const { addToast } = useApp();
  const [downloadingReport, setDownloadingReport] = useState<string | null>(null);

  const getReportId = (title: string): string => {
    if (title.includes('SLA')) return 'sla-polos';
    if (title.includes('Financeiro') || title.includes('DRE')) return 'dossie-financeiro';
    if (title.includes('Preditivo') || title.includes('Desgaste')) return 'inventario-preditivo';
    if (title.includes('Auditoria')) return 'auditoria-decisoes';
    return 'executivo-nacional';
  };

  const handleExport = async (reportTitle: string) => {
    const reportId = getReportId(reportTitle);
    setDownloadingReport(reportTitle);

    addToast({
      type: 'info',
      title: 'Gerando Relatório',
      message: `Compilando dados no motor Python e preparando download de "${reportTitle}"...`
    });

    try {
      // Dispara o download pelo backend Spring Boot (porta 8080)
      const downloadUrl = `http://localhost:8080/api/v1/reports/download/${reportId}`;
      const response = await fetch(downloadUrl);
      
      if (!response.ok) {
        // Fallback direto para o microserviço Python na porta 8000 se o Spring Boot não estiver rodando no momento
        const fallbackUrl = `http://localhost:8000/reports/download/${reportId}`;
        const fallbackResp = await fetch(fallbackUrl);
        if (!fallbackResp.ok) throw new Error('Serviço de relatórios indisponível.');
        
        const blob = await fallbackResp.blob();
        triggerBlobDownload(blob, reportTitle, reportId);
      } else {
        const blob = await response.blob();
        triggerBlobDownload(blob, reportTitle, reportId);
      }

      addToast({
        type: 'success',
        title: 'Download Concluído',
        message: `Relatório "${reportTitle}" baixado com sucesso.`
      });
    } catch (err: any) {
      addToast({
        type: 'warning',
        title: 'Servidores Offline',
        message: `Para baixar em tempo real, inicie o Spring Boot (porta 8080) e o Python FastAPI (porta 8000).`
      });
    } finally {
      setDownloadingReport(null);
    }
  };

  const triggerBlobDownload = (blob: Blob, title: string, id: string) => {
    const ext = (id === 'executivo-nacional' || id === 'auditoria-decisoes') ? 'pdf' : 'xlsx';
    const timestamp = new Date().toISOString().slice(0, 10);
    const filename = `${id}_${timestamp}.${ext}`;
    
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    document.body.removeChild(a);
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 p-5 rounded-2xl bg-gradient-to-r from-slate-900 via-slate-900 to-indigo-950/40 border border-slate-800/90 shadow-sm">
        <div>
          <div className="flex items-center gap-2">
            <span className="px-2 py-0.5 rounded text-[10px] font-bold uppercase bg-cyan-500/20 text-cyan-300 border border-cyan-500/30">
              Auditoria & Prestação de Contas
            </span>
            <span className="text-xs text-slate-400 font-mono">Exportações Gerenciais (Spring Boot + Python Engine)</span>
          </div>
          <h1 className="text-xl sm:text-2xl font-bold text-white tracking-tight mt-1">
            Relatórios Operacionais & Executivos
          </h1>
          <p className="text-xs sm:text-sm text-slate-300">
            Exporte dados consolidados de SLA, custos por contrato, consumo de peças e evidências de intervenção da IA.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {[
          { title: 'Relatório Executivo Nacional (Presidência)', desc: 'Consolidado executivo com disponibilidade da frota, SLA global, margens contratuais e economia apurada.', format: 'PDF Executivo' },
          { title: 'Relatório de Cumprimento de SLA por Polo', desc: 'Desempenho dos supervisores, tempo médio de atendimento (TA/TB), horas técnicas e desvios.', format: 'Excel (.xlsx)' },
          { title: 'Dossiê Financeiro & DRE de Contratos', desc: 'Receita vs peças vs mão de obra vs deslocamento por cliente e alertas analíticos de margem.', format: 'Excel com DRE' },
          { title: 'Inventário Preditivo & Padrões de Falha', desc: 'Score de risco preditivo da frota cadastrada, telemetria de portas e histórico de intervenções.', format: 'Excel (.xlsx)' },
          { title: 'Auditoria de Decisões: Supervisor vs IA', desc: 'Aderência às recomendações do SmartFlow IA e justificativas operacionais registradas.', format: 'PDF Executivo' },
          { title: 'Relatório de Desgaste e Almoxarifado', desc: 'Vida útil observada vs teórica de componentes e alertas de estoque crítico.', format: 'Excel (.xlsx)' }
        ].map((rep, idx) => {
          const isCurrentLoading = downloadingReport === rep.title;
          return (
            <div
              key={idx}
              className="p-5 rounded-2xl bg-slate-900/90 border border-slate-800 space-y-4 flex flex-col justify-between"
            >
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <FileText className="w-5 h-5 text-cyan-400" />
                  <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-slate-800 text-slate-300 border border-slate-700">
                    {rep.format}
                  </span>
                </div>
                <h3 className="text-sm font-bold text-slate-100">{rep.title}</h3>
                <p className="text-xs text-slate-400 leading-relaxed">{rep.desc}</p>
              </div>

              <button
                disabled={isCurrentLoading}
                onClick={() => handleExport(rep.title)}
                className="w-full py-2.5 px-3 rounded-xl bg-slate-800 hover:bg-slate-750 text-slate-200 text-xs font-semibold flex items-center justify-center gap-2 cursor-pointer transition-colors disabled:opacity-50"
              >
                {isCurrentLoading ? (
                  <>
                    <Loader2 className="w-3.5 h-3.5 text-cyan-400 animate-spin" />
                    <span>Compilando...</span>
                  </>
                ) : (
                  <>
                    <Download className="w-3.5 h-3.5 text-cyan-400" />
                    <span>Baixar Relatório</span>
                  </>
                )}
              </button>
            </div>
          );
        })}
      </div>
    </div>
  );
};
