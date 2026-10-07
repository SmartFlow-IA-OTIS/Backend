package br.com.otis.smartflow.controller;

import br.com.otis.smartflow.model.CallTicket;
import br.com.otis.smartflow.repository.CallTicketRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/calls")
@Tag(name = "Chamados & Ocorrências", description = "Gestão de ordens de serviço, priorização IA e despacho de técnicos")
public class CallTicketController {

    private final CallTicketRepository callTicketRepository;

    public CallTicketController(CallTicketRepository callTicketRepository) {
        this.callTicketRepository = callTicketRepository;
    }

    @GetMapping
    @Operation(summary = "Listar todos os chamados ou filtrar por status/prioridade")
    public List<CallTicket> getAllCalls(@RequestParam(required = false) String status,
                                        @RequestParam(required = false) String priority) {
        if (status != null && !status.isBlank()) {
            return callTicketRepository.findByStatus(status.toUpperCase());
        }
        if (priority != null && !priority.isBlank()) {
            return callTicketRepository.findByPriority(priority.toUpperCase());
        }
        return callTicketRepository.findAll();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Consultar chamado por ID")
    public ResponseEntity<CallTicket> getCallById(@PathVariable String id) {
        return callTicketRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @Operation(summary = "Criar novo chamado técnico")
    public CallTicket createCall(@RequestBody CallTicket ticket) {
        if (ticket.getId() == null || ticket.getId().isBlank()) {
            ticket.setId("call-" + System.currentTimeMillis());
        }
        return callTicketRepository.save(ticket);
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Atualizar status do chamado (ex: A_CAMINHO, EM_ATENDIMENTO, CONCLUIDO)")
    public ResponseEntity<CallTicket> updateCallStatus(@PathVariable String id, @RequestParam String status) {
        return callTicketRepository.findById(id).map(ticket -> {
            ticket.setStatus(status.toUpperCase());
            return ResponseEntity.ok(callTicketRepository.save(ticket));
        }).orElse(ResponseEntity.notFound().build());
    }
}
