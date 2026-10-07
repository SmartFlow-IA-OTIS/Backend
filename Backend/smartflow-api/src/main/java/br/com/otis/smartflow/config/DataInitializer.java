package br.com.otis.smartflow.config;

import br.com.otis.smartflow.model.CallTicket;
import br.com.otis.smartflow.model.Equipment;
import br.com.otis.smartflow.model.Technician;
import br.com.otis.smartflow.repository.CallTicketRepository;
import br.com.otis.smartflow.repository.EquipmentRepository;
import br.com.otis.smartflow.repository.TechnicianRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {

    private final EquipmentRepository equipmentRepository;
    private final TechnicianRepository technicianRepository;
    private final CallTicketRepository callTicketRepository;

    public DataInitializer(EquipmentRepository equipmentRepository,
                           TechnicianRepository technicianRepository,
                           CallTicketRepository callTicketRepository) {
        this.equipmentRepository = equipmentRepository;
        this.technicianRepository = technicianRepository;
        this.callTicketRepository = callTicketRepository;
    }

    @Override
    public void run(String... args) {
        if (equipmentRepository.count() == 0) {
            Equipment eq1 = new Equipment(
                    "eq-001", "SP-GEN2-042", "Elevador Social 01", "Gen2 Comfort", "ELEVADOR_PASSAGEIROS",
                    "Condomínio Faria Lima Tower", "Torre A", "São Paulo", "SP",
                    "EM_RISCO", 89, "CRITICO",
                    "Vibração anômala no rolete AT120. Risco de travamento de porta iminente.",
                    184500, 1.2
            );

            Equipment eq2 = new Equipment(
                    "eq-002", "RJ-SKY-108", "Elevador Panorâmico Torre Sul", "SkyRise HighRise", "ELEVADOR_PANORAMICO",
                    "Centro Empresarial Botafogo", "Torre Sul", "Rio de Janeiro", "RJ",
                    "OPERACIONAL", 84, "CRITICO",
                    "Aquecimento térmico ReGen Drive acima de 68°C em horário de pico.",
                    321000, 0.0
            );

            Equipment eq3 = new Equipment(
                    "eq-003", "BH-HYD-019", "Elevador de Emergência / Macas", "HydroFit", "ELEVADOR_CARGA",
                    "Hospital Mater Dei Contorno", "Prédio Principal", "Belo Horizonte", "MG",
                    "OPERACIONAL", 76, "ALTO",
                    "Flutuação de pressão na válvula proporcional durante o nivelamento de piso.",
                    94200, 0.5
            );

            Equipment eq4 = new Equipment(
                    "eq-004", "PR-GEN2-211", "Elevador Serviço 02", "Gen2 Life", "ELEVADOR_PASSAGEIROS",
                    "Shopping Mueller Curitiba", "Edifício Garagem", "Curitiba", "PR",
                    "OPERACIONAL", 71, "ALTO",
                    "Resistividade elétrica nas cintas de tração CSB atingiu 82% do limite de desgaste.",
                    215000, 0.0
            );

            Equipment eq5 = new Equipment(
                    "eq-005", "SP-ESC-005", "Escada Rolante Acesso Principal", "Escada 606N", "ESCADA_ROLANTE",
                    "Shopping Eldorado", "Vão Central", "São Paulo", "SP",
                    "OPERACIONAL", 42, "MODERADO",
                    "Desgaste uniforme nos segmentos de pente plástico. Operação normal.",
                    450000, 0.0
            );

            equipmentRepository.saveAll(List.of(eq1, eq2, eq3, eq4, eq5));
        }

        if (technicianRepository.count() == 0) {
            Technician t1 = new Technician(
                    "tech-001", "Lucas Mendes", "lucas.mendes@otis.com", "(11) 98765-4321", "DISPONIVEL",
                    "Carlos Silveira", "São Paulo", "SP",
                    List.of("Sistema de Portas AT120", "Drives ReGen", "Comando GECB"),
                    42, 24, 38, 99.2, "Fiorino OTIS-042"
            );

            Technician t2 = new Technician(
                    "tech-002", "Rodrigo Santoro", "rodrigo.santoro@otis.com", "(21) 97654-3210", "EM_ATENDIMENTO",
                    "Marcos Vinicius", "Rio de Janeiro", "RJ",
                    List.of("SkyRise HighSpeed", "Automação", "Quadro E2"),
                    36, 31, 45, 97.8, "Kangoo OTIS-108"
            );

            Technician t3 = new Technician(
                    "tech-003", "Beatriz Lima", "beatriz.lima@otis.com", "(31) 96543-2109", "A_CAMINHO",
                    "Renata Figueiredo", "Belo Horizonte", "MG",
                    List.of("Hidráulica HydroFit", "Válvulas Proporcionais", "Segurança"),
                    39, 21, 36, 98.9, "Strada OTIS-019"
            );

            technicianRepository.saveAll(List.of(t1, t2, t3));
        }

        if (callTicketRepository.count() == 0) {
            CallTicket c1 = new CallTicket(
                    "call-001", "CH-2026-0104", "eq-001", "SP-GEN2-042",
                    "Condomínio Faria Lima Tower", "Torre A", "São Paulo",
                    "CRITICO", "EM_ATENDIMENTO",
                    "Porta do 14º andar com ruído metálico e fechamento intermitente.",
                    false, false, "tech-001", "Lucas Mendes",
                    "Substituição imediata dos roletes AT120 recomendada pelo SmartFlow IA."
            );

            CallTicket c2 = new CallTicket(
                    "call-002", "CH-2026-0105", "eq-002", "RJ-SKY-108",
                    "Centro Empresarial Botafogo", "Torre Sul", "Rio de Janeiro",
                    "ALTO", "A_CAMINHO",
                    "Variação de velocidade durante aceleração expressa entre andares 20 e 35.",
                    false, false, "tech-002", "Rodrigo Santoro",
                    "Calibração de ganho de velocidade no ReGen Drive sugerida pela IA."
            );

            callTicketRepository.saveAll(List.of(c1, c2));
        }

        System.out.println(">>> SmartFlow DataInitializer: Dados iniciais carregados (5 Equipamentos, 3 Técnicos, 2 Chamados).");
    }
}
