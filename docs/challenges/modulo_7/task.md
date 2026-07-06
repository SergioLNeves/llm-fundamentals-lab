# Módulo 7 — Treino/Ajuste e Consolidação

> **Objetivo:** sair do "usar LLM pronto" para "ajustar um LLM". Entender
> fine-tuning leve (LoRA) e, opcionalmente, portar o core do projeto para Go,
> consolidando tudo o que foi aprendido.

**Status:** não iniciado.
**Pré-requisito:** Módulos 1, 2, 4 e 5 concluídos.

---

## Tarefas — Fine-tuning (conceito + prática leve)

- [ ] Entender a diferença entre fine-tuning completo vs LoRA/PEFT
      (por que LoRA é viável em hardware comum)
- [ ] Preparar um dataset pequeno (formato instrução -> resposta)
- [ ] Rodar um fine-tuning leve (LoRA) em um modelo pequeno
- [ ] Criar um Modelfile no Ollama com o modelo ajustado e testar
- [ ] Comparar respostas do modelo base vs ajustado no mesmo prompt

## Tarefas — Avaliação do limite de uma LLM

- [ ] Definir uma tarefa específica e medir até onde o modelo pequeno consegue
      ir (objetivo original: "entender o limite de uma LLM")
- [ ] Documentar: o que melhora com RAG, o que melhora com fine-tuning, o que
      só melhora com modelo maior

## Tarefas — Port para Go (opcional)

- [ ] Portar o core (cosine similarity, chamada ao Ollama, retrieval) para Go
      com arquitetura hexagonal real (`samber/do`, ports como interfaces)
- [ ] Comparar a experiência de implementação Python vs Go

## Conceitos envolvidos

- Fine-tuning completo vs PEFT/LoRA
- Dataset de instrução
- Quando usar RAG vs fine-tuning vs modelo maior
- Limites reais de modelos pequenos

## Definition of Done

- Consigo explicar, com base em experiência prática, quando vale RAG, quando
  vale fine-tuning, e quando o problema só se resolve com um modelo maior.
- (Opcional) Core do RAG rodando em Go.
