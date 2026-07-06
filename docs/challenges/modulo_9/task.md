# Módulo 9 — Memória e Estado Conversacional

> **Objetivo:** tornar os agentes stateful — capazes de lembrar o que foi dito
> nos turnos anteriores. Entender as estratégias de gestão de histórico (janela
> deslizante, sumarização) e como cada uma afeta o context window e a qualidade
> das respostas.

**Status:** não iniciado.
**Pré-requisito:** Módulo 8 concluído (loop de agente com tool use).
**Entrega de código:** agente com memória conversacional funcional usando ao
menos duas estratégias de gestão de histórico.

---

## O problema que este módulo resolve

Todos os agentes dos módulos anteriores são **stateless**: cada pergunta começa
um contexto novo, sem memória do que veio antes. Na prática isso significa que:

- "O que eu perguntei antes?" → o modelo não sabe
- "Refine a última resposta" → qual última resposta?
- "Continue a lista que você começou" → não há lista no contexto

Memória conversacional resolve isso, mas introduz um novo problema: o context
window tem tamanho fixo. Quanto mais histórico você acumula, menos espaço sobra
para o conteúdo real da resposta.

---

## Estratégias de gestão de histórico

### 1. Janela deslizante (sliding window)
Mantém apenas os últimos N turnos no contexto. Simples e previsível.
- Vantagem: implementação trivial, custo de tokens constante
- Desvantagem: perde contexto de conversas longas abruptamente

### 2. Sumarização de contexto
Periodicamente sumariza os turnos mais antigos em um bloco compacto e mantém
esse resumo + os últimos N turnos.
- Vantagem: preserva informação essencial de conversas longas
- Desvantagem: introduz uma chamada extra ao LLM; resumos podem perder detalhes

### 3. Memória seletiva (apenas para referência)
Extrai e armazena fatos importantes da conversa (entidades, preferências) em
uma memória estruturada separada. Mais complexo — não implementado neste módulo,
mas útil conhecer.

---

## Tarefas — Teoria

- [ ] Calcular o custo em tokens de diferentes estratégias: numa conversa
      de 20 turnos com respostas de ~200 tokens cada, quantos tokens o
      contexto acumula? Quando estoura a janela de 128k do llama3.1:8b?
- [ ] Entender por que sumarização é preferível a truncar bruscamente:
      o que se perde quando o modelo vê o contexto "cortado no meio"?

## Tarefas — Código

### Etapa 1 — Histórico ingênuo (sem gestão)

- [ ] Implementar a estrutura básica de histórico: uma lista de mensagens
      `[{"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}]`
- [ ] Enviar o histórico completo a cada chamada ao Ollama
- [ ] Testar: perguntar algo em 3 turnos encadeados e verificar que o
      modelo lembra o contexto do turno 1 no turno 3
- [ ] Testar o limite: em quantos turnos o contexto começa a estourar?

### Etapa 2 — Janela deslizante

- [ ] Implementar `sliding_window(history, max_turns=10)` que mantém apenas
      os últimos N pares user/assistant
- [ ] Sempre preservar a **system message** fora da janela (ela define o
      comportamento do agente e não deve ser cortada)
- [ ] Testar: após 15 turnos, fazer referência ao que foi dito no turno 1
      e observar que o modelo não lembra mais

### Etapa 3 — Sumarização de contexto

- [ ] Implementar `summarize_history(old_turns)` que usa o próprio LLM para
      sumarizar turnos antigos em um parágrafo
- [ ] Quando o histórico ultrapassar N turnos, sumarizar os mais antigos e
      substituí-los pelo resumo
- [ ] Testar: após 15 turnos, verificar se informação do turno 1 sobrevive
      no resumo e se o modelo ainda consegue referenciá-la

### Etapa 4 — Integrar ao agente do Módulo 8

- [ ] Adicionar gestão de histórico ao agente de doc management: o agente
      deve lembrar que já auditou um arquivo nessa sessão
- [ ] Escolher a estratégia (janela ou sumarização) e justificar a escolha
      para este caso de uso específico

---

## Ponto de reflexão

> O histórico conversacional e o RAG resolvem problemas parecidos mas
> distintos: RAG busca informação em documentos externos; histórico mantém
> contexto da conversa atual. Um agente completo precisa de ambos.
> Qual dos dois tem prioridade quando o context window está cheio?

---

## Conceitos envolvidos

- Histórico multi-turno (messages array)
- Context window como recurso finito
- Janela deslizante — custo constante, perda abrupta
- Sumarização — custo variável, perda gradual
- System message e por que preservá-la
- Stateless vs stateful agents

## Conexão com módulos anteriores

| Módulo | Conexão |
|--------|---------|
| 1 — Fundamentos | context window como limite hard do modelo |
| 8 — Tool Use | o loop de agente agora tem memória entre chamadas |
| 13 — Limitações | context window como limitação estrutural do LLM local |

## Definition of Done

- O agente lembra o contexto de pelo menos 10 turnos anteriores sem estourar
  a janela de contexto.
- Implementei e comparei janela deslizante vs sumarização no mesmo cenário.
- Consigo explicar quando a sumarização vale o custo de uma chamada extra
  ao LLM vs simplesmente truncar o histórico.
