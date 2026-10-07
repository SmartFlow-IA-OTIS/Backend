package br.com.otis.smartflow.controller;

import br.com.otis.smartflow.service.ReportsIntegrationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/reports")
@Tag(name = "Relatórios & Dashboards", description = "Endpoints para consulta e download de relatórios executivos compilados pelo motor Python")
public class ReportsController {

    private final ReportsIntegrationService reportsService;

    public ReportsController(ReportsIntegrationService reportsService) {
        this.reportsService = reportsService;
    }

    @GetMapping("/types")
    @Operation(summary = "Listar catálogo de relatórios disponíveis")
    public ResponseEntity<List<Map<String, Object>>> getAvailableReports() {
        try {
            return ResponseEntity.ok(reportsService.getReportCatalog());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).build();
        }
    }

    @GetMapping("/download/{reportType}")
    @Operation(summary = "Baixar relatório gerado em PDF ou Excel")
    public ResponseEntity<byte[]> downloadReport(@PathVariable String reportType) {
        try {
            ResponseEntity<byte[]> response = reportsService.downloadReport(reportType);
            
            HttpHeaders headers = new HttpHeaders();
            headers.putAll(response.getHeaders());
            
            return new ResponseEntity<>(
                    response.getBody(),
                    headers,
                    response.getStatusCode()
            );
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(("Erro ao comunicar com o serviço de relatórios Python: " + e.getMessage()).getBytes());
        }
    }
}
