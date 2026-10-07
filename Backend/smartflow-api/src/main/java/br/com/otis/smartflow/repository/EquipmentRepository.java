package br.com.otis.smartflow.repository;

import br.com.otis.smartflow.model.Equipment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EquipmentRepository extends JpaRepository<Equipment, String> {
    List<Equipment> findByCity(String city);
    List<Equipment> findByRiskLevel(String riskLevel);
    List<Equipment> findByStatus(String status);
}
