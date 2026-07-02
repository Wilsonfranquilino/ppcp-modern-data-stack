"""
Carga de Dados — Indústria MetalPlan
Carrega os CSVs gerados direto no PostgreSQL (schema raw_ppcp)
"""

import pandas as pd
from sqlalchemy import create_engine, text
import os

# ─────────────────────────────────────────
# CONEXÃO COM O POSTGRES
# ─────────────────────────────────────────
DB_URL = "postgresql://metalplan:metalplan123@172.19.0.2:5432/metalplan_dw"
engine = create_engine(DB_URL)

SAMPLES = "data/samples"

# ─────────────────────────────────────────
# CRIA O SCHEMA raw_ppcp
# ─────────────────────────────────────────
def criar_schema():
    with engine.connect() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw_ppcp"))
        conn.commit()
    print("✅ Schema raw_ppcp criado!")

# ─────────────────────────────────────────
# CARREGA OS CSVs
# ─────────────────────────────────────────
def carregar_tabela(arquivo, tabela):
    caminho = f"{SAMPLES}/{arquivo}"
    df = pd.read_csv(caminho)
    df.to_sql(
        tabela,
        engine,
        schema="raw_ppcp",
        if_exists="replace",
        index=False
    )
    print(f"✅ {tabela}: {len(df)} registros carregados!")

# ─────────────────────────────────────────
# EXECUÇÃO
# ─────────────────────────────────────────
if __name__ == "__main__":
    print("\n🏭 Iniciando carga no PostgreSQL — MetalPlan\n")
    criar_schema()
    carregar_tabela("ordens_producao.csv",  "ordens_producao")
    carregar_tabela("apontamentos.csv",     "apontamentos")
    carregar_tabela("estoque.csv",          "estoque")
    print("\n✅ Carga concluída! Dados disponíveis em raw_ppcp\n")