# Módulo 3 — Sampling Parameters: Controlando a Geração

> **Objetivo:** entender e sentir na prática como os parâmetros de sampling
> controlam o comportamento do LLM — transformando o mesmo modelo em
> determinístico ou criativo dependendo da configuração. Conectar esses
> parâmetros com a natureza probabilística vista no Módulo 1.

**Status:** não iniciado.
**Pré-requisito:** Módulo 1 concluído (natureza probabilística do LLM).
**Entrega:** anotações comparativas dos experimentos com cada parâmetro.

---

## O problema que este módulo resolve

No Módulo 1 você viu que LLMs são probabilísticos: o mesmo prompt pode gerar
respostas diferentes a cada execução. Mas você também pode **controlar** esse
comportamento. Os parâmetros de sampling são os botões que determinam o quanto
o modelo "ousa" vs o quanto ele é previsível.

Sem entender esses parâmetros, você não consegue explicar por que o modelo é
criativo demais numa tarefa de código (onde você quer exatidão) ou repetitivo
demais numa tarefa de escrita (onde você quer variedade).

---

## Os parâmetros

### Temperature
Controla a "ousadia" na escolha do próximo token.

- `temperature=0.0` → sempre escolhe o token mais provável (determinístico)
- `temperature=1.0` → distribuição original do modelo
- `temperature>1.0` → mais aleatório, pode virar incoerente

### Top-p (nucleus sampling)
Limita o conjunto de tokens candidatos ao grupo que soma probabilidade `p`.

- `top_p=0.9` → considera apenas os tokens que juntos somam 90% da
  probabilidade; ignora os tokens menos prováveis
- Controla variedade sem aceitar tokens absurdos

### Top-k
Limita o conjunto a apenas os `k` tokens mais prováveis.

- `top_k=40` → considera só os 40 candidatos mais prováveis
- Mais agressivo que top-p em termos de limitação

### Repeat penalty
Penaliza tokens que já apareceram recentemente no output.

- Reduz repetição de frases e palavras
- Útil para geração de textos longos

### Seed
Fixa a semente do gerador de números aleatórios.

- Mesmo prompt + mesmo seed → mesma resposta (reprodutibilidade)
- Útil para testes e debugging

---

## Tarefas — Experimentos

> Use `/api/generate` do Ollama diretamente para controlar os parâmetros.
> Script Python ou curl, à sua escolha.

- [ ] **Temperature extrema**: gerar a mesma frase 5 vezes com
      `temperature=0.0` (todas iguais?) e depois com `temperature=1.5`
      (coerentes? incoerentes?)
- [ ] **Código vs criativo**: pedir para gerar uma função Python com
      `temperature=0.0` e depois pedir um poema com `temperature=0.0` —
      o que acontece com a criatividade?
- [ ] **Top-p vs top-k**: gerar 10 continuações de uma frase incompleta
      variando top-p (0.5 vs 0.95) e observar a diversidade
- [ ] **Repeat penalty**: gerar um texto longo (~300 tokens) com
      `repeat_penalty=1.0` vs `repeat_penalty=1.3` — o modelo repete menos?
- [ ] **Seed para reprodutibilidade**: confirmar que seed fixo + mesmos
      parâmetros produz output idêntico em duas execuções
- [ ] **Combinações práticas**: testar e anotar os valores que você usaria
      para cada cenário:

| Cenário | temperature | top_p | repeat_penalty |
|---------|-------------|-------|----------------|
| Geração de código | | | |
| Chat assistente | | | |
| Escrita criativa | | | |
| Resposta factual/RAG | | | |

---

## O que NÃO fazer

- **Não deixar temperature=1.0 para código**: o modelo pode gerar código
  sintaticamente válido mas logicamente errado com alta temperatura
- **Não usar temperature=0.0 para tudo**: perde criatividade e pode prender
  o modelo em loops de repetição em textos longos
- **Não empilhar top-p e top-k sem necessidade**: geralmente um ou outro é
  suficiente; ambos juntos restringem demais o espaço de tokens

---

## Conceitos envolvidos

- Distribuição de probabilidade sobre o vocabulário
- Softmax e como temperature escala os logits
- Nucleus sampling (top-p) vs top-k
- Trade-off: determinismo vs diversidade
- Reprodutibilidade com seed

## Conexão com módulos anteriores

| Módulo | Conexão |
|--------|---------|
| 1 — Fundamentos | temperature explica por que o mesmo prompt gera respostas diferentes |

## Definition of Done

- Consigo prever o comportamento do modelo dado um conjunto de parâmetros
  (alta temperature → mais variado; baixa → mais repetível).
- Tenho uma tabela pessoal de configurações para pelo menos 3 cenários de uso.
- Consigo explicar a diferença entre top-p e top-k e quando usar cada um.
