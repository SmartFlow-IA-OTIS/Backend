package br.com.otis.smartflow.controller;

import br.com.otis.smartflow.model.Technician;
import br.com.otis.smartflow.repository.TechnicianRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/technicians")
@Tag(name = "Técnicos em Campo", description = "Endpoints para monitoramento de rotas, status e performance de técnicos OTIS")
public class TechnicianController {

    private final TechnicianRepository technicianRepository;

    public TechnicianController(TechnicianRepository technicianRepository) {
        this.technicianRepository = technicianRepository;
    }

    @GetMapping
    @Operation(summary = "Listar todos os técnicos ou filtrar por cidade/status")
    public List<Technician> getAllTechnicians(@RequestParam(required = false) String city,
                                              @RequestParam(required = false) String status) {
        if (city != null && !city.isBlank()) {
            return technicianRepository.findByCity(city);
        }
        if (status != null && !status.isBlank()) {
            return technicianRepository.findByStatus(status.toUpperCase());
        }
        return technicianRepository.findAll();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obter dados de um técnico específico")
    public ResponseEntity<Technician> getTechnicianById(@PathVariable String id) {
        return technicianRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}
