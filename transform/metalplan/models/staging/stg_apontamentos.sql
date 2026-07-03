-- models/staging/stg_apontamentos.sql
-- Camada de staging: limpa e tipifica os apontamentos de produção (base do OEE)

with source as (
    select * from raw_ppcp.apontamentos
),

staged as (
    select
        apontamento_id,
        linha,
        turno,
        data::date as data,
        tempo_disponivel_min,
        tempo_parada_min,
        tempo_producao_min,
        pecas_produzidas,
        pecas_boas,
        pecas_refugo,
        -- Indicadores OEE
        disponibilidade,
        performance,
        qualidade,
        oee,
        -- Classificação do OEE
        case
            when oee >= 0.75 then 'Bom'
            when oee >= 0.60 then 'Regular'
            else 'Crítico'
        end as classe_oee,
        current_timestamp as _loaded_at
    from source
)

select * from staged