-- models/staging/stg_estoque.sql
-- Camada de staging: limpa e tipifica os dados de estoque

with source as (
    select * from raw_ppcp.estoque
),

staged as (
    select
        produto_codigo,
        familia,
        saldo_atual,
        ponto_reposicao,
        status_estoque,
        -- Indicador de cobertura
        case
            when ponto_reposicao = 0 then null
            else round(saldo_atual::numeric / ponto_reposicao, 2)
        end as cobertura_relativa,
        -- Urgência de reposição
        case
            when saldo_atual = 0 then 'Ruptura'
            when saldo_atual < ponto_reposicao * 0.5 then 'Urgente'
            when saldo_atual < ponto_reposicao then 'Crítico'
            else 'Normal'
        end as urgencia_reposicao,
        data_atualizacao::date as data_atualizacao,
        current_timestamp as _loaded_at
    from source
)

select * from staged