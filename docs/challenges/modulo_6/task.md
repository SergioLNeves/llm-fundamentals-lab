# Módulo 6 — RAG de Produção: Vector DB e Reranking

> **Objetivo:** evoluir o RAG em memória do Módulo 4 para uma arquitetura
> de produção: banco vetorial persistente, índice eficiente (HNSW), busca
> híbrida e reranking. Sentir a diferença de qualidade de retrieval que cada
> técnica adiciona.

**Status:** não iniciado.
**Pré-requisito:** Módulos 4 e 5 concluídos (RAG funcional + desafios observados).
**Entrega de código:** RAG com vector DB persistente, busca híbrida e reranking.

---

## Por que o RAG em memória do Módulo 4 não escala

O RAG do Módulo 4 armazena embeddings em memória e faz busca por força bruta
(cosine similarity contra todos os vetores). Isso funciona para dezenas de
chunks, mas quebra em produção:

| Problema | Módulo 4 | Este módulo |
|---|---|---|
| Persistência | Perde tudo ao reiniciar | Vector DB persiste em disco |
| Velocidade de busca | O(n) força bruta | O(log n) com índice HNSW |
| Qualidade do retrieval | Só semântica | Híbrido: semântica + keyword |
| Ordem dos chunks | Qualquer ordem | Reranking melhora relevância |

---

## Conceitos novos

### HNSW (Hierarchical Navigable Small World)
Índice de grafos que permite busca aproximada de vizinhos mais próximos em
tempo sub-linear. Usado por Chroma, Qdrant e pgvector internamente. Você não
implementa — você entende para saber o que está usando.

### Busca híbrida
Combina busca semântica (por embedding) com busca por keyword (BM25/TF-IDF).
Semântica captura intenção; keyword captura termos exatos. A combinação
supera qualquer uma isolada, especialmente em documentos técnicos com nomes
específicos (funções, classes, erros).

### Reranking (cross-encoder)
Após buscar os top-k chunks por similaridade, um modelo de reranking
(cross-encoder) avalia cada chunk **em relação à pergunta** e reordena.
Diferença do bi-encoder (que gera embeddings separados): o cross-encoder
lê pergunta + chunk juntos, gerando score muito mais preciso.

> **Conexão com Módulo 13**: reranking resolve parcialmente o "lost in the
> middle" — ao colocar os chunks mais relevantes no início do prompt, você
> garante que o modelo veja o que importa primeiro.

---

## Tarefas — Teoria

- [ ] Entender HNSW intuitivamente: por que grafos de vizinhança permitem
      busca sub-linear? (não precisa implementar, só entender a estrutura)
- [ ] Entender BM25: como ele difere de busca semântica? Em que casos
      keyword supera embedding?
- [ ] Entender cross-encoder vs bi-encoder: por que cross-encoder é mais
      preciso mas mais lento?

## Tarefas — Código

### Etapa 1 — Vector DB persistente

- [ ] Escolher e instalar um dos três: **Chroma** (mais simples, local),
      **Qdrant** (mais features, suporta hybrid search nativo) ou
      **pgvector** (se já usa PostgreSQL)
- [ ] Migrar o código de indexação do Módulo 4 para usar o vector DB escolhido
- [ ] Verificar que o índice persiste: indexar, reiniciar o processo, buscar
      e confirmar que os chunks ainda estão lá

### Etapa 2 — Busca híbrida

- [ ] Implementar busca BM25 sobre os mesmos documentos (biblioteca `rank_bm25`
      ou a busca híbrida nativa do Qdrant)
- [ ] Combinar scores semântico e BM25 com uma função de fusão simples
      (ex: `score = alpha * semantic + (1 - alpha) * bm25`)
- [ ] Testar com uma pergunta que contém um termo técnico exato (nome de função,
      classe, erro): a busca híbrida encontra melhor que só embedding?

### Etapa 3 — Reranking

- [ ] Usar um cross-encoder para reordenar os top-k resultados
      (ex: `cross-encoder/ms-marco-MiniLM-L-6-v2` via `sentence-transformers`)
- [ ] Comparar a ordem antes e depois do reranking: o chunk mais relevante
      subiu para o topo?
- [ ] Medir o impacto na resposta final do LLM: a qualidade melhorou?

### Etapa 4 — Avaliação comparativa

- [ ] Usar o conjunto de perguntas do Módulo 5 e medir retrieval@k: quantas
      vezes o chunk correto aparece nos top-3 com cada configuração:
      - Só embedding (Módulo 4)
      - Embedding + vector DB (Etapa 1)
      - Busca híbrida (Etapa 2)
      - + Reranking (Etapa 3)

---

## Conceitos envolvidos

- Vector DB e persistência de índices
- HNSW — busca aproximada de vizinhos mais próximos
- BM25 — busca por keyword com penalização por frequência
- Busca híbrida — fusão de scores semântico e keyword
- Cross-encoder vs bi-encoder para reranking
- Retrieval@k como métrica de avaliação

## Conexão com módulos anteriores

| Módulo | Componente evoluído aqui |
|--------|--------------------------|
| 2 — Arquitetura | embeddings: agora persistidos e indexados |
| 4 — RAG | pipeline em memória → vector DB + busca híbrida |
| 5 — Desafios | retrieval ruim identificado → reranking como solução |

## Definition of Done

- O índice persiste após reiniciar o processo.
- A busca híbrida supera a busca só por embedding em pelo menos uma pergunta
  com termo técnico específico.
- Consigo explicar quando o reranking ajuda e quando é desperdício de tempo.
