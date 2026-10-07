package br.com.otis.smartflow.controller;

import br.com.otis.smartflow.model.Equipment;
import br.com.otis.smartflow.repository.EquipmentRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/equipments")
@Tag(name = "Equipamentos & Elevadores", description = "Endpoints para consulta de inventário, telemetria e scores preditivos da frota")
public class EquipmentController {

    private final EquipmentRepository equipmentRepository;

    public EquipmentController(EquipmentRepository equipmentRepository) {
        this.equipmentRepository = equipmentRepository;
    }

    @GetMapping
    @Operation(summary = "Listar todos os equipamentos ou filtrar por cidade")
    public List<Equipment> getAllEquipments(@RequestParam(required = false) String city) {
        if (city != null && !city.isBlank()) {
            return equipmentRepository.findByCity(city);
        }
        return equipmentRepository.findAll();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obter detalhes de um equipamento específico por ID")
    public ResponseEntity<Equipment> getEquipmentById(@PathVariable String id) {
        return equipmentRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/risk/{riskLevel}")
    @Operation(summary = "Filtrar equipamentos por nível de risco preditivo (CRITICO, ALTO, MODERADO, BAIXO)")
    public List<Equipment> getEquipmentsByRisk(@PathVariable String riskLevel) {
        return equipmentRepository.findByRiskLevel(riskLevel.toUpperCase());
    }
}
