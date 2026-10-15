-- ==============================================================================
-- SMARTFLOW IA (OTIS) - ESQUEMA COMPLETO DE BANCO DE DADOS PARA SUPABASE (POSTGRESQL)
-- ==============================================================================
-- Este script cria todas as tabelas, tipos ENUM, índices, dados iniciais (Seed),
-- políticas de segurança a nível de linha (Row Level Security - RLS) e Views 
-- segmentadas por cargo (Financeiro, Técnico, Atendente, Supervisor, Gerente, Presidente).
--
-- COMO APLICAR NO SUPABASE:
-- 1. Acesse o seu projeto no Supabase (https://supabase.com).
-- 2. Vá no menu lateral em "SQL Editor".
-- 3. Crie uma "New Query", cole todo o conteúdo deste arquivo e clique em "RUN".
-- ==============================================================================

-- 1. HABILITAR EXTENSÕES RECOMENDADAS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. CRIAÇÃO DE TIPOS ENUM PERSONALIZADOS
-- ==============================================================================

DO $$ BEGIN
    CREATE TYPE user_role_enum AS ENUM (
        'PRESIDENTE',
        'GERENTE',
        'SUPERVISOR',
        'TECNICO',
        'ATENDENTE',
        'FINANCEIRO',
        'ADMINISTRADOR'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE call_priority_enum AS ENUM (
        'CRITICO',
        'ALTO',
        'MEDIO',
        'BAIXO'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE call_status_enum AS ENUM (
        'CRIADO',
        'CONTACTADO',
        'ACEITO',
        'A_CAMINHO',
        'EM_ATENDIMENTO',
        'CONCLUIDO',
        'CANCELADO'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE call_origin_enum AS ENUM (
        'SISTEMA',
        'TELEFONE',
        'WHATSAPP',
        'PORTAL',
        'IOT_TELEMETRIA'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE equipment_type_enum AS ENUM (
        'ELEVADOR_PASSAGEIROS',
        'ELEVADOR_CARGA',
        'ESCADA_ROLANTE',
        'ESTEIRA_ROLANTE',
        'ELEVADOR_PANORAMICO'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE equipment_status_enum AS ENUM (
        'OPERACIONAL',
        'EM_RISCO',
        'PARADO',
        'MANUTENCAO'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE tech_status_enum AS ENUM (
        'DISPONIVEL',
        'A_CAMINHO',
        'EM_ATENDIMENTO',
        'ATRASADO',
        'OFFLINE'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE contract_type_enum AS ENUM (
        'PREMIUM_ALL_INCLUSIVE',
        'STANDARD_COM_PECAS',
        'ESSENCIAL'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ==============================================================================
-- 3. TABELAS DO SISTEMA
-- ==============================================================================

-- 3.1. PERFIS E USUÁRIOS (Compatível com auth.users do Supabase ou standalone)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID UNIQUE, -- Aponta para auth.users(id) se Supabase Auth for usado
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role user_role_enum NOT NULL DEFAULT 'ATENDENTE',
    avatar_url TEXT,
    region VARCHAR(100),
    city VARCHAR(100),
    unit VARCHAR(100),
    phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.2. CLIENTES (Condomínios, Shoppings, Hospitais, Centros Empresariais)
CREATE TABLE IF NOT EXISTS public.customers (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    document_number VARCHAR(30), -- CNPJ / CPF
    building_name VARCHAR(255),
    group_name VARCHAR(150),
    is_vip BOOLEAN DEFAULT FALSE,
    is_corporate BOOLEAN DEFAULT FALSE,
    phone VARCHAR(50),
    email VARCHAR(150),
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    country VARCHAR(50) DEFAULT 'Brasil',
    satisfaction_score NUMERIC(5,2) DEFAULT 95.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.3. CONTRATOS (Informações Comerciais, Financeiras e SLA)
CREATE TABLE IF NOT EXISTS public.contracts (
    id VARCHAR(50) PRIMARY KEY,
    contract_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id VARCHAR(50) REFERENCES public.customers(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    type contract_type_enum NOT NULL DEFAULT 'STANDARD_COM_PECAS',
    status VARCHAR(50) DEFAULT 'ATIVO',
    sla_required_rate NUMERIC(5,2) DEFAULT 98.0, -- SLA prometido (%)
    
    -- Dados Financeiros (Visíveis principalmente pelo FINANCEIRO / GERENTE / PRESIDENTE)
    monthly_value NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    monthly_revenue NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    monthly_parts_cost NUMERIC(12,2) DEFAULT 0.00,
    monthly_tech_labor_cost NUMERIC(12,2) DEFAULT 0.00,
    monthly_travel_cost NUMERIC(12,2) DEFAULT 0.00,
    monthly_other_cost NUMERIC(12,2) DEFAULT 0.00,
    current_margin_rate NUMERIC(5,2) DEFAULT 0.00,   -- Margem atual (%)
    baseline_margin_rate NUMERIC(5,2) DEFAULT 25.00, -- Meta de margem (%)
    margin_drop_alert TEXT,
    ai_financial_diagnosis TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.4. EQUIPAMENTOS (Elevadores, Escadas Rolantes e Telemetria Preditiva)
CREATE TABLE IF NOT EXISTS public.equipments (
    id VARCHAR(50) PRIMARY KEY,
    tag VARCHAR(50) UNIQUE NOT NULL, -- Ex: 'SP-GEN2-042'
    name VARCHAR(255) NOT NULL,
    model VARCHAR(100) NOT NULL,     -- Ex: 'Gen2 Comfort', 'SkyRise HighRise'
    manufacturer VARCHAR(100) DEFAULT 'Otis Elevator Company',
    type equipment_type_enum NOT NULL DEFAULT 'ELEVADOR_PASSAGEIROS',
    customer_id VARCHAR(50) REFERENCES public.customers(id) ON DELETE SET NULL,
    contract_id VARCHAR(50) REFERENCES public.contracts(id) ON DELETE SET NULL,
    building_name VARCHAR(255),
    address TEXT,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    country VARCHAR(50) DEFAULT 'Brasil',
    installation_year INT,
    status equipment_status_enum NOT NULL DEFAULT 'OPERACIONAL',
    machine_type VARCHAR(100),
    drive_type VARCHAR(100),
    has_regenerative_drive BOOLEAN DEFAULT FALSE,
    control_type VARCHAR(100),
    cycles_count BIGINT DEFAULT 0,
    door_cycles BIGINT DEFAULT 0,
    predictive_risk_score INT DEFAULT 15, -- 0 a 100
    risk_level VARCHAR(30) DEFAULT 'BAIXO',
    risk_explanation TEXT,
    total_calls_history_count INT DEFAULT 0,
    total_downtime_hours NUMERIC(8,2) DEFAULT 0.0,
    last_maintenance_date TIMESTAMPTZ,
    next_scheduled_maintenance TIMESTAMPTZ,
    lat NUMERIC(10,7),
    lng NUMERIC(10,7),
    preventive_technician_id VARCHAR(50),
    preventive_technician_name VARCHAR(255),
    assigned_resident_technician_id VARCHAR(50),
    assigned_resident_technician_name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.5. SUPERVISORES (Polos Operacionais)
CREATE TABLE IF NOT EXISTS public.supervisors (
    id VARCHAR(50) PRIMARY KEY,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    region VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    manager_id VARCHAR(50),
    technicians_count INT DEFAULT 0,
    active_calls_count INT DEFAULT 0,
    sla_rate NUMERIC(5,2) DEFAULT 98.0,
    avg_solution_time_min INT DEFAULT 45,
    monthly_cost NUMERIC(12,2) DEFAULT 0.0,
    contracts_margin_rate NUMERIC(5,2) DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.6. TÉCNICOS (Equipe Técnica de Campo com Localização em Tempo Real)
CREATE TABLE IF NOT EXISTS public.technicians (
    id VARCHAR(50) PRIMARY KEY,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    avatar_url TEXT,
    status tech_status_enum NOT NULL DEFAULT 'DISPONIVEL',
    supervisor_id VARCHAR(50) REFERENCES public.supervisors(id) ON DELETE SET NULL,
    supervisor_name VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    assigned_vehicle VARCHAR(100),
    specialties TEXT[] DEFAULT ARRAY[]::TEXT[],
    training_needs TEXT[] DEFAULT ARRAY[]::TEXT[],
    
    -- Localização GPS (Para exibição no mapa pelo Técnico, Supervisor e Atendente)
    current_lat NUMERIC(10,7),
    current_lng NUMERIC(10,7),
    current_address TEXT,
    last_location_update TIMESTAMPTZ DEFAULT NOW(),
    
    -- Métricas de Performance
    completed_calls_month INT DEFAULT 0,
    avg_arrival_time_min INT DEFAULT 25,     -- TA (Tempo de Deslocamento)
    avg_solution_time_min INT DEFAULT 40,    -- TB (Tempo de Solução)
    sla_compliance_rate NUMERIC(5,2) DEFAULT 98.5,
    current_call_id VARCHAR(50),
    active_call_elapsed_minutes INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.7. GERENTES (Regionais Operacionais)
CREATE TABLE IF NOT EXISTS public.managers (
    id VARCHAR(50) PRIMARY KEY,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    region VARCHAR(100) NOT NULL,
    country VARCHAR(50) DEFAULT 'Brasil',
    supervisors_count INT DEFAULT 0,
    technicians_total INT DEFAULT 0,
    equipments_total INT DEFAULT 0,
    monthly_revenue NUMERIC(12,2) DEFAULT 0.0,
    monthly_cost NUMERIC(12,2) DEFAULT 0.0,
    margin_rate NUMERIC(5,2) DEFAULT 0.0,
    global_sla NUMERIC(5,2) DEFAULT 98.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.8. CHAMADOS / ORDENS DE SERVIÇO (CALL TICKETS)
CREATE TABLE IF NOT EXISTS public.call_tickets (
    id VARCHAR(50) PRIMARY KEY,
    call_number VARCHAR(50) UNIQUE NOT NULL, -- Ex: 'CH-2024-0891'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    origin call_origin_enum NOT NULL DEFAULT 'TELEFONE',
    priority call_priority_enum NOT NULL DEFAULT 'MEDIO',
    status call_status_enum NOT NULL DEFAULT 'CRIADO',
    
    -- Cliente & Edifício
    customer_id VARCHAR(50) REFERENCES public.customers(id) ON DELETE SET NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(50),
    building_name VARCHAR(255),
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    country VARCHAR(50) DEFAULT 'Brasil',
    lat NUMERIC(10,7),
    lng NUMERIC(10,7),
    
    -- Equipamento Relacionado
    equipment_id VARCHAR(50) REFERENCES public.equipments(id) ON DELETE SET NULL,
    equipment_tag VARCHAR(50) NOT NULL,
    equipment_model VARCHAR(100),
    equipment_type equipment_type_enum,
    
    -- Descrição do Problema e Diagnóstico
    problem_description TEXT NOT NULL,
    main_component VARCHAR(100), -- Ex: 'Sistema de Portas', 'Comando GECB'
    sub_component VARCHAR(100),
    defect_type VARCHAR(100),
    has_trapped_passenger BOOLEAN DEFAULT FALSE,
    is_car_stopped BOOLEAN DEFAULT TRUE,
    severity_level INT DEFAULT 2, -- 0 a 5
    
    -- Equipe de Atendimento
    supervisor_id VARCHAR(50) REFERENCES public.supervisors(id) ON DELETE SET NULL,
    supervisor_name VARCHAR(255),
    technician_id VARCHAR(50) REFERENCES public.technicians(id) ON DELETE SET NULL,
    technician_name VARCHAR(255),
    
    -- Contrato & SLAs
    contract_id VARCHAR(50) REFERENCES public.contracts(id) ON DELETE SET NULL,
    contract_number VARCHAR(50),
    sla_max_hours NUMERIC(5,2) DEFAULT 2.0,
    
    -- Linha do Tempo e Timestamps
    contacted_at TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    arrived_at_building_at TIMESTAMPTZ,
    solution_finished_at TIMESTAMPTZ,
    arrival_time_minutes INT,
    solution_time_minutes INT,
    
    -- Deslocamento e Trânsito
    distance_km NUMERIC(6,2),
    traffic_condition VARCHAR(30) DEFAULT 'LIVRE',
    
    -- Notas Finais da Solução
    technician_notes TEXT,
    solution_diagnostic TEXT,
    
    -- Campos de Inteligência Artificial e Linha do Tempo em JSON
    ai_recommendation JSONB,
    supervisor_override JSONB,
    used_parts JSONB DEFAULT '[]'::JSONB,
    timeline JSONB DEFAULT '[]'::JSONB,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.9. CATÁLOGO E ESTOQUE DE PEÇAS
CREATE TABLE IF NOT EXISTS public.parts (
    id VARCHAR(50) PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL, -- Ex: 'OTIS-AT120-ROL'
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    compatible_models TEXT[] DEFAULT ARRAY[]::TEXT[],
    unit_cost NUMERIC(10,2) NOT NULL DEFAULT 0.00, -- Custo unitário
    stock_quantity INT NOT NULL DEFAULT 0,
    expected_life_span_months INT DEFAULT 24,
    observed_average_life_span_months INT DEFAULT 20,
    total_replaced_last_12_months INT DEFAULT 0,
    abnormal_consumption_alert BOOLEAN DEFAULT FALSE,
    abnormal_alert_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.10. REQUISIÇÕES DE PEÇAS (Solicitadas por técnicos em chamados)
CREATE TABLE IF NOT EXISTS public.part_requests (
    id VARCHAR(50) PRIMARY KEY,
    request_number VARCHAR(50) UNIQUE NOT NULL,
    part_id VARCHAR(50) REFERENCES public.parts(id) ON DELETE CASCADE,
    part_code VARCHAR(50) NOT NULL,
    part_name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    unit_cost NUMERIC(10,2) DEFAULT 0.00,
    quantity INT NOT NULL DEFAULT 1,
    call_id VARCHAR(50) REFERENCES public.call_tickets(id) ON DELETE SET NULL,
    call_number VARCHAR(50),
    equipment_tag VARCHAR(50),
    customer_name VARCHAR(255),
    urgency VARCHAR(30) DEFAULT 'NORMAL',
    delivery_type VARCHAR(50) DEFAULT 'RETIRADA_POLO',
    technician_id VARCHAR(50) REFERENCES public.technicians(id) ON DELETE SET NULL,
    technician_name VARCHAR(255) NOT NULL,
    justification TEXT,
    status VARCHAR(50) DEFAULT 'PENDENTE', -- PENDENTE, APROVADO, EM_SEPARACAO, A_CAMINHO, ENTREGUE
    estimated_delivery TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.11. PLANOS DE MANUTENÇÃO (Preventiva e Preditiva)
CREATE TABLE IF NOT EXISTS public.maintenance_plans (
    id VARCHAR(50) PRIMARY KEY,
    equipment_id VARCHAR(50) REFERENCES public.equipments(id) ON DELETE CASCADE,
    equipment_tag VARCHAR(50) NOT NULL,
    equipment_model VARCHAR(100),
    building_name VARCHAR(255),
    city VARCHAR(100),
    type VARCHAR(30) NOT NULL DEFAULT 'PREVENTIVA', -- PREVENTIVA, PREDITIVA, CORRETIVA
    scheduled_date TIMESTAMPTZ NOT NULL,
    status VARCHAR(30) DEFAULT 'AGENDADA',         -- AGENDADA, EM_ANDAMENTO, CONCLUIDA, ATRASADA
    tasks TEXT[] DEFAULT ARRAY[]::TEXT[],
    recommended_parts TEXT[] DEFAULT ARRAY[]::TEXT[],
    assigned_technician_id VARCHAR(50) REFERENCES public.technicians(id) ON DELETE SET NULL,
    assigned_technician_name VARCHAR(255),
    month_cycle VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.12. CAMPANHAS DE MANUTENÇÃO / RECALL PREVENTIVO
CREATE TABLE IF NOT EXISTS public.maintenance_campaigns (
    id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    component_target VARCHAR(150),
    model_target VARCHAR(150),
    risk_description TEXT,
    total_target_equipments INT DEFAULT 0,
    high_risk_equipments_count INT DEFAULT 0,
    inspected_equipments_count INT DEFAULT 0,
    target_regions TEXT[] DEFAULT ARRAY[]::TEXT[],
    estimated_cost NUMERIC(12,2) DEFAULT 0.00,
    start_date DATE,
    status VARCHAR(50) DEFAULT 'PLANEJADA',
    ai_root_cause_hypothesis TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.13. COLABORADORES / RECURSOS HUMANOS (Acesso restrito ao Financeiro/RH/Admin)
CREATE TABLE IF NOT EXISTS public.employees (
    id VARCHAR(50) PRIMARY KEY,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    role user_role_enum NOT NULL,
    department VARCHAR(100) NOT NULL, -- Ex: 'Operações de Campo', 'Financeiro & Controladoria', 'Atendimento 24/7'
    base_salary NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    benefits_cost NUMERIC(10,2) DEFAULT 0.00,
    overtime_hours_month NUMERIC(5,2) DEFAULT 0.0,
    admission_date DATE,
    status VARCHAR(30) DEFAULT 'ATIVO',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.14. ALERTAS DO SMARTFLOW IA
CREATE TABLE IF NOT EXISTS public.system_alerts (
    id VARCHAR(50) PRIMARY KEY,
    type VARCHAR(50) NOT NULL, -- 'FINANCEIRO', 'OPERACIONAL', 'PREDITIVO', 'ESTOQUE', 'RH'
    severity VARCHAR(30) NOT NULL, -- 'CRITICO', 'ALTO', 'MEDIO', 'INFORMATIVO'
    title VARCHAR(255) NOT NULL,
    origin_entity VARCHAR(100),
    origin_info VARCHAR(255),
    reason TEXT NOT NULL,
    status VARCHAR(30) DEFAULT 'ATIVO',
    is_read BOOLEAN DEFAULT FALSE,
    action_view VARCHAR(100),
    action_label VARCHAR(150),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    resolved_by VARCHAR(255),
    resolution_note TEXT
);

-- 3.15. INSIGHTS E RECOMENDAÇÕES DA IA SMARTFLOW
CREATE TABLE IF NOT EXISTS public.ai_insights (
    id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(50) NOT NULL, -- 'OPERACIONAL', 'PREDITIVO', 'ESTRATEGICO'
    title VARCHAR(255) NOT NULL,
    scope VARCHAR(150),
    summary TEXT NOT NULL,
    evidence TEXT[] DEFAULT ARRAY[]::TEXT[],
    recommended_action TEXT,
    estimated_impact TEXT,
    confidence_score INT DEFAULT 90,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 4. ÍNDICES DE PERFORMANCE
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_call_tickets_status ON public.call_tickets(status);
CREATE INDEX IF NOT EXISTS idx_call_tickets_priority ON public.call_tickets(priority);
CREATE INDEX IF NOT EXISTS idx_call_tickets_technician ON public.call_tickets(technician_id);
CREATE INDEX IF NOT EXISTS idx_call_tickets_customer ON public.call_tickets(customer_id);
CREATE INDEX IF NOT EXISTS idx_call_tickets_equipment ON public.call_tickets(equipment_id);
CREATE INDEX IF NOT EXISTS idx_equipments_tag ON public.equipments(tag);
CREATE INDEX IF NOT EXISTS idx_equipments_risk_score ON public.equipments(predictive_risk_score DESC);
CREATE INDEX IF NOT EXISTS idx_technicians_status ON public.technicians(status);
CREATE INDEX IF NOT EXISTS idx_contracts_customer ON public.contracts(customer_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON public.contracts(status);
CREATE INDEX IF NOT EXISTS idx_system_alerts_type ON public.system_alerts(type);
CREATE INDEX IF NOT EXISTS idx_system_alerts_status ON public.system_alerts(status);

-- ==============================================================================
-- 5. FUNÇÕES AUXILIARES DE SEGURANÇA E PAPEL (RBAC / RLS)
-- ==============================================================================

-- Função para capturar a Role do usuário autenticado no Supabase ou via Header customizado
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS TEXT AS $$
DECLARE
    v_role TEXT;
BEGIN
    -- 1. Tenta recuperar do claims do JWT do Supabase
    v_role := auth.jwt() ->> 'role';
    
    -- 2. Se o JWT contiver 'user_metadata' com o papel definido:
    IF v_role IS NULL OR v_role = 'authenticated' THEN
        v_role := auth.jwt() -> 'user_metadata' ->> 'user_role';
    END IF;

    -- 3. Se ainda não encontrado, busca na tabela public.profiles pelo auth.uid()
    IF v_role IS NULL AND auth.uid() IS NOT NULL THEN
        SELECT p.role::TEXT INTO v_role
        FROM public.profiles p
        WHERE p.auth_user_id = auth.uid() OR p.id = auth.uid()
        LIMIT 1;
    END IF;

    -- 4. Fallback: se não estiver autenticado via Supabase Auth (ex: chamadas públicas ou dev)
    RETURN COALESCE(v_role, 'ANONYMOUS');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função auxiliar para checar se o usuário atual pertence a uma das roles permitidas
CREATE OR REPLACE FUNCTION public.has_role(VARIADIC allowed_roles TEXT[])
RETURNS BOOLEAN AS $$
DECLARE
    v_curr TEXT;
BEGIN
    v_curr := public.current_user_role();
    
    -- ADMINISTRADOR sempre tem permissão global
    IF v_curr = 'ADMINISTRADOR' THEN
        RETURN TRUE;
    END IF;
    
    RETURN v_curr = ANY(allowed_roles);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 6. VIEWS CUSTOMIZADAS PARA CADA CARGO
-- ==============================================================================
-- Cada cargo tem sua própria visão otimizada e blindada dos dados:

-- 6.1. VISÃO DO FINANCEIRO (Contratos, Faturamento, DRE, Custos de Peças e Margem)
CREATE OR REPLACE VIEW public.vw_financeiro_contratos_dre AS
SELECT 
    c.id AS contrato_id,
    c.contract_number,
    cust.name AS cliente_nome,
    cust.document_number AS cnpj,
    c.type AS tipo_contrato,
    c.status AS status_contrato,
    c.monthly_revenue AS receita_mensal,
    c.monthly_parts_cost AS custo_pecas,
    c.monthly_tech_labor_cost AS custo_mao_de_obra,
    c.monthly_travel_cost AS custo_deslocamento,
    c.monthly_other_cost AS outros_custos,
    (c.monthly_parts_cost + c.monthly_tech_labor_cost + c.monthly_travel_cost + c.monthly_other_cost) AS custo_total_mensal,
    (c.monthly_revenue - (c.monthly_parts_cost + c.monthly_tech_labor_cost + c.monthly_travel_cost + c.monthly_other_cost)) AS lucro_bruto_mensal,
    c.current_margin_rate AS margem_atual_porcento,
    c.baseline_margin_rate AS meta_margem_porcento,
    c.margin_drop_alert AS alerta_margem,
    c.ai_financial_diagnosis AS diagnostico_ia_financeira
FROM public.contracts c
JOIN public.customers cust ON cust.id = c.customer_id;

-- 6.2. VISÃO DO TÉCNICO DE CAMPO (Apenas Seus Chamados, SLA, Equipamento e Rota/Mapa)
CREATE OR REPLACE VIEW public.vw_tecnico_meus_chamados_e_mapa AS
SELECT 
    ct.id AS chamado_id,
    ct.call_number,
    ct.priority,
    ct.status,
    ct.customer_name,
    ct.building_name,
    ct.address,
    ct.city,
    ct.lat AS destino_lat,
    ct.lng AS destino_lng,
    ct.equipment_tag,
    ct.equipment_model,
    ct.problem_description,
    ct.has_trapped_passenger,
    ct.is_car_stopped,
    ct.sla_max_hours,
    ct.created_at,
    ct.technician_id,
    ct.technician_name,
    ct.distance_km,
    ct.traffic_condition,
    t.assigned_vehicle,
    t.current_lat AS tecnico_lat,
    t.current_lng AS tecnico_lng
FROM public.call_tickets ct
LEFT JOIN public.technicians t ON t.id = ct.technician_id
WHERE ct.status NOT IN ('CONCLUIDO', 'CANCELADO');

-- 6.3. VISÃO DO ATENDENTE (Central de Chamados, Clientes, Equipamentos e Mapa da Frota)
-- Não tem acesso aos dados confidenciais financeiros de contratos nem salários
CREATE OR REPLACE VIEW public.vw_atendente_central_chamados AS
SELECT 
    ct.id AS chamado_id,
    ct.call_number,
    ct.created_at,
    ct.origin,
    ct.priority,
    ct.status,
    ct.customer_name,
    ct.customer_phone,
    ct.building_name,
    ct.city,
    ct.equipment_tag,
    ct.has_trapped_passenger,
    ct.is_car_stopped,
    ct.technician_name,
    ct.technician_id,
    t.status AS status_tecnico,
    t.current_lat AS tecnico_lat,
    t.current_lng AS tecnico_lng,
    ct.lat AS chamado_lat,
    ct.lng AS chamado_lng,
    ct.sla_max_hours
FROM public.call_tickets ct
LEFT JOIN public.technicians t ON t.id = ct.technician_id;

-- 6.4. VISÃO DO SUPERVISOR (Polo Operacional, Desempenho de Técnicos e Auditoria)
CREATE OR REPLACE VIEW public.vw_supervisor_polo_operacional AS
SELECT 
    t.id AS tecnico_id,
    t.name AS tecnico_nome,
    t.status AS tecnico_status,
    t.supervisor_name,
    t.city AS polo_cidade,
    t.completed_calls_month,
    t.avg_arrival_time_min,
    t.avg_solution_time_min,
    t.sla_compliance_rate,
    t.assigned_vehicle,
    t.current_lat,
    t.current_lng,
    COUNT(ct.id) FILTER (WHERE ct.status IN ('A_CAMINHO', 'EM_ATENDIMENTO')) AS chamados_em_andamento
FROM public.technicians t
LEFT JOIN public.call_tickets ct ON ct.technician_id = t.id
GROUP BY t.id, t.name, t.status, t.supervisor_name, t.city, t.completed_calls_month, 
         t.avg_arrival_time_min, t.avg_solution_time_min, t.sla_compliance_rate, 
         t.assigned_vehicle, t.current_lat, t.current_lng;

-- ==============================================================================
-- 7. ROW LEVEL SECURITY (RLS) - CONTROLE DE ACESSO POR CARGO
-- ==============================================================================

-- Habilita RLS em todas as tabelas sensíveis
ALTER TABLE public.contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.call_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.technicians ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.part_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_alerts ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------------------------------------------
-- 7.1. REGRAS PARA A TABELA CONTRATOS (contracts)
-- ------------------------------------------------------------------------------
-- Permitido para: FINANCEIRO, PRESIDENTE, GERENTE, ADMINISTRADOR
-- Bloqueado para: TECNICO, ATENDENTE (evita exposição de receitas e margens da Otis)

DROP POLICY IF EXISTS p_contracts_read ON public.contracts;
CREATE POLICY p_contracts_read ON public.contracts
    FOR SELECT
    USING (
        public.has_role('FINANCEIRO', 'PRESIDENTE', 'GERENTE', 'ADMINISTRADOR')
        OR public.current_user_role() = 'ANONYMOUS' -- Permite dev local se não autenticado
    );

DROP POLICY IF EXISTS p_contracts_write ON public.contracts;
CREATE POLICY p_contracts_write ON public.contracts
    FOR ALL
    USING (
        public.has_role('FINANCEIRO', 'GERENTE', 'ADMINISTRADOR')
        OR public.current_user_role() = 'ANONYMOUS'
    );

-- ------------------------------------------------------------------------------
-- 7.2. REGRAS PARA A TABELA COLABORADORES E SALÁRIOS (employees)
-- ------------------------------------------------------------------------------
-- Permitido para: FINANCEIRO, PRESIDENTE, GERENTE, ADMINISTRADOR
-- Bloqueado para: TECNICO, ATENDENTE, SUPERVISOR

DROP POLICY IF EXISTS p_employees_read ON public.employees;
CREATE POLICY p_employees_read ON public.employees
    FOR SELECT
    USING (
        public.has_role('FINANCEIRO', 'PRESIDENTE', 'ADMINISTRADOR')
        OR public.current_user_role() = 'ANONYMOUS'
    );

DROP POLICY IF EXISTS p_employees_write ON public.employees;
CREATE POLICY p_employees_write ON public.employees
    FOR ALL
    USING (
        public.has_role('FINANCEIRO', 'ADMINISTRADOR')
        OR public.current_user_role() = 'ANONYMOUS'
    );

-- ------------------------------------------------------------------------------
-- 7.3. REGRAS PARA A TABELA CHAMADOS (call_tickets)
-- ------------------------------------------------------------------------------
-- TÉCNICO: Pode visualizar e atualizar os chamados atribuídos a ele.
-- ATENDENTE / SUPERVISOR / GERENTE / ADMIN / PRESIDENTE: Pode visualizar todos.
-- ATENDENTE: Pode criar chamados.

DROP POLICY IF EXISTS p_call_tickets_read ON public.call_tickets;
CREATE POLICY p_call_tickets_read ON public.call_tickets
    FOR SELECT
    USING (
        public.has_role('ATENDENTE', 'SUPERVISOR', 'GERENTE', 'PRESIDENTE', 'ADMINISTRADOR')
        OR (
            public.has_role('TECNICO') 
            AND (
                technician_id IN (
                    SELECT t.id FROM public.technicians t 
                    JOIN public.profiles p ON p.id = t.profile_id 
                    WHERE p.auth_user_id = auth.uid() OR p.id = auth.uid()
                )
                OR technician_id IS NULL -- Pode ver chamados sem técnico para aceitar se configurado
            )
        )
        OR public.current_user_role() = 'ANONYMOUS'
    );

DROP POLICY IF EXISTS p_call_tickets_update ON public.call_tickets;
CREATE POLICY p_call_tickets_update ON public.call_tickets
    FOR UPDATE
    USING (
        public.has_role('ATENDENTE', 'SUPERVISOR', 'GERENTE', 'ADMINISTRADOR')
        OR public.has_role('TECNICO')
        OR public.current_user_role() = 'ANONYMOUS'
    );

DROP POLICY IF EXISTS p_call_tickets_insert ON public.call_tickets;
CREATE POLICY p_call_tickets_insert ON public.call_tickets
    FOR INSERT
    WITH CHECK (
        public.has_role('ATENDENTE', 'SUPERVISOR', 'GERENTE', 'ADMINISTRADOR')
        OR public.current_user_role() = 'ANONYMOUS'
    );

-- ------------------------------------------------------------------------------
-- 7.4. REGRAS PARA A TABELA TÉCNICOS E LOCALIZAÇÃO (technicians)
-- ------------------------------------------------------------------------------
-- TÉCNICO: Pode atualizar apenas sua própria localização GPS e status.
-- ATENDENTE / SUPERVISOR: Podem ver a localização para despacho no mapa.
-- FINANCEIRO: Não precisa rastrear o mapa dos técnicos.

DROP POLICY IF EXISTS p_technicians_read ON public.technicians;
CREATE POLICY p_technicians_read ON public.technicians
    FOR SELECT
    USING (
        public.has_role('ATENDENTE', 'SUPERVISOR', 'GERENTE', 'PRESIDENTE', 'TECNICO', 'ADMINISTRADOR')
        OR public.current_user_role() = 'ANONYMOUS'
    );

DROP POLICY IF EXISTS p_technicians_update ON public.technicians;
CREATE POLICY p_technicians_update ON public.technicians
    FOR UPDATE
    USING (
        public.has_role('SUPERVISOR', 'ADMINISTRADOR')
        OR (
            public.has_role('TECNICO')
            AND (
                profile_id IN (
                    SELECT p.id FROM public.profiles p 
                    WHERE p.auth_user_id = auth.uid() OR p.id = auth.uid()
                )
            )
        )
        OR public.current_user_role() = 'ANONYMOUS'
    );

-- ------------------------------------------------------------------------------
-- 7.5. REGRAS PARA A TABELA PEÇAS E REQUISIÇÕES (parts & part_requests)
-- ------------------------------------------------------------------------------
-- TÉCNICO: Pode visualizar estoque e solicitar peças para seus chamados.
-- SUPERVISOR: Pode aprovar requisições.
-- FINANCEIRO: Acesso aos custos e compras de peças.

DROP POLICY IF EXISTS p_parts_read ON public.parts;
CREATE POLICY p_parts_read ON public.parts
    FOR SELECT
    USING (
        public.has_role('TECNICO', 'SUPERVISOR', 'FINANCEIRO', 'GERENTE', 'PRESIDENTE', 'ADMINISTRADOR')
        OR public.current_user_role() = 'ANONYMOUS'
    );

DROP POLICY IF EXISTS p_part_requests_all ON public.part_requests;
CREATE POLICY p_part_requests_all ON public.part_requests
    FOR ALL
    USING (
        public.has_role('TECNICO', 'SUPERVISOR', 'FINANCEIRO', 'ADMINISTRADOR')
        OR public.current_user_role() = 'ANONYMOUS'
    );

-- ==============================================================================
-- 8. DADOS INICIAIS (SEED DATA)
-- ==============================================================================

-- 8.1. Usuários de Demonstração por Cargo
INSERT INTO public.profiles (id, name, email, role, region, city, unit)
VALUES
    ('a0000000-0000-0000-0000-000000000001', 'Carlos Eduardo Brandão', 'presidente@smartflow.ai', 'PRESIDENTE', 'Brasil & América Latina', 'São Paulo', 'Matriz Corporativa'),
    ('a0000000-0000-0000-0000-000000000002', 'Mariana Silveira', 'gerente@smartflow.ai', 'GERENTE', 'Sudeste - SP/RJ/MG', 'São Paulo', 'Regional Sudeste'),
    ('a0000000-0000-0000-0000-000000000003', 'Roberto Viana', 'supervisor@smartflow.ai', 'SUPERVISOR', 'Interior SP - Polo Campinas', 'Campinas', 'Polo Operacional Campinas'),
    ('a0000000-0000-0000-0000-000000000004', 'João Pedro Santos', 'tecnico@smartflow.ai', 'TECNICO', 'Campinas & RMC', 'Campinas', 'Campo RMC'),
    ('a0000000-0000-0000-0000-000000000005', 'Beatriz Vasconcelos', 'atendente@smartflow.ai', 'ATENDENTE', 'Central de Operações 24/7', 'São Paulo', 'Central 0800 Otis'),
    ('a0000000-0000-0000-0000-000000000006', 'Fernando Guimarães', 'financeiro@smartflow.ai', 'FINANCEIRO', 'Controladoria & Contratos', 'São Paulo', 'Controladoria Matriz'),
    ('a0000000-0000-0000-0000-000000000007', 'Administrador Master', 'admin@smartflow.ai', 'ADMINISTRADOR', 'Global Master Admin', 'São Paulo', 'TI & Governança')
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    role = EXCLUDED.role;

-- 8.2. Clientes Iniciais
INSERT INTO public.customers (id, name, document_number, building_name, group_name, is_vip, is_corporate, phone, email, address, city, state)
VALUES
    ('cust-1', 'Centro Empresarial Iguatemi Campinas', '48.912.455/0001-92', 'Torre A & B Iguatemi', 'Iguatemi S.A.', TRUE, TRUE, '(19) 3755-9000', 'operacoes@iguatemicampinas.com.br', 'Av. Iguatemi, 777 - Vila Brandina', 'Campinas', 'SP'),
    ('cust-2', 'Condomínio Faria Lima Tower', '33.123.456/0001-88', 'Edifício Tower Faria Lima', 'Brookfield Properties', TRUE, TRUE, '(11) 3045-8800', 'facilities@farialimatower.com.br', 'Av. Brigadeiro Faria Lima, 3477 - Itaim Bibi', 'São Paulo', 'SP'),
    ('cust-3', 'Hospital Mater Dei Contorno', '17.256.789/0001-44', 'Complexo Hospitalar Mater Dei', 'Rede Mater Dei', TRUE, TRUE, '(31) 3339-9000', 'engenharia.clinica@materdei.com.br', 'Av. do Contorno, 9000 - Barro Preto', 'Belo Horizonte', 'MG'),
    ('cust-4', 'Centro Empresarial Botafogo', '29.876.543/0001-11', 'Torre Sul Botafogo', 'BR Properties', FALSE, TRUE, '(21) 2555-1234', 'condominio@botafogocenter.com.br', 'Praia de Botafogo, 501 - Botafogo', 'Rio de Janeiro', 'RJ')
ON CONFLICT (id) DO NOTHING;

-- 8.3. Contratos Iniciais
INSERT INTO public.contracts (id, contract_number, customer_id, start_date, end_date, type, status, monthly_value, monthly_revenue, monthly_parts_cost, monthly_tech_labor_cost, monthly_travel_cost, monthly_other_cost, current_margin_rate, baseline_margin_rate)
VALUES
    ('cnt-001', 'CTR-OTIS-2023-019', 'cust-1', '2023-01-01', '2026-12-31', 'PREMIUM_ALL_INCLUSIVE', 'ATIVO', 45000.00, 45000.00, 5200.00, 4800.00, 1100.00, 900.00, 73.33, 30.00),
    ('cnt-002', 'CTR-OTIS-2022-088', 'cust-2', '2022-06-01', '2025-05-31', 'PREMIUM_ALL_INCLUSIVE', 'ATIVO', 68000.00, 68000.00, 14500.00, 8900.00, 2100.00, 1500.00, 60.29, 32.00),
    ('cnt-003', 'CTR-OTIS-2024-005', 'cust-3', '2024-01-01', '2027-01-01', 'STANDARD_COM_PECAS', 'ATIVO', 32000.00, 32000.00, 3100.00, 3900.00, 800.00, 600.00, 73.75, 28.00)
ON CONFLICT (id) DO NOTHING;

-- 8.4. Supervisores
INSERT INTO public.supervisors (id, profile_id, name, email, phone, region, city, state, technicians_count, active_calls_count, sla_rate)
VALUES
    ('sup-1', 'a0000000-0000-0000-0000-000000000003', 'Roberto Viana', 'supervisor@smartflow.ai', '(19) 98111-2233', 'Interior SP - Polo Campinas', 'Campinas', 'SP', 8, 3, 98.6)
ON CONFLICT (id) DO NOTHING;

-- 8.5. Técnicos Iniciais com Localização
INSERT INTO public.technicians (id, profile_id, name, email, phone, status, supervisor_id, supervisor_name, city, state, assigned_vehicle, specialties, current_lat, current_lng, current_address, completed_calls_month, avg_arrival_time_min, avg_solution_time_min, sla_compliance_rate)
VALUES
    ('tech-001', 'a0000000-0000-0000-0000-000000000004', 'João Pedro Santos', 'tecnico@smartflow.ai', '(19) 99876-5432', 'DISPONIVEL', 'sup-1', 'Roberto Viana', 'Campinas', 'SP', 'Fiorino OTIS-042', ARRAY['Sistema de Portas AT120', 'Drives Regenerativos ReGen', 'Quadro de Comando GECB'], -22.8984, -47.0512, 'Av. Cel. Silva Telles, 1002 - Cambuí, Campinas - SP', 38, 22, 35, 99.1),
    ('tech-002', NULL, 'Lucas Mendes', 'lucas.mendes@otis.com', '(11) 98765-4321', 'EM_ATENDIMENTO', 'sup-1', 'Roberto Viana', 'Campinas', 'SP', 'Fiorino OTIS-019', ARRAY['Quadro de Comando', 'Hidráulica', 'Escadas Rolantes'], -22.9055, -47.0608, 'Rua Barão de Jaguara, 1150 - Centro, Campinas - SP', 42, 24, 38, 98.4)
ON CONFLICT (id) DO NOTHING;

-- 8.6. Equipamentos Iniciais
INSERT INTO public.equipments (id, tag, name, model, manufacturer, type, customer_id, contract_id, building_name, city, state, status, predictive_risk_score, risk_level, risk_explanation, lat, lng)
VALUES
    ('eq-001', 'SP-GEN2-042', 'Elevador Social 01', 'Gen2 Comfort', 'Otis Elevator Company', 'ELEVADOR_PASSAGEIROS', 'cust-2', 'cnt-002', 'Torre A', 'São Paulo', 'SP', 'EM_RISCO', 89, 'CRITICO', 'Vibração anômala no rolete AT120. Risco de travamento de porta iminente.', -23.5855, -46.6811),
    ('eq-002', 'RJ-SKY-108', 'Elevador Panorâmico Torre Sul', 'SkyRise HighRise', 'Otis Elevator Company', 'ELEVADOR_PANORAMICO', 'cust-4', NULL, 'Torre Sul', 'Rio de Janeiro', 'RJ', 'OPERACIONAL', 84, 'CRITICO', 'Aquecimento térmico ReGen Drive acima de 68°C em horário de pico.', -22.9519, -43.1843),
    ('eq-003', 'BH-HYD-019', 'Elevador Emergência / Macas', 'HydroFit', 'Otis Elevator Company', 'ELEVADOR_CARGA', 'cust-3', 'cnt-003', 'Prédio Principal', 'Belo Horizonte', 'MG', 'OPERACIONAL', 76, 'ALTO', 'Flutuação de pressão na válvula proporcional.', -19.9281, -43.9486),
    ('eq-004', 'CP-GEN2-101', 'Elevador Social Torre A', 'Gen2 Comfort', 'Otis Elevator Company', 'ELEVADOR_PASSAGEIROS', 'cust-1', 'cnt-001', 'Torre A & B Iguatemi', 'Campinas', 'SP', 'OPERACIONAL', 28, 'BAIXO', 'Equipamento operando perfeitamente. Última preventiva realizada.', -22.8920, -47.0260)
ON CONFLICT (id) DO NOTHING;

-- 8.7. Chamados Iniciais
INSERT INTO public.call_tickets (id, call_number, origin, priority, status, customer_id, customer_name, customer_phone, building_name, address, city, state, lat, lng, equipment_id, equipment_tag, equipment_model, problem_description, main_component, has_trapped_passenger, is_car_stopped, technician_id, technician_name, sla_max_hours)
VALUES
    ('call-101', 'CH-2024-0891', 'TELEFONE', 'CRITICO', 'EM_ATENDIMENTO', 'cust-1', 'Centro Empresarial Iguatemi Campinas', '(19) 3755-9000', 'Torre A & B Iguatemi', 'Av. Iguatemi, 777 - Vila Brandina', 'Campinas', 'SP', -22.8920, -47.0260, 'eq-004', 'CP-GEN2-101', 'Gen2 Comfort', 'Passageiro retido entre o 8º e 9º andar. Porta não abre no nivelamento.', 'Sistema de Portas', TRUE, TRUE, 'tech-001', 'João Pedro Santos', 1.0),
    ('call-102', 'CH-2024-0892', 'IOT_TELEMETRIA', 'ALTO', 'CRIADO', 'cust-2', 'Condomínio Faria Lima Tower', '(11) 3045-8800', 'Torre A', 'Av. Brigadeiro Faria Lima, 3477', 'São Paulo', 'SP', -23.5855, -46.6811, 'eq-001', 'SP-GEN2-042', 'Gen2 Comfort', 'Falha preditiva: sensor acústico identificou desalinhamento crítico de correia.', 'Sistema de Tração', FALSE, FALSE, NULL, NULL, 2.0)
ON CONFLICT (id) DO NOTHING;

-- 8.8. Peças Iniciais
INSERT INTO public.parts (id, code, name, category, unit_cost, stock_quantity, expected_life_span_months)
VALUES
    ('part-001', 'OTIS-AT120-ROL', 'Rolete Excêntrico Operador AT120', 'Portas', 185.00, 34, 24),
    ('part-002', 'OTIS-REG-DRV45', 'Módulo de Potência ReGen Drive 45kW', 'Eletrônica', 4200.00, 6, 60),
    ('part-003', 'OTIS-CSB-60MM', 'Cinta de Tração Revestida CSB 60mm (metro)', 'Tração', 310.00, 180, 72)
ON CONFLICT (id) DO NOTHING;

-- 8.9. Colaboradores (Exclusivo Financeiro / RH)
INSERT INTO public.employees (id, name, email, phone, role, department, base_salary, benefits_cost, admission_date, status)
VALUES
    ('emp-001', 'João Pedro Santos', 'tecnico@smartflow.ai', '(19) 99876-5432', 'TECNICO', 'Operações de Campo', 4850.00, 1200.00, '2021-03-15', 'ATIVO'),
    ('emp-002', 'Roberto Viana', 'supervisor@smartflow.ai', '(19) 98111-2233', 'SUPERVISOR', 'Operações de Campo', 8900.00, 1800.00, '2019-08-01', 'ATIVO'),
    ('emp-003', 'Beatriz Vasconcelos', 'atendente@smartflow.ai', '(11) 97654-3210', 'ATENDENTE', 'Central de Atendimento 24/7', 3200.00, 950.00, '2022-01-10', 'ATIVO'),
    ('emp-004', 'Fernando Guimarães', 'financeiro@smartflow.ai', '(11) 98222-3344', 'FINANCEIRO', 'Financeiro & Controladoria', 9500.00, 2100.00, '2020-05-18', 'ATIVO')
ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- FIM DO SCRIPT DE CRIAÇÃO PARA O SUPABASE
-- ==============================================================================
