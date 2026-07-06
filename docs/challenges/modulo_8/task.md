# Módulo 8 — Tool Use / Agentes: Chat com o Vault Obsidian

> **Objetivo:** aprender o paradigma de **tool use (function calling)** —
> onde o LLM decide *quando* e *qual* ferramenta chamar — construindo um chat
> que lê documentação Markdown de um vault Obsidian. Contrastar com o RAG dos
> Módulos 2, 4 e 5.

**Status:** não iniciado.
**Pré-requisito:** Módulo 4 concluído (RAG funcional).
**Entrega de código:** chat com acesso de leitura ao vault.

---

## Conceito central — a diferença que esse módulo ensina

| | RAG (Módulos 2, 4 e 5) | Tool Use (este módulo) |
|---|---|---|
| Quem busca o contexto | Você (pipeline fixo) | O **modelo** decide |
| Como o contexto chega | "Empurrado" no prompt | "Puxado" via chamada de ferramenta |
| Paradigma | Retrieval por similaridade | Agente com ferramentas |
| Controle | Total e previsível | Flexível, menos previsível |

> Os dois resolvem "LLM conhecer meus docs", mas por caminhos opostos.
> Fazer ambos e sentir o contraste é o aprendizado principal.

---

## Segurança (ler antes de começar)

- [ ] Fazer **backup do vault** (de preferência com git) antes de qualquer teste
- [ ] Trabalhar em modo **read-only** nesta fase — nada de escrita/edição
- [ ] Restringir o acesso a uma pasta específica do vault, não o vault inteiro

---

## Tarefas — Teoria

- [ ] Entender function calling: o modelo não executa nada; ele **pede** para
      uma ferramenta ser chamada, e o seu código executa e devolve o resultado
- [ ] Entender o loop do agente: prompt -> modelo pede tool -> código executa
      -> resultado volta pro modelo -> modelo responde (ou pede outra tool)
- [ ] Confirmar quais modelos do Ollama suportam tools (ex: llama3.1)

## Tarefas — Código (tool use manual em Python)

> Mesma filosofia do RAG: implementar manual primeiro para entender por dentro.

- [ ] Definir uma ferramenta `read_note(path)` que lê um `.md` do vault
- [ ] Definir uma ferramenta `list_notes()` ou `search_notes(termo)`
- [ ] Descrever essas ferramentas no formato de tools da API do Ollama (schema)
- [ ] Implementar o loop: enviar pergunta + tools -> se o modelo pedir uma
      ferramenta, executar e devolver o resultado -> repetir até resposta final
- [ ] Testar: "o que minhas notas dizem sobre X?" e observar o modelo
      escolhendo qual nota ler

## Tarefas — MCP (padrão da indústria, opcional/avançado)

- [ ] Entender o que um MCP server de Obsidian faz (expõe o vault como
      ferramentas padronizadas; alguns leem o disco direto, outros exigem o
      plugin Obsidian Local REST API)
- [ ] Escolher um server **read-only** e conectar a um cliente
- [ ] Comparar: implementar as ferramentas na mão vs usar um MCP pronto

## Tarefas — Avaliação (conexão com Módulo 5)

- [ ] Fazer a MESMA pergunta via RAG e via tool use; comparar qualidade e
      previsibilidade das respostas
- [ ] Observar falhas típicas de agente: chamar a ferramenta errada, não
      chamar nenhuma, ou entrar em loop
- [ ] Anotar: em quais situações RAG é melhor e em quais tool use é melhor

## Conceitos envolvidos

- Function calling / tool use
- Loop de agente (model -> tool -> result -> model)
- Contexto "empurrado" (RAG) vs "puxado" (agente)
- MCP como padronização de tool use
- Trade-off: previsibilidade vs flexibilidade

## Definition of Done

- Consigo fazer uma pergunta e ver o modelo decidindo sozinho qual nota ler.
- Consigo explicar, com base em teste prático, a diferença entre RAG e tool
  use e quando usar cada um.
