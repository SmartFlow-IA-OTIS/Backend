package br.com.otis.smartflow.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.List;
import java.util.Map;

@Service
public class ReportsIntegrationService {

    private final RestClient restClient;

    public ReportsIntegrationService(@Value("${smartflow.reports.service-url:http://localhost:8000}") String reportsServiceUrl) {
        this.restClient = RestClient.builder()
                .baseUrl(reportsServiceUrl)
                .build();
    }

    public List<Map<String, Object>> getReportCatalog() {
        return restClient.get()
                .uri("/reports/types")
                .accept(MediaType.APPLICATION_JSON)
                .retrieve()
                .body(List.class);
    }

    public ResponseEntity<byte[]> downloadReport(String reportType) {
        return restClient.get()
                .uri("/reports/download/{reportId}", reportType)
                .retrieve()
                .toEntity(byte[].class);
    }
}
