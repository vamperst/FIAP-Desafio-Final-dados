**Desafio Técnico AWS: Análise de Dados de Animes**

Este desafio é projetado para grupos compostos por alunos de MBA em BI e Engenharia de Dados, com duração máxima de 1 hora e 30 minutos. Cada grupo utilizará sua própria conta AWS para desenvolver uma solução que abrange desde a aquisição dos dados até a disponibilização de um dashboard interativo. As ferramentas AWS a serem utilizadas incluem S3, Glue, Athena, QuickSight, QuickSight Q e Amazon Q.

**Datasets Disponíveis:**

1. **anime-dataset-2023**
2. **anime-filtered**
3. **final_animedataset**
4. **user-filtered**
5. **users-details-2023**
6. **users-score-2023**


## Cenários de Negócio

Cada grupo deverá escolher **um** dos cenários abaixo e, com base no(s) dataset(s) designado(s), construir uma solução em AWS que entregue um **painel interativo com insights de negócio**. Esses cenários são pensados como **desafios reais de uma empresa de mídia, streaming ou análise de mercado de animes**, como se você estivesse entregando valor para o time de produto, marketing ou executivos.

---

### 📊 1. **Análise de Popularidade de Gêneros de Animes**

**Contexto de Negócio:**
Uma empresa de streaming especializada em animes está planejando sua próxima aquisição de catálogo. O objetivo é **entender quais gêneros de animes possuem maior apelo entre os usuários** para guiar decisões de compra e licenciamento. Além disso, esses dados servirão de base para o algoritmo de recomendação da plataforma.

**Objetivo:**
Identificar os gêneros de anime com maiores médias de avaliação e volume de notas, permitindo determinar:
- Quais gêneros são os favoritos do público?
- Existe algum gênero com notas altas, mas baixa audiência (nicho com potencial)?
- Como os gêneros performam ao longo dos anos?

**Datasets sugeridos:**  
- `anime-dataset-2023`: contém metadados dos animes, incluindo gênero.  
- `users-score-2023`: contém avaliações (notas) dadas por usuários para cada anime.

---

### 🏢 2. **Avaliação da Qualidade dos Animes por Estúdio**

**Contexto de Negócio:**
Uma produtora de conteúdo está considerando **parcerias estratégicas com estúdios de animação**. Para isso, deseja entender **quais estúdios têm maior histórico de qualidade percebida**, com base nas avaliações da comunidade MyAnimeList. Isso também pode embasar decisões de investimento ou contratação de estúdios terceirizados.

**Objetivo:**
Responder a perguntas como:
- Quais estúdios produzem os animes mais bem avaliados?
- Existe consistência na qualidade dos estúdios ao longo do tempo?
- Existe algum estúdio subestimado com média alta, mas pouca produção?

**Datasets sugeridos:**  
- `anime-dataset-2023`: contém informações sobre os estúdios de produção.  
- `users-score-2023`: contém as avaliações dos usuários.

---

### 👥 3. **Comportamento de Usuários em Relação a Tipos de Animes**

**Contexto de Negócio:**
A plataforma de streaming está avaliando **qual formato de anime priorizar** (séries de TV, OVAs, filmes, etc.). Além disso, deseja entender o **comportamento dos usuários em relação a esses formatos**: quais assistem mais? Quais abandonam? Quais recebem melhores avaliações?

**Objetivo:**
Entender o comportamento de consumo e engajamento por tipo de anime:
- Qual tipo de anime é mais assistido (quantidade de usuários por tipo)?
- Existem tipos com avaliação consistentemente melhor?
- O tempo médio de engajamento varia por tipo?

**Datasets sugeridos:**  
- `anime-dataset-2023`: contém o tipo de anime (TV, Movie, OVA, etc.).  
- `user-filtered`: dados de usuários com animes assistidos e progresso.

---

### ⏱️ 4. **Correlação entre Duração dos Episódios e Avaliações**

**Contexto de Negócio:**
Os estúdios e produtores querem entender **se o tempo médio de episódio influencia a avaliação do anime**. Há um dilema entre criar animes mais curtos (mais baratos e fáceis de consumir) ou episódios longos (mais profundos e complexos).

**Objetivo:**
Investigar:
- Existe correlação entre duração média dos episódios e nota média?
- Há um “ponto ótimo” de duração?
- Esse comportamento varia por gênero ou tipo de anime?

**Datasets sugeridos:**  
- `anime-dataset-2023`: contém informações sobre duração e tipo.  
- `users-score-2023`: contém as notas atribuídas pelos usuários.

---

### 🧬 5. **Análise Demográfica dos Avaliadores de Animes**

**Contexto de Negócio:**
A equipe de marketing de uma nova plataforma deseja realizar **campanhas segmentadas por perfil de usuário**. Com base nas informações demográficas, eles querem saber **quem são os usuários mais ativos e como preferências variam entre faixas etárias, gêneros, etc.**

**Objetivo:**
- Quais faixas etárias mais consomem e avaliam animes?
- Homens e mulheres diferem em média de notas e gêneros preferidos?
- Existe algum grupo demográfico que tende a avaliar mais negativamente?

**Datasets sugeridos:**  
- `users-details-2023`: informações demográficas dos usuários.  
- `users-score-2023`: avaliações que cada usuário deu a cada anime.

---

### Observação final:

Todos os cenários têm o mesmo peso de avaliação (conforme os critérios definidos anteriormente). O que muda é **o problema de negócio**, e a capacidade do grupo de **extrair insights relevantes e apresentar um painel claro, estruturado e que comunique o valor dos dados**.

---

**Critérios de Avaliação:**

- **Apresentação (Pitch) com Dashboard no QuickSight**
    Cada grupo deverá realizar uma apresentação de até 5 minutos, utilizando o dashboard desenvolvido no Amazon QuickSight como base para comunicar suas descobertas.

    A avaliação considerará os seguintes aspectos:

1. **Clareza dos Insights** 
    Os principais achados foram comunicados de forma objetiva?

    Os gráficos escolhidos foram explorados de forma que traduzam dados em informação útil para o negócio?

    O grupo evitou apenas “ler gráficos” e realmente explicou o que os dados significam?

2. **Estrutura da Apresentação**
    A apresentação teve início (contexto do problema), meio (análises realizadas) e fim (conclusões/recomendações)?

    Os dados e as visualizações foram conectados a uma narrativa coerente, voltada para responder o cenário de negócio proposto?

3. **Domínio do Dashboard**
    Os alunos demonstraram segurança na navegação pelo QuickSight, sabendo onde encontrar os dados, interagir com filtros e explicar as visualizações?

    Usaram recursos como filtros, drill-down ou QuickSight Q para enriquecer a apresentação?

    Conseguiram responder perguntas da banca ou discutir limitações e alternativas?

**Comunicação**
A linguagem foi acessível e adequada a um público executivo ou de produto?

O grupo demonstrou confiança e clareza ao explicar as decisões tomadas ao longo do desafio?


Caso queira, existe um roteiro como [exemplo](/roteiro_pitch_quicksight.md).

Consulte o [dicionario de dados](/dicionario/README.md) para entender melhor os datasets disponíveis.