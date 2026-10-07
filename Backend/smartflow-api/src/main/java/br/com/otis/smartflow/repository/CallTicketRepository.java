package br.com.otis.smartflow.repository;

import br.com.otis.smartflow.model.CallTicket;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CallTicketRepository extends JpaRepository<CallTicket, String> {
    List<CallTicket> findByStatus(String status);
    List<CallTicket> findByPriority(String priority);
    List<CallTicket> findByCity(String city);
    List<CallTicket> findByAssignedTechnicianId(String technicianId);
}
