package br.com.otis.smartflow.repository;

import br.com.otis.smartflow.model.Technician;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TechnicianRepository extends JpaRepository<Technician, String> {
    List<Technician> findByCity(String city);
    List<Technician> findByStatus(String status);
}
