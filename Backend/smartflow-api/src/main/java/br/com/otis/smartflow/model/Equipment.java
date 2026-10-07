package br.com.otis.smartflow.model;

import jakarta.persistence.*;

@Entity
@Table(name = "equipments")
public class Equipment {

    @Id
    private String id;

    @Column(nullable = false, unique = true)
    private String tag;

    @Column(nullable = false)
    private String name;

    private String model;
    private String type; // ELEVADOR_PASSAGEIROS, ELEVADOR_CARGA, ESCADA_ROLANTE
    private String customerName;
    private String buildingName;
    private String city;
    private String state;
    private String status; // OPERACIONAL, EM_RISCO, PARADO, MANUTENCAO

    private Integer predictiveRiskScore; // 0 - 100
    private String riskLevel; // BAIXO, MODERADO, ALTO, CRITICO
    private String riskExplanation;
    private Integer doorCycles;
    private Double totalDowntimeHours;

    public Equipment() {}

    public Equipment(String id, String tag, String name, String model, String type, 
                     String customerName, String buildingName, String city, String state, 
                     String status, Integer predictiveRiskScore, String riskLevel, 
                     String riskExplanation, Integer doorCycles, Double totalDowntimeHours) {
        this.id = id;
        this.tag = tag;
        this.name = name;
        this.model = model;
        this.type = type;
        this.customerName = customerName;
        this.buildingName = buildingName;
        this.city = city;
        this.state = state;
        this.status = status;
        this.predictiveRiskScore = predictiveRiskScore;
        this.riskLevel = riskLevel;
        this.riskExplanation = riskExplanation;
        this.doorCycles = doorCycles;
        this.totalDowntimeHours = totalDowntimeHours;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTag() { return tag; }
    public void setTag(String tag) { this.tag = tag; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getBuildingName() { return buildingName; }
    public void setBuildingName(String buildingName) { this.buildingName = buildingName; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getState() { return state; }
    public void setState(String state) { this.state = state; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Integer getPredictiveRiskScore() { return predictiveRiskScore; }
    public void setPredictiveRiskScore(Integer predictiveRiskScore) { this.predictiveRiskScore = predictiveRiskScore; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public String getRiskExplanation() { return riskExplanation; }
    public void setRiskExplanation(String riskExplanation) { this.riskExplanation = riskExplanation; }

    public Integer getDoorCycles() { return doorCycles; }
    public void setDoorCycles(Integer doorCycles) { this.doorCycles = doorCycles; }

    public Double getTotalDowntimeHours() { return totalDowntimeHours; }
    public void setTotalDowntimeHours(Double totalDowntimeHours) { this.totalDowntimeHours = totalDowntimeHours; }
}
