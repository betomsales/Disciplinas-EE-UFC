# Importação de todas as bibliotecas

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.ticker import AutoMinorLocator, MaxNLocator

!wget "https://drive.google.com/uc?export=download&id=1CKFr8apAJRXqqF6Cjjv5a0GSqB_p5GGU" -O dataset.csv

data = pd.read_csv('dataset.csv', index_col=0)
data

#FILTRAR CURVAS COMPORTADAS

#Calculo de media geral
media_geral = data.mean()

#Calculo de curva de referencia
curva_ref = data.mean(axis=1)

#Calculo de correlação
correlação = data.corrwith(curva_ref)

#Calculo dos quartis 1, 3 e similaridade
q1= media_geral.quantile(0.25)
q3= media_geral.quantile(0.75)

#Filtra as curvas entre 2°e 3° quartis e que tem alta correlação com a curva de referência
curvas_comportadas = media_geral[
    (media_geral>=q1)&
    (media_geral<=q3)&
    (correlação> 0.85)
].dropna()

#Seleciona 20 curvas aelatórias no grupo filtrado
curvas_aleatorias = curvas_comportadas.sample(n=20, random_state=10)

#Separa 10 cruva para treinamento e 10 para teste
grupo_treino = curvas_aleatorias.index[None:10].tolist()
grupo_teste = curvas_aleatorias.index[10:None].tolist()

#Transforma as listas em dataframes

df_treino = data[grupo_treino]
df_teste = data[grupo_teste]

#Ploatagem dascurvas filtradas
df_treino.plot(figsize=(10,5), title = "Grupo de Treinamento", alpha=0.5)
df_teste.plot(figsize=(10,5), title= "Grupo de Teste",alpha=0.5)
plt.show()

# O fator (15/60) transforma o passo de tempo de 15 minutos em fração de hora (0.25h).
# O método .sum() realiza a somatório da curva para todo o mês.

EnergiaMensal_teste = (df_teste*(15/60)).sum()

# Valor fictício, trocar quando tiver de onde pegar esse dado, obtido a patir dos
# dados de energia consumida e demanda máxima do grupo de treinamento, obtidos pelo NETO

# O termo "DemandaEnergia_regrecao[0]" corresponde a alfa e "DemandaEnergia_regrecao[1]" corresponde a beta
DemandaEnergia_regrecao = [0.00310561, 1.46611559]

# A equação linear "demanda máxima = alfa * Energia + beta" é aplicada para cada consumidor.
DemandaMax_teste = ((DemandaEnergia_regrecao[0] * EnergiaMensal_teste) + DemandaEnergia_regrecao[1])

# Dados
x_valores = EnergiaMensal_teste
y_valores = DemandaMax_teste

plt.figure(figsize=(10, 5))

# Gráfico principal: linha azul e pontos vermelhos
plt.plot(x_valores, y_valores,
         marker='o', linestyle='-',
         color='blue',
         markerfacecolor='red',
         markeredgecolor='red',
         label='Energia Mensal x Demanda Máxima')

# Grid principal
plt.grid(which='major', linestyle='--', alpha=0.8, linewidth=0.9)

# Grid secundária
ax = plt.gca()
ax.xaxis.set_minor_locator(AutoMinorLocator(4))       # 3 linhas entre cada major
ax.yaxis.set_minor_locator(AutoMinorLocator(5))       # 4 linhas entre cada major

# Aplicar grid nos ticks secundários (minor)
plt.grid(which='minor', linestyle=':', alpha=0.5, linewidth=0.7)

plt.xlabel('Energia Mensal')
plt.ylabel('Demanda Máxima')
plt.title('Relação: Energia Mensal x Demanda Máxima')
plt.legend()
plt.tight_layout()
plt.show()

# Um DataFrame é inicializado para o armazenamento dos resultados.
DemandaMaxNaoCoincidente_teste = pd.DataFrame()

# O processo é iterado para cada tamanho de grupo N, de 1 a 10.
for N in range(1, 11):
  k = 0
  if N == 1:
    # Para o caso unitário, a média das demandas máximas é utilizada.
    k = DemandaMax_teste.mean()
  else:
    # Para N>1 o processo de amostragem é repetido 10 vezes para cada N.
    for i in range(1, 11):
      # N consumidores são selecionados aleatoriamente e seus picos individuais são somados.
      k = k + ((DemandaMax_teste.sample(n=N, random_state=i)).sum())
    # A média das 10 repetições é calculada para reduzir a variabilidade da amostra.
    k = k/10

  # O valor médio resultante é armazenado no DataFrame de saída.
  if DemandaMaxNaoCoincidente_teste.empty == True:
    # Cria coluna se o DataFrame estiver vazio
    DemandaMaxNaoCoincidente_teste.loc[0, 'valores'] = k
  else:
    # Adiciona uma linha na coluna se o DataFrame não estiver vazio
    DemandaMaxNaoCoincidente_teste.loc[len(DemandaMaxNaoCoincidente_teste),'valores'] = k

FD = pd.DataFrame({'FD':[1.5, 1.75, 2, 2.2, 2.25, 2.275, 2.5, 2.6, 2.65, 2.7]}) # Valores fictícios - Pegar valores obtidos pelo CLAUDEAN

# O cálculo é realizado para cada agrupamento (N = 1 até 10).
DemandaDiversificada_teste = DemandaMaxNaoCoincidente_teste['valores']/FD['FD']