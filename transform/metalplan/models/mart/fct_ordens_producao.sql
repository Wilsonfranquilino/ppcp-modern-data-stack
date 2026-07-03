-- models/mart/fct_ordens_producao.sql
-- Tabela Fato de Ordens de Produção — OTIF, Fill Rate, Lead Time
-- Grão: um registro por Ordem de Produção (OP)

with ordens as (
    select * from {{ ref('stg_ordens_producao') }}
),

dim_calendario_abertura as (
    select sk_data, data from {{ ref('dim_calendario') }}
),

dim_calendario_encerramento as (
    select sk_data, data from {{ ref('dim_calendario') }}
),

dim_produto as (
    select sk_produto, produto_codigo from {{ ref('dim_produto') }}
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
        cal_ab.sk_data                          as sk_data_abertura,
        cal_enc.sk_data                         as sk_data_encerramento,
        pro.sk_produto,
        lin.sk_linha,
        tur.sk_turno,

        -- Chave natural
        op.op_id,

        -- Atributos descritivos
        op.status,
        op.familia,

        -- Métricas de quantidade
        op.quantidade_planejada,
        op.quantidade_produzida,
        op.taxa_execucao,

        -- Métricas de tempo
        op.lead_time_previsto_dias,
        op.lead_time_real_dias,
        op.lead_time_real_dias - 
            op.lead_time_previsto_dias          as desvio_lead_time_dias,

        -- Indicadores OTIF
        op.entregue_no_prazo,
        op.entregue_quantidade_correta,
        case
            when op.entregue_no_prazo 
             and op.entregue_quantidade_correta 
            then true else false
        end                                     as otif,

        -- Fill Rate
        case
            when op.quantidade_planejada > 0
            then round(
                op.quantidade_produzida::numeric 
                / op.quantidade_planejada * 100, 2)
            else null
        end                                     as fill_rate_pct,

        -- Classificação de desempenho da OP
        case
            when op.entregue_no_prazo 
             and op.quantidade_produzida >= op.quantidade_planejada
            then 'Excelente'
            when op.entregue_no_prazo 
              or op.quantidade_produzida >= op.quantidade_planejada
            then 'Parcial'
            else 'Crítico'
        end                                     as classe_desempenho,

        -- Datas
        op.data_abertura,
        op.data_prevista,
        op.data_encerramento,

        -- Metadata
        op._loaded_at

    from ordens op
    left join dim_calendario_abertura    cal_ab  
        on cal_ab.data  = op.data_abertura::date
    left join dim_calendario_encerramento cal_enc 
        on cal_enc.data = op.data_encerramento::date
    left join dim_produto pro 
        on pro.produto_codigo = op.produto_codigo
    left join dim_linha   lin 
        on lin.linha  = op.linha
    left join dim_turno   tur 
        on tur.turno  = op.turno
)

select * from fct