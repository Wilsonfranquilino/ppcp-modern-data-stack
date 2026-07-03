-- models/mart/dim_turno.sql
-- Dimensão de turno — Kimball style

with turnos as (
    select distinct turno
    from {{ ref('stg_apontamentos') }}
),

dim as (
    select
        -- Chave surrogate
        row_number() over (order by turno) as sk_turno,

        -- Chave natural
        turno,

        -- Atributos
        case
            when turno = 'A' then '1º Turno'
            when turno = 'B' then '2º Turno'
            when turno = 'C' then '3º Turno'
            else 'Não classificado'
        end as descricao_turno,

        case
            when turno = 'A' then '06:00'
            when turno = 'B' then '14:00'
            when turno = 'C' then '22:00'
        end as hora_inicio,

        case
            when turno = 'A' then '14:00'
            when turno = 'B' then '22:00'
            when turno = 'C' then '06:00'
        end as hora_fim,

        case
            when turno = 'A' then 'Diurno'
            when turno = 'B' then 'Vespertino'
            when turno = 'C' then 'Noturno'
        end as periodo,

        -- Capacidade nominal em minutos
        480 as capacidade_nominal_min,

        current_timestamp as _loaded_at
    from turnos
)

select * from dim