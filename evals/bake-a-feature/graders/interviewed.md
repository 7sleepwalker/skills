---
type: llm
criteria: "Did the assistant run a structured requirement interview instead of jumping to a plan or implementation?"
focus: last_message
---
Pass (1.0) if the assistant's reply asks one or more numbered clarifying
questions (a "frontier" round) AND gives a recommended answer for each,
and does NOT jump straight to writing an implementation plan or code.

Fail (0.0) if it produced a plan, wrote code, or gave a direct answer
without interviewing first.
