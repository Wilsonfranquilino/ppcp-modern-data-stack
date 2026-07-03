-- models/staging/stg_ordens_producao.sql
-- Camada de staging: limpa e tipifica as ordens de produção brutas

with source as (
    select * from raw_ppcp.ordens_producao
),

staged as (
    select
        op_id,
        produto_codigo,
        familia,
        linha,
        turno,
        quantidade_planejada,
        quantidade_produzida,
        quantidade_produzida::numeric / 
            nullif(quantidade_planejada, 0) as taxa_execucao,
        data_abertura::timestamp as data_abertura,
        data_prevista::timestamp as data_prevista,
        data_encerramento::timestamp as data_encerramento,
        lead_time_previsto_dias,
        lead_time_real_dias,
        case
            when data_encerramento <= data_prevista then true
            else false
        end as entregue_no_prazo,
        case
            when quantidade_produzida >= quantidade_planejada then true
            else false
        end as entregue_quantidade_correta,
        status,
        current_timestamp as _loaded_at
    from source
)

select * from staged