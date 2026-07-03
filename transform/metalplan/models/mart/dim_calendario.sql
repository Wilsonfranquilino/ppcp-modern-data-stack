-- models/mart/dim_calendario.sql
-- Dimensão de calendário — Kimball style
-- Gera uma linha para cada dia do período de análise

with datas as (
    select generate_series(
        '2025-01-01'::date,
        '2027-12-31'::date,
        '1 day'::interval
    )::date as data
),

calendario as (
    select
        -- Chave primária
        to_char(data, 'YYYYMMDD')::integer     as sk_data,
        data                                    as data,

        -- Dia
        extract(day from data)::integer         as num_dia,
        to_char(data, 'Day')                    as nome_dia_semana,
        extract(dow from data)::integer         as num_dia_semana,
        case
            when extract(dow from data) in (0, 6) then true
            else false
        end                                     as flag_fim_semana,

        -- Semana
        extract(week from data)::integer        as num_semana,

        -- Mês
        extract(month from data)::integer       as num_mes,
        to_char(data, 'Month')                  as nome_mes,
        to_char(data, 'YYYY-MM')                as ano_mes,
        date_trunc('month', data)::date         as primeiro_dia_mes,

        -- Trimestre
        extract(quarter from data)::integer     as num_trimestre,
        'Q' || extract(quarter from data)       as nome_trimestre,

        -- Ano
        extract(year from data)::integer        as num_ano,

        -- Flags úteis para PPCP
        case
            when data = date_trunc('month', data) then true
            else false
        end                                     as flag_primeiro_dia_mes,
        case
            when data = (date_trunc('month', data) 
                + interval '1 month' - interval '1 day')::date then true
            else false
        end                                     as flag_ultimo_dia_mes

    from datas
)

select * from calendario