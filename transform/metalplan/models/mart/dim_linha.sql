-- models/mart/dim_linha.sql
-- Dimensão de linha de produção — Kimball style

with linhas as (
    select distinct linha
    from {{ ref('stg_apontamentos') }}
),

dim as (
    select
        -- Chave surrogate
        row_number() over (order by linha) as sk_linha,

        -- Chave natural
        linha,

        -- Atributos
        case
            when linha in ('L01', 'L02') then 'Planta 1'
            when linha in ('L03', 'L04') then 'Planta 2'
            when linha in ('L05', 'L06') then 'Planta 3'
            else 'Não classificado'
        end as planta,

        case
            when linha in ('L01', 'L02') then 'Área A'
            when linha in ('L03', 'L04') then 'Área B'
            when linha in ('L05', 'L06') then 'Área C'
            else 'Não classificado'
        end as area,

        case
            when linha in ('L01', 'L03', 'L05') then 'Usinagem'
            when linha in ('L02', 'L04', 'L06') then 'Montagem'
            else 'Não classificado'
        end as tipo_processo,

        -- Capacidade nominal por turno (minutos)
        480 as capacidade_nominal_min,

        current_timestamp as _loaded_at
    from linhas
)

select * from dim