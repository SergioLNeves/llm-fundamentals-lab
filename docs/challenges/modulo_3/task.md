# Módulo 3 — Tipos de LLM e Estratégias de Criação

> **Objetivo:** entender como modelos são criados (pretraining, fine-tuning,
> RLHF), as diferenças de arquitetura (densos vs MoE) e quantização. Ter um
> RAG funcional ponta a ponta: indexar um documento e responder perguntas
> sobre ele.

**Status:** não iniciado.
**Entrega de código:** RAG funcional (indexar + perguntar).

---

## Tarefas — Teoria

- [ ] Anotar a diferença entre: pretraining, fine-tuning, instruction-tuning,
      RLHF (1 frase cada)
- [ ] Entender modelos densos vs MoE (Mixture of Experts) — por que MoE é
      "barato de rodar, caro de armazenar"
- [ ] Entender quantização: por que um modelo "8B" roda numa máquina comum
      (relação entre bits por peso, RAM/VRAM e perda de qualidade)
- [ ] Comparar tamanhos: rodar mesmo prompt em modelo pequeno vs maior e
      anotar diferença de qualidade de raciocínio

## Tarefas — Código

- [ ] Implementar a chamada real ao modelo de embedding (Ollama)
- [ ] Implementar a chamada real ao modelo de geração (Ollama)
- [ ] Implementar um armazenamento de chunks com busca por similaridade
      (pode ser em memória nesta fase)
- [ ] Implementar o fluxo de indexação: documento -> chunking -> embedding ->
      armazenamento
- [ ] Implementar o fluxo de consulta: pergunta -> embedding -> busca dos
      chunks mais relevantes -> montagem do prompt -> geração da resposta
- [ ] Expor esse fluxo de alguma forma utilizável (API, CLI, script — sua
      escolha) e testar com um `.md` real
- [ ] Fazer o retorno da consulta incluir as fontes/chunks usados (não só a
      resposta em texto livre), usando `format: "json"` ou JSON Schema

## Conceitos envolvidos

- Conhecimento paramétrico (treino) vs contextual (RAG)
- Pretraining / fine-tuning / RLHF
- Densos vs MoE; quantização
- Chunking, retrieval top-k, prompt assembly

## Definition of Done

- Consigo indexar um `.md` e fazer uma pergunta, recebendo resposta baseada
  no conteúdo do documento.
- Consigo explicar por que a resposta mudou ao usar RAG vs sem RAG.
