# Contexto de Negócio — Indústria MetalPlan

## Sobre a empresa

A **Indústria MetalPlan** é uma fabricante brasileira de componentes
metálicos de médio-grande porte, localizada no interior de Minas Gerais.
Fundada em 1998, atua nos segmentos de autopeças, agronegócio e construção
civil, com mais de 800 colaboradores e três plantas produtivas.

## Estrutura produtiva

| Item | Detalhe |
|---|---|
| Plantas | 3 unidades (Matriz + 2 filiais) |
| Linhas de produção | 12 linhas ativas |
| Turnos | 3 turnos / dia |
| Famílias de produto | 6 famílias |
| SKUs ativos | ~1.400 SKUs |
| Volume mensal | ~180.000 peças/mês |

## Desafios atuais de PPCP

- OEE abaixo da meta: ~62%, meta de 75%
- OTIF calculado de forma diferente por cada área
- Forecast de demanda manual em Excel (horizonte 30 dias)
- Decisões reativas — problemas identificados tarde demais
- Analistas gastam ~40% do tempo consolidando planilhas

## KPIs prioritários

| KPI | Definição | Meta |
|---|---|---|
| OEE | Disponibilidade × Performance × Qualidade | ≥ 75% |
| OTIF | % pedidos entregues no prazo e quantidade | ≥ 92% |
| Fill Rate | % itens atendidos no primeiro envio | ≥ 95% |
| Lead Time | Tempo médio de abertura ao fim da OP | ≤ 5 dias |

## Fontes de dados mapeadas

| Fonte | Sistema | Formato |
|---|---|---|
| Ordens de Produção | ERP TOTVS | CSV |
| Apontamentos | MES legado | CSV |
| Estoque | ERP TOTVS | CSV |
| Paradas de máquina | Planilha Excel | XLSX |

## Arquitetura escolhida

Modern Data Stack 100% open source via Docker Compose:

*Empresa fictícia criada para fins de portfólio*