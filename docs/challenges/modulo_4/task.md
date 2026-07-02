# Módulo 4 — Desafios Reais de LLM

> **Objetivo:** observar de forma controlada os problemas reais de LLM
> (hallucination, limite de contexto, retrieval ruim) e construir uma camada
> mínima de avaliação sobre o RAG do Módulo 3.

**Status:** não iniciado.
**Entrega de código:** camada de avaliação/observação no projeto.

---

## Tarefas — Experimentação crítica

- [ ] Fazer uma pergunta cuja resposta **não está** nos documentos e observar:
      o modelo inventa (hallucination) ou admite que não sabe?
- [ ] Ajustar o prompt do `query_service` para instruir "responda apenas com
      base no contexto; se não houver, diga que não sabe" — comparar antes/depois
- [ ] Testar pergunta ambígua e observar a qualidade do retrieval
- [ ] Forçar chunks mal cortados (chunk muito pequeno / muito grande) e
      observar o impacto na resposta

## Tarefas — Avaliação

- [ ] Medir relevância do retrieval: para uma pergunta conhecida, os top-k
      chunks retornados fazem sentido?
- [ ] Anotar limitações: onde o RAG falha e por quê (retrieval vs geração)

## Conceitos envolvidos

- Hallucination e como RAG reduz (mas não elimina)
- Context window e seus limites
- Qualidade de chunking impacta mais que o LLM em muitos casos
- Avaliação: benchmark vs uso real
- Prompt como "grounding" (ancorar resposta no contexto)

## Definition of Done

- Consigo provocar e identificar uma hallucination.
- Consigo explicar se uma resposta ruim veio do retrieval (contexto errado)
  ou da geração (modelo ignorou o contexto).
