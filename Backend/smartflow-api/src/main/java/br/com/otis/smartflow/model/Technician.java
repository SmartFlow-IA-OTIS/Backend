package br.com.otis.smartflow.model;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "technicians")
public class Technician {

    @Id
    private String id;

    @Column(nullable = false)
    private String name;

    private String email;
    private String phone;
    private String status; // DISPONIVEL, A_CAMINHO, EM_ATENDIMENTO, ATRASADO, OFFLINE
    private String supervisorName;
    private String city;
    private String state;

    @ElementCollection
    @CollectionTable(name = "technician_specialties", joinColumns = @JoinColumn(name = "technician_id"))
    @Column(name = "specialty")
    private List<String> specialties;

    private Integer completedCallsMonth;
    private Integer avgArrivalTimeMin; // TA
    private Integer avgSolutionTimeMin; // TB
    private Double slaComplianceRate; // ex: 98.4
    private String assignedVehicle;

    public Technician() {}

    public Technician(String id, String name, String email, String phone, String status, 
                      String supervisorName, String city, String state, List<String> specialties, 
                      Integer completedCallsMonth, Integer avgArrivalTimeMin, Integer avgSolutionTimeMin, 
                      Double slaComplianceRate, String assignedVehicle) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.status = status;
        this.supervisorName = supervisorName;
        this.city = city;
        this.state = state;
        this.specialties = specialties;
        this.completedCallsMonth = completedCallsMonth;
        this.avgArrivalTimeMin = avgArrivalTimeMin;
        this.avgSolutionTimeMin = avgSolutionTimeMin;
        this.slaComplianceRate = slaComplianceRate;
        this.assignedVehicle = assignedVehicle;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getSupervisorName() { return supervisorName; }
    public void setSupervisorName(String supervisorName) { this.supervisorName = supervisorName; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public List<String> getSpecialties() { return specialties; }
    public void setSpecialties(List<String> specialties) { this.specialties = specialties; }

    public Integer getCompletedCallsMonth() { return completedCallsMonth; }
    public void setCompletedCallsMonth(Integer completedCallsMonth) { this.completedCallsMonth = completedCallsMonth; }

    public Integer getAvgArrivalTimeMin() { return avgArrivalTimeMin; }
    public void setAvgArrivalTimeMin(Integer avgArrivalTimeMin) { this.avgArrivalTimeMin = avgArrivalTimeMin; }

    public Integer getAvgSolutionTimeMin() { return avgSolutionTimeMin; }
    public void setAvgSolutionTimeMin(Integer avgSolutionTimeMin) { this.avgSolutionTimeMin = avgSolutionTimeMin; }

    public Double getSlaComplianceRate() { return slaComplianceRate; }
    public void setSlaComplianceRate(Double slaComplianceRate) { this.slaComplianceRate = slaComplianceRate; }

    public String getAssignedVehicle() { return assignedVehicle; }
    public void setAssignedVehicle(String assignedVehicle) { this.assignedVehicle = assignedVehicle; }
}
