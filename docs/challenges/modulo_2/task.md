# Módulo 2 — Arquitetura: Tokenização, Embeddings e Attention

> **Objetivo:** entender como texto vira número (token -> embedding) e como
> o modelo relaciona tokens (attention). Implementar as peças fundamentais
> que o RAG vai precisar (similaridade, contratos de embedding/geração).

**Status:** teoria concluída. Prática de código em aberto.

---

## Tarefas — Teoria/Experimentação

- [ ] Baixar `nomic-embed-text` (`ollama pull nomic-embed-text`)
- [ ] Gerar embedding via `/api/embed` e anotar o tamanho do vetor
- [ ] Gerar embedding de dois textos de assuntos diferentes e confirmar:
      vetores não são interpretáveis a olho nu

## Tarefas — Código

- [ ] Modelar a representação de um "pedaço de documento" (chunk): decidir
      quais informações ele precisa guardar (texto? embedding? origem?)
- [ ] Implementar `cosine_similarity(a, b)` de forma pura/testável
      - testar isolado com vetores simples (ex: [1,0] vs [0,1] vs [1,1])
- [ ] Definir o contrato (assinatura/interface) de "algo que gera embedding"
      a partir de um texto
- [ ] Definir o contrato de "algo que gera texto" a partir de um prompt

> Como organizar esses componentes em arquivos/módulos é decisão sua. Use
> `docs/architecture.md` como referência opcional, não como exigência.

## Conceitos envolvidos

- Token != palavra (BPE / subpalavra)
- Embedding = vetor que captura significado; proximidade = similaridade
- Attention: Query/Key/Value, processamento paralelo (não sequencial)
- Camadas empilhadas = abstração progressiva (analogia CNN)

## Definition of Done

- A similaridade entre vetores está implementada e testada (1.0 para vetores
  iguais, ~0 para ortogonais).
- Os contratos de embedding e geração estão definidos antes de qualquer
  implementação concreta (Ollama ou outra).
