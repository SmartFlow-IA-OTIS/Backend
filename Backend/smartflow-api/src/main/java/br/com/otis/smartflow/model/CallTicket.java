package br.com.otis.smartflow.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "call_tickets")
public class CallTicket {

    @Id
    private String id;

    @Column(nullable = false, unique = true)
    private String callNumber; // ex: "CH-2024-0891"

    private String equipmentId;
    private String equipmentTag;
    private String customerName;
    private String buildingName;
    private String city;

    private String priority; // CRITICO, ALTO, MEDIO, BAIXO
    private String status;   // CRIADO, CONTACTADO, ACEITO, A_CAMINHO, EM_ATENDIMENTO, CONCLUIDO, CANCELADO

    @Column(length = 1000)
    private String problemDescription;

    private Boolean hasTrappedPassenger;
    private Boolean isCarStopped;

    private String assignedTechnicianId;
    private String assignedTechnicianName;

    @Column(length = 1000)
    private String aiRecommendation;

    private LocalDateTime createdAt;
    private LocalDateTime completedAt;

    public CallTicket() {}

    public CallTicket(String id, String callNumber, String equipmentId, String equipmentTag, 
                      String customerName, String buildingName, String city, String priority, 
                      String status, String problemDescription, Boolean hasTrappedPassenger, 
                      Boolean isCarStopped, String assignedTechnicianId, String assignedTechnicianName, 
                      String aiRecommendation) {
        this.id = id;
        this.callNumber = callNumber;
        this.equipmentId = equipmentId;
        this.equipmentTag = equipmentTag;
        this.customerName = customerName;
        this.buildingName = buildingName;
        this.city = city;
        this.priority = priority;
        this.status = status;
        this.problemDescription = problemDescription;
        this.hasTrappedPassenger = hasTrappedPassenger;
        this.isCarStopped = isCarStopped;
        this.assignedTechnicianId = assignedTechnicianId;
        this.assignedTechnicianName = assignedTechnicianName;
        this.aiRecommendation = aiRecommendation;
        this.createdAt = LocalDateTime.now();
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getCallNumber() { return callNumber; }
    public void setCallNumber(String callNumber) { this.callNumber = callNumber; }

    public String getEquipmentId() { return equipmentId; }
    public void setEquipmentId(String equipmentId) { this.equipmentId = equipmentId; }

    public String getEquipmentTag() { return equipmentTag; }
    public void setEquipmentTag(String equipmentTag) { this.equipmentTag = equipmentTag; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getBuildingName() { return buildingName; }
    public void setBuildingName(String buildingName) { this.buildingName = buildingName; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getPriority() { return priority; }
    public void setPriority(String priority) { this.priority = priority; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getProblemDescription() { return problemDescription; }
    public void setProblemDescription(String problemDescription) { this.problemDescription = problemDescription; }

    public Boolean getHasTrappedPassenger() { return hasTrappedPassenger; }
    public void setHasTrappedPassenger(Boolean hasTrappedPassenger) { this.hasTrappedPassenger = hasTrappedPassenger; }

    public Boolean getIsCarStopped() { return isCarStopped; }
    public void setIsCarStopped(Boolean isCarStopped) { this.isCarStopped = isCarStopped; }

    public String getAssignedTechnicianId() { return assignedTechnicianId; }
    public void setAssignedTechnicianId(String assignedTechnicianId) { this.assignedTechnicianId = assignedTechnicianId; }

    public String getAssignedTechnicianName() { return assignedTechnicianName; }
    public void setAssignedTechnicianName(String assignedTechnicianName) { this.assignedTechnicianName = assignedTechnicianName; }

    public String getAiRecommendation() { return aiRecommendation; }
    public void setAiRecommendation(String aiRecommendation) { this.aiRecommendation = aiRecommendation; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }
}
