"""
Gerador de Dados Sintéticos — Indústria MetalPlan
Sprint 2 | PPCP Modern Data Stack
Gera: Ordens de Produção, Apontamentos, Estoque, Paradas
"""

import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime, timedelta
import random
import os

fake = Faker('pt_BR')
random.seed(42)
np.random.seed(42)

# ─────────────────────────────────────────
# CONFIGURAÇÕES DA FÁBRICA
# ─────────────────────────────────────────
LINHAS = ['L01', 'L02', 'L03', 'L04', 'L05', 'L06']
TURNOS = ['A', 'B', 'C']
FAMILIAS = ['Estruturas', 'Fixadores', 'Perfis', 'Chapas', 'Tubos', 'Especiais']
STATUS_OP = ['Concluída', 'Concluída', 'Concluída', 'Atrasada', 'Em andamento']

PRODUTOS = [
    {'codigo': f'MP-{str(i).zfill(4)}', 'familia': random.choice(FAMILIAS),
     'tempo_ciclo': random.randint(10, 120)}
    for i in range(1, 101)
]

OUTPUT = 'data/samples'
os.makedirs(OUTPUT, exist_ok=True)


# ─────────────────────────────────────────
# 1. ORDENS DE PRODUÇÃO
# ─────────────────────────────────────────
def gerar_ordens(n=500):
    ordens = []
    for i in range(n):
        produto = random.choice(PRODUTOS)
        data_abertura = fake.date_time_between(
            start_date='-6M', end_date='now'
        )
        lead_time_previsto = random.randint(2, 8)
        variacao = random.gauss(0, 1.5)
        lead_time_real = max(1, lead_time_previsto + variacao)

        data_prevista = data_abertura + timedelta(days=lead_time_previsto)
        data_encerramento = data_abertura + timedelta(days=lead_time_real)
        status = random.choice(STATUS_OP)

        ordens.append({
            'op_id': f'OP-{str(i+1).zfill(5)}',
            'produto_codigo': produto['codigo'],
            'familia': produto['familia'],
            'linha': random.choice(LINHAS),
            'quantidade_planejada': random.randint(50, 2000),
            'quantidade_produzida': int(random.randint(45, 2000)),
            'data_abertura': data_abertura,
            'data_prevista': data_prevista,
            'data_encerramento': data_encerramento,
            'lead_time_previsto_dias': lead_time_previsto,
            'lead_time_real_dias': round(lead_time_real, 1),
            'status': status,
            'turno': random.choice(TURNOS),
        })

    df = pd.DataFrame(ordens)
    df.to_csv(f'{OUTPUT}/ordens_producao.csv', index=False)
    print(f'✅ Ordens de produção: {len(df)} registros')
    return df


# ─────────────────────────────────────────
# 2. APONTAMENTOS (base do OEE)
# ─────────────────────────────────────────
def gerar_apontamentos(n=1000):
    apontamentos = []
    for i in range(n):
        tempo_disponivel = 480  # minutos por turno
        tempo_parada = random.randint(0, 120)
        tempo_producao = tempo_disponivel - tempo_parada
        velocidade_nominal = random.randint(80, 120)
        velocidade_real = velocidade_nominal * random.uniform(0.7, 1.0)
        pecas_produzidas = int((tempo_producao / 60) * velocidade_real)
        pecas_boas = int(pecas_produzidas * random.uniform(0.92, 0.99))
        pecas_refugo = pecas_produzidas - pecas_boas

        disponibilidade = round((tempo_producao / tempo_disponivel), 4)
        performance = round((velocidade_real / velocidade_nominal), 4)
        qualidade = round((pecas_boas / pecas_produzidas) if pecas_produzidas > 0 else 0, 4)
        oee = round(disponibilidade * performance * qualidade, 4)

        apontamentos.append({
            'apontamento_id': f'AP-{str(i+1).zfill(6)}',
            'linha': random.choice(LINHAS),
            'turno': random.choice(TURNOS),
            'data': fake.date_between(start_date='-6M', end_date='today'),
            'tempo_disponivel_min': tempo_disponivel,
            'tempo_parada_min': tempo_parada,
            'tempo_producao_min': tempo_producao,
            'pecas_produzidas': pecas_produzidas,
            'pecas_boas': pecas_boas,
            'pecas_refugo': pecas_refugo,
            'disponibilidade': disponibilidade,
            'performance': performance,
            'qualidade': qualidade,
            'oee': oee,
        })

    df = pd.DataFrame(apontamentos)
    df.to_csv(f'{OUTPUT}/apontamentos.csv', index=False)
    print(f'✅ Apontamentos: {len(df)} registros')
    return df


# ─────────────────────────────────────────
# 3. ESTOQUE
# ─────────────────────────────────────────
def gerar_estoque():
    estoque = []
    for p in PRODUTOS:
        saldo = random.randint(0, 5000)
        ponto_reposicao = random.randint(200, 800)
        estoque.append({
            'produto_codigo': p['codigo'],
            'familia': p['familia'],
            'saldo_atual': saldo,
            'ponto_reposicao': ponto_reposicao,
            'status_estoque': 'Crítico' if saldo < ponto_reposicao else 'Normal',
            'data_atualizacao': datetime.now().date(),
        })

    df = pd.DataFrame(estoque)
    df.to_csv(f'{OUTPUT}/estoque.csv', index=False)
    print(f'✅ Estoque: {len(df)} registros')
    return df


# ─────────────────────────────────────────
# EXECUÇÃO
# ─────────────────────────────────────────
if __name__ == '__main__':
    print('\n🏭 Gerando dados sintéticos — Indústria MetalPlan\n')
    gerar_ordens()
    gerar_apontamentos()
    gerar_estoque()
    print('\n✅ Todos os arquivos gerados em data/samples/')