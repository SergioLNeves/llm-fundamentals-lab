# Módulo 1 — Fundamentos de IA/LLM

> **Objetivo:** entender o que é um LLM na prática e por que ele é
> probabilístico, não determinístico. Sentir os limites de instruction
> following e a diferença entre "pedir em texto" vs "restringir
> estruturalmente".

**Status:** parcialmente concluído nas conversas iniciais.
**Pré-requisito:** Ollama instalado e rodando.

---

## Tarefas

- [ ] Rodar `ollama run llama3.2` e completar uma frase simples
- [ ] Testar instrução composta ("complete X e pare na primeira palavra") e
      observar a falha de instruction following
- [ ] Gerar JSON via prompt em texto (`/api/generate`) e avaliar se quebraria
      um parse direto
- [ ] Testar o parâmetro nativo `format: "json"` e observar:
      - sintaxe garantida
      - schema **não** garantido (campos inventados)
- [ ] Anotar em 3-4 linhas: por que um LLM nunca deve ser o único guardião de
      uma regra crítica

## Conceitos envolvidos

- LLM = preditor de próximo token em loop
- Tokenização (intuição)
- Instruction following e seus limites
- Texto livre vs restrição estrutural (structured output)

## Definition of Done

- Consegue explicar com as próprias palavras por que a instrução "pare na
  primeira palavra" falhou.
- Entende que `format: "json"` resolve sintaxe, não schema.
