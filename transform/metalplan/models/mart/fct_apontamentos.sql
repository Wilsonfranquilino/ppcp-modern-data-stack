-- models/mart/fct_apontamentos.sql
-- Tabela Fato de Apontamentos — OEE por linha/turno/dia
-- Grão: um registro por apontamento (linha + turno + data)

with apontamentos as (
    select * from {{ ref('stg_apontamentos') }}
),

dim_calendario as (
    select sk_data, data from {{ ref('dim_calendario') }}
),

dim_linha as (
    select sk_linha, linha from {{ ref('dim_linha') }}
),

dim_turno as (
    select sk_turno, turno from {{ ref('dim_turno') }}
),

fct as (
    select
        -- Chaves surrogate (FK para dimensões)
        cal.sk_data,
        lin.sk_linha,
        tur.sk_turno,

        -- Chaves naturais (para debug e rastreabilidade)
        ap.apontamento_id,
        ap.linha,
        ap.turno,
        ap.data,

        -- Métricas de tempo
        ap.tempo_disponivel_min,
        ap.tempo_parada_min,
        ap.tempo_producao_min,

        -- Métricas de produção
        ap.pecas_produzidas,
        ap.pecas_boas,
        ap.pecas_refugo,

        -- Indicadores OEE
        ap.disponibilidade,
        ap.performance,
        ap.qualidade,
        ap.oee,
        ap.classe_oee,

        -- Flags de meta
        case when ap.oee >= 0.75 then true else false end as atingiu_meta_oee,

        -- Metadata
        ap._loaded_at

    from apontamentos ap
    left join dim_calendario cal on cal.data = ap.data
    left join dim_linha      lin on lin.linha = ap.linha
    left join dim_turno      tur on tur.turno = ap.turno
)

select * from fct