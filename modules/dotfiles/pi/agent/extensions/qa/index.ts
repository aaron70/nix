import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
  Editor,
  type EditorTheme,
  Key,
  matchesKey,
  Text,
  visibleWidth,
  wrapTextWithAnsi,
} from "@earendil-works/pi-tui";
import { Type } from "typebox";

interface Option {
  label: string;
  description?: string;
  recommended?: boolean;
}

interface Question {
  question: string;
  clarification?: string;
  options: Option[];
}

interface Answer {
  question: string;
  answer: string;
  custom: boolean;
  recommended: boolean;
}

interface QuestionnaireResult {
  answers: Answer[];
  cancelled: boolean;
  userQuestions?: string[];
}

const OptionSchema = Type.Object({
  label: Type.String({ description: "A concise possible answer" }),
  description: Type.Optional(Type.String({ description: "Optional context that helps explain this answer" })),
  recommended: Type.Optional(Type.Boolean({ description: "Mark the single best-fit answer as recommended" })),
});

const QuestionSchema = Type.Object({
  question: Type.String({ description: "The question to ask the user" }),
  clarification: Type.Optional(Type.String({ description: "Optional plain-language clarification" })),
  options: Type.Optional(
    Type.Array(OptionSchema, { description: "Possible answers; mark exactly one as recommended when provided" }),
  ),
});

const ParamsSchema = Type.Object({
  questions: Type.Array(QuestionSchema, {
    description: "Questions to ask one at a time. Include useful answer options and mark the best-fit option recommended when possible.",
  }),
});

function formatAnswers(answers: Answer[]): string {
  return answers.map((answer, i) => `Q${i + 1}: ${answer.question}\nA${i + 1}: ${answer.answer}`).join("\n\n");
}

function isQuestionOrDoubt(text: string): boolean {
  const answer = text.trim();
  return (
    /[?？]/u.test(answer) ||
    /^(?:who|what|when|where|why|how|which|whose|whom|is|are|am|do|does|did|can|could|would|will|should|have|has|had)\b/i.test(answer) ||
    /\b(?:i(?:'m| am) (?:not sure|confused|unclear|unsure)|i (?:don't|do not) (?:understand|get)|i have a question|could you (?:explain|clarify)|please (?:explain|clarify))\b/i.test(answer)
  );
}

function questionFollowUp(userQuestions: string[]): string {
  if (userQuestions.length === 0) return "";
  return [
    "",
    "The user also asked a question or expressed a doubt in their answer:",
    ...userQuestions.map((question) => `- ${question}`),
    "Before resuming the original task or asking more questions, answer and clarify each point directly. If the user's meaning is still unclear, ask a focused follow-up instead of assuming.",
  ].join("\n");
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "ask_questions",
    label: "Q/A",
    description:
      "Ask the user one or more clarifying questions in an interactive TUI. Use when user intent, requirements, preferences, or an action needs clarification. Include helpful answer options when possible, mark exactly one best-fit option as recommended, and always allow a custom typed answer. Questions appear one at a time; users can go back to revise previous answers. If the user answers with a question or expresses a doubt, answer and clarify it before resuming the original task.",
    promptSnippet: "Ask the user clarifying questions in an interactive Q/A screen.",
    promptGuidelines: [
      "Use ask_questions when the user's intent or preference is meaningfully ambiguous; do not interrupt for details that can be safely inferred.",
      "Provide useful answer options when practical, mark exactly one best-fit option as recommended, and add a short clarification when it helps the user understand the question.",
      "If any user answer includes a question or expresses confusion/uncertainty, pause the original task, answer and clarify the user's doubt directly, and only then continue. Do not treat that text as merely an option selection.",
    ],
    parameters: ParamsSchema,
    exposure: "model-only",
    executionMode: "sequential",

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (ctx.mode !== "tui") {
        return {
          content: [{ type: "text", text: "Q/A requires an interactive TUI; no questions were asked." }],
          details: { answers: [], cancelled: true } satisfies QuestionnaireResult,
        };
      }
      if (params.questions.length === 0) {
        return {
          content: [{ type: "text", text: "No questions were provided." }],
          details: { answers: [], cancelled: true } satisfies QuestionnaireResult,
        };
      }

      // Guarantee one recommended option when choices exist; if several were marked,
      // preserve only the first. This keeps the UI unambiguous even for imperfect input.
      const questions: Question[] = params.questions.map((question) => {
        const options = question.options ?? [];
        const recommendedIndex = Math.max(0, options.findIndex((option) => option.recommended));
        return {
          ...question,
          options: options.map((option, index) => ({
            ...option,
            recommended: options.length > 0 && index === recommendedIndex,
          })),
        };
      });

      const result = await ctx.ui.custom<QuestionnaireResult>((tui, theme, _keybindings, done) => {
        let questionIndex = 0;
        let optionIndex = Math.max(0, questions[0].options.findIndex((option) => option.recommended));
        let editing = false;
        let editorError = false;
        let cachedWidth: number | undefined;
        let cachedLines: string[] | undefined;
        const answers = new Map<number, Answer>();
        const selectedOptions = new Map<number, number>();

        const editorTheme: EditorTheme = {
          borderColor: (text) => theme.fg("accent", text),
          selectList: {
            selectedPrefix: (text) => theme.fg("accent", text),
            selectedText: (text) => theme.fg("accent", text),
            description: (text) => theme.fg("muted", text),
            scrollInfo: (text) => theme.fg("dim", text),
            noMatch: (text) => theme.fg("warning", text),
          },
        };
        const editor = new Editor(tui, editorTheme);

        function refresh() {
          cachedWidth = undefined;
          cachedLines = undefined;
          tui.requestRender();
        }

        function selectOption(index: number) {
          const question = questions[questionIndex];
          if (!question) return;
          if (index === question.options.length) {
            editing = true;
            editorError = false;
            const previous = answers.get(questionIndex);
            editor.setText(previous?.custom ? previous.answer : "");
            refresh();
            return;
          }
          const option = question.options[index];
          if (!option) return;
          answers.set(questionIndex, {
            question: question.question,
            answer: option.label,
            custom: false,
            recommended: option.recommended === true,
          });
          selectedOptions.set(questionIndex, index);
          moveForward();
        }

        function complete(cancelled: boolean) {
          done({
            answers: [...answers.entries()].sort(([a], [b]) => a - b).map(([, answer]) => answer),
            cancelled,
          });
        }

        function moveForward() {
          questionIndex = Math.min(questionIndex + 1, questions.length);
          if (questionIndex < questions.length) {
            optionIndex = selectedOptions.get(questionIndex) ?? questions[questionIndex].options.findIndex((option) => option.recommended);
            if (optionIndex < 0) optionIndex = 0;
          }
          refresh();
        }

        function moveBack() {
          if (questionIndex === 0) return;
          questionIndex--;
          optionIndex = selectedOptions.get(questionIndex) ?? questions[questionIndex].options.findIndex((option) => option.recommended);
          if (optionIndex < 0) optionIndex = 0;
          refresh();
        }

        editor.onSubmit = (value) => {
          const answer = value.trim();
          if (!answer) {
            editorError = true;
            refresh();
            return;
          }
          const question = questions[questionIndex];
          answers.set(questionIndex, { question: question.question, answer, custom: true, recommended: false });
          selectedOptions.set(questionIndex, question.options.length);
          editing = false;
          editorError = false;
          moveForward();
        };

        function render(width: number): string[] {
          if (cachedLines && cachedWidth === width) return cachedLines;

          const lines: string[] = [];
          const renderWidth = Math.max(1, width);
          const isReview = questionIndex === questions.length;
          const question = isReview ? undefined : questions[questionIndex];
          const options = question?.options ?? [];
          const customIndex = options.length;
          const optionCount = options.length + 1;

          function addWrapped(text: string) {
            lines.push(...wrapTextWithAnsi(text, renderWidth));
          }

          function addWrappedWithPrefix(prefix: string, text: string) {
            const prefixWidth = visibleWidth(prefix);
            if (prefixWidth >= renderWidth) {
              addWrapped(prefix + text);
              return;
            }
            const wrapped = wrapTextWithAnsi(text, renderWidth - prefixWidth);
            const continuationPrefix = " ".repeat(prefixWidth);
            for (let i = 0; i < wrapped.length; i++) {
              lines.push(`${i === 0 ? prefix : continuationPrefix}${wrapped[i]}`);
            }
          }

          lines.push(theme.fg("accent", "─".repeat(renderWidth)));
          if (isReview) {
            addWrappedWithPrefix(" ", theme.fg("accent", theme.bold("Review your answers")));
            lines.push("");
            for (let i = 0; i < questions.length; i++) {
              addWrappedWithPrefix(" ", `${theme.fg("muted", `Q${i + 1}: `)}${theme.fg("text", questions[i].question)}`);
              addWrappedWithPrefix("    ", theme.fg("success", answers.get(i)?.answer ?? ""));
            }
            lines.push("");
            addWrappedWithPrefix(" ", theme.fg("success", "Enter to submit • ← review/change answers • Esc to cancel"));
          } else if (question) {
            addWrappedWithPrefix(
              " ",
              theme.fg("accent", theme.bold(`Question ${questionIndex + 1} of ${questions.length}`)),
            );
            lines.push("");
            addWrappedWithPrefix(" ", theme.fg("text", question.question));
            if (question.clarification?.trim()) {
              addWrappedWithPrefix(" ", theme.fg("muted", question.clarification.trim()));
            }
            lines.push("");

            for (let i = 0; i < optionCount; i++) {
              const option = options[i];
              const isCustom = i === customIndex;
              const selected = i === optionIndex;
              const chosen = answers.has(questionIndex) && selectedOptions.get(questionIndex) === i;
              const prefix = selected ? theme.fg("accent", "> ") : "  ";
              let label = `${i + 1}. ${isCustom ? "Type your own answer…" : option.label}`;
              if (option?.recommended) label += ` ${theme.fg("success", "★ Recommended")}`;
              if (chosen) label += ` ${theme.fg("success", "✓")}`;
              addWrappedWithPrefix(prefix, theme.fg(selected ? "accent" : "text", label));
              if (option?.description?.trim()) {
                addWrappedWithPrefix("     ", theme.fg("muted", option.description.trim()));
              }
            }

            if (editing) {
              lines.push("");
              addWrappedWithPrefix(" ", theme.fg(editorError ? "warning" : "muted", editorError ? "Please enter an answer:" : "Your answer:"));
              for (const line of editor.render(Math.max(1, renderWidth - 2))) lines.push(` ${line}`);
              addWrappedWithPrefix(" ", theme.fg("dim", "Enter to save and continue • Esc to return to options"));
            }
          }

          lines.push("");
          if (!editing && !isReview) {
            addWrappedWithPrefix(" ", theme.fg("dim", "↑↓ or 1–9 choose • Enter answer/continue • ← back • → next • Esc cancel"));
          }
          lines.push(theme.fg("accent", "─".repeat(renderWidth)));
          cachedWidth = width;
          cachedLines = lines;
          return lines;
        }

        return {
          render,
          invalidate() {
            cachedWidth = undefined;
            cachedLines = undefined;
          },
          handleInput(data: string) {
            if (editing) {
              if (matchesKey(data, Key.escape)) {
                editing = false;
                editorError = false;
                editor.setText("");
                refresh();
              } else {
                editor.handleInput(data);
                refresh();
              }
              return;
            }

            if (matchesKey(data, Key.escape)) {
              complete(true);
              return;
            }
            if (matchesKey(data, Key.left)) {
              moveBack();
              return;
            }
            if (questionIndex >= questions.length) {
              if (matchesKey(data, Key.enter)) complete(false);
              return;
            }

            const question = questions[questionIndex];
            const optionCount = question.options.length + 1;
            if (matchesKey(data, Key.right) || matchesKey(data, Key.tab)) {
              if (answers.has(questionIndex)) moveForward();
              return;
            }
            if (matchesKey(data, Key.up)) {
              optionIndex = Math.max(0, optionIndex - 1);
              refresh();
              return;
            }
            if (matchesKey(data, Key.down)) {
              optionIndex = Math.min(optionCount - 1, optionIndex + 1);
              refresh();
              return;
            }
            if (/^[1-9]$/.test(data)) {
              const numberedIndex = Number(data) - 1;
              if (numberedIndex < optionCount) {
                optionIndex = numberedIndex;
                selectOption(numberedIndex);
              }
              return;
            }
            if (matchesKey(data, Key.enter)) selectOption(optionIndex);
          },
          get focused() {
            return editor.focused;
          },
          set focused(value: boolean) {
            editor.focused = value;
          },
        };
      });

      const userQuestions = result.answers.map((answer) => answer.answer).filter(isQuestionOrDoubt);
      const details: QuestionnaireResult = { ...result, userQuestions };
      const answersText = result.cancelled
        ? result.answers.length > 0
          ? `User cancelled the Q/A flow after answering:\n${formatAnswers(result.answers)}`
          : "User cancelled the Q/A flow without answering."
        : formatAnswers(result.answers);
      const text = answersText + questionFollowUp(userQuestions);
      return { content: [{ type: "text", text }], details };
    },

    renderCall(args, theme) {
      const count = Array.isArray(args.questions) ? args.questions.length : 0;
      return new Text(
        theme.fg("toolTitle", theme.bold("Q/A ")) + theme.fg("muted", `Ask ${count} clarifying question${count === 1 ? "" : "s"}`),
        0,
        0,
      );
    },

    renderResult(result, _options, theme) {
      const details = result.details as QuestionnaireResult | undefined;
      if (!details) {
        const first = result.content[0];
        return new Text(first?.type === "text" ? first.text : "", 0, 0);
      }
      if (details.cancelled) return new Text(theme.fg("warning", "Q/A cancelled"), 0, 0);
      const lines = details.answers.map((answer, i) => {
        const marker = answer.recommended ? " (recommended)" : answer.custom ? " (custom)" : "";
        return `${theme.fg("success", "✓ ")}${theme.fg("accent", `Q${i + 1}: `)}${answer.answer}${theme.fg("muted", marker)}`;
      });
      if (details.userQuestions?.length) {
        lines.push(theme.fg("warning", "Answer the user's question/doubt before continuing."));
      }
      return new Text(lines.join("\n"), 0, 0);
    },
  });
}
