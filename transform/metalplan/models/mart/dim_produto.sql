-- models/mart/dim_produto.sql
-- Dimensão de produto — Kimball style

with produtos as (
    select distinct
        produto_codigo,
        familia
    from {{ ref('stg_ordens_producao') }}
),

dim as (
    select
        -- Chave surrogate
        row_number() over (order by produto_codigo) as sk_produto,

        -- Chave natural
        produto_codigo,

        -- Atributos
        familia,
        case
            when familia = 'Estruturas'  then 'Linha Pesada'
            when familia = 'Fixadores'   then 'Linha Leve'
            when familia = 'Perfis'      then 'Linha Leve'
            when familia = 'Chapas'      then 'Linha Pesada'
            when familia = 'Tubos'       then 'Linha Média'
            when familia = 'Especiais'   then 'Linha Especial'
            else 'Não classificado'
        end as segmento,

        current_timestamp as _loaded_at
    from produtos
)

select * from dim