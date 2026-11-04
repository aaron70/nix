# Q/A (`ask_questions`)

Gives the model an `ask_questions` tool that opens an interactive questionnaire in the
pi TUI. The model uses it to ask the user one or more clarifying questions, with optional
answer choices, and receives the answers as the tool result.

The extension registers a single tool and no slash commands.

## Concepts

- **Tool**: `ask_questions`, shown in the TUI as `Q/A`. It is `model-only`, so the user
  cannot invoke it directly. The model calls it when it needs input.
- **Question**: has a `question` text, an optional `clarification`, and an optional list of
  `options`. Without options, the user only gets the custom-answer prompt.
- **Option**: has a `label`, an optional `description`, and an optional `recommended` flag.
- **Recommended option**: exactly one per question. If the model marks several, only the
  first is kept. If none is marked, the first option is used.
- **Custom answer**: the last entry in every list ("Type your own answer…") lets the user
  type free text. It is always available.
- **Doubt detection**: answers that look like a question or express confusion are flagged
  in the tool result, so the model answers them before continuing. See
  [Doubts and questions](#doubts-and-questions).

## Where it lives

- Source: `modules/dotfiles/pi/agent/extensions/qa/index.ts`
- Registered in `modules/dotfiles/pi/pi.nix` as a loader stub (`mkStub "qa" ...`).
  The stub loads an editable copy from `~/.pi/agent/dev-extensions/qa'/` when it exists,
  otherwise the read-only nix store copy.
- To change it, use `/ext edit qa`, then `/ext reload`, then `/ext save qa`. See the
  [Extension Manager README](../extension-manager/README.md).

## Tool parameters

```ts
{
  questions: [
    {
      question: string,              // required
      clarification?: string,        // optional plain-language context
      options?: [                    // optional; omit for free-text only
        {
          label: string,             // required, concise
          description?: string,      // optional context for this choice
          recommended?: boolean,     // mark at most one as best fit
        },
      ],
    },
  ],
}
```

Example call from the model:

```json
{
  "questions": [
    {
      "question": "Which host should this change target?",
      "clarification": "The change touches shared dotfiles.",
      "options": [
        { "label": "pc", "description": "Desktop, NVIDIA", "recommended": true },
        { "label": "laptop" },
        { "label": "gpd" }
      ]
    }
  ]
}
```

## User interface

Questions appear one at a time, followed by a review screen before the answers are returned.

| Screen | What the user sees |
| --- | --- |
| Question | `Question N of M`, the question, the clarification, numbered options, and the custom-answer entry |
| Custom answer | A text editor below the options. Empty input is rejected |
| Review | Every question with its answer. Enter submits, ← goes back to change answers |

Keys:

| Key | Question screen | Custom answer editor | Review screen |
| --- | --- | --- | --- |
| `↑` / `↓` | Move the selection | Edit text | — |
| `1`–`9` | Pick that option directly | Type the digit | — |
| `Enter` | Choose the highlighted option (or open the custom editor) | Save and continue | Submit all answers |
| `←` | Go to the previous question | — | Go back to the last question |
| `→` / `Tab` | Go to the next question, only if this one is answered | — | — |
| `Esc` | Cancel the whole flow | Return to the options | Cancel the whole flow |

Choosing an option moves to the next question automatically. Going back keeps earlier
answers and pre-selects them.

## Results

When the user finishes, the tool returns plain text:

```text
Q1: Which host should this change target?
A1: pc

Q2: ...
A2: <the user's typed answer>
```

If the user cancels, the text says so and includes any answers given before cancelling,
or says that no questions were answered.

If the TUI is not available (for example, print or RPC mode), the tool returns
`Q/A requires an interactive TUI; no questions were asked.` and asks nothing.

## Doubts and questions

If an answer looks like a question or a statement of confusion, the tool result adds a
follow-up asking the model to answer it before continuing. The check is a heuristic:

- contains `?` or `？`
- starts with a question word or auxiliary verb (`who`, `what`, `how`, `is`, `can`, `should`, …)
- contains phrases such as "I'm not sure", "I don't understand", "could you explain", or
  "please clarify"

Option labels are checked too, so keep labels short and avoid question marks in them.

## Error handling

- An empty `questions` array returns `No questions were provided.` and asks nothing.
- A custom answer that is only whitespace is rejected, and the editor asks again.
- If several options are marked `recommended`, only the first is kept. If none is marked,
  the first option is used as the default selection.

## Rendering

- The tool call shows `Q/A Ask N clarifying question(s)`.
- The tool result lists each answer with `✓`. Recommended and custom answers are labelled.
  If a doubt was detected, a warning line tells the model to address it.
