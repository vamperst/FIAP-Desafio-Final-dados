
# Roteiro Orientador: Pitch de Apresentação com Dashboard QuickSight

**Duração máxima:** 5 minutos  
**Participação:** Não é necessário que todos do grupo participem, mas é importante que todos estejam preparados para responder perguntas.

---

## 1. Introdução (30–45 segundos)

**Objetivo:** contextualizar o público e explicar o foco da análise.

- Qual foi o cenário de negócio escolhido?
- Por que esse tema é importante para uma empresa da área de mídia, tecnologia ou streaming?
- Qual pergunta ou problema vocês buscaram responder com os dados?

**Exemplo de fala:**

> Nosso grupo utilizou o cenário "Popularidade de gêneros" para entender quais estilos de anime geram maior engajamento e avaliação positiva entre os usuários. Isso é essencial para orientar decisões de catálogo em uma plataforma de streaming.

---

## 2. Caminho dos Dados (30–45 segundos)

**Objetivo:** demonstrar domínio técnico do pipeline de dados.

- Quais datasets foram utilizados?
- Como os dados foram processados: do S3 até o QuickSight?
- Houve alguma transformação, limpeza ou união de dados relevante?

**Exemplo de fala:**

> Usamos os arquivos `anime-dataset-2023` e `users-score-2023`. Após a ingestão no S3, transformamos os dados para o formato Parquet com Glue, criamos o catálogo no Glue Data Catalog e realizamos as consultas no Athena. 

---

## 3. Análises e Insights (2–3 minutos)

**Objetivo:** apresentar os principais achados, usando o dashboard como ferramenta de storytelling.

- Mostre os gráficos e explique o que cada um revela.
- Relacione os resultados ao problema de negócio.
- Destaque tendências, comparações, outliers ou padrões.
- Mostre como filtros, segmentações ou drill-downs ajudaram na análise.
- Caso tenham usado QuickSight Q ou Amazon Q, mostre como esses recursos foram aplicados.

**Exemplo de fala:**

> Neste gráfico, observamos que o gênero "Action" concentra o maior número de avaliações. No entanto, gêneros como "Psychological" e "Mystery" apresentam médias de avaliação mais altas, indicando um público menor, mas muito satisfeito.

---

## 4. Conclusão e Recomendações (30 segundos)

**Objetivo:** encerrar a apresentação com uma mensagem clara e bem estruturada.

- Qual foi a conclusão principal?
- Que recomendações práticas vocês fariam com base nos dados?
- O que poderia ser investigado em uma próxima etapa?

**Exemplo de fala:**

> Concluímos que a plataforma poderia testar a promoção de animes psicológicos, pois possuem excelente avaliação apesar de pouca visibilidade. Em uma próxima etapa, seria interessante cruzar esses dados com dados de visualizações reais da plataforma.

---

## 5. Extra (opcional, se houver tempo)

- Demonstração breve de perguntas feitas com o QuickSight Q.
- Uso do Amazon Q para gerar insights automáticos ou narrativas.

---

## Dicas Finais

- Evite apenas ler os gráficos. Explique o que os dados significam.
- Use uma linguagem clara e objetiva, como se estivesse apresentando para um gestor de produto.
- Divida a apresentação entre os membros do grupo com antecedência.
- Se algo deu errado ou ficou incompleto, seja transparente e explique o porquê.
- Se esquecerem algo durante o pitch, usem o próprio dashboard como guia.
