---
name: report
description: Report a work result, an investigation result or an incident in short conclusion-first paragraphs and lists
argument-hint: <subject. Default: the last work result>
disable-model-invocation: true
---

# report

## Task

Write the report of the given subject (default: the last work result) in the format below.

## Structure

- Line 1 is the conclusion (「修正しました」「以下調査結果です」). Do not start with the history.
- Write evidence, steps and history as a list. Give each history item a time (`[7/27 09:22]`).
- Separate cause, action and affected range. Separate the direct cause and the root cause.
- Separate what is known and what is not known.
- End with the action you ask of the user or with the next step (「ご確認お願いします」「〜してから対応します」). Do not add a closing summary.
- One report has at most a few paragraphs of 2 to 5 lines.

## Style

- 敬体. Inside a list, use 体言止め or 常体 (「〜が発生」「完了」).
- A paragraph is 1 to 3 lines. Separate paragraphs with a blank line. Break a long sentence at a 読点.
- Mark a guess with 「〜かと思います」 or 「〜と思われます」. Mark an uninvestigated item with 「未調査ですが」.
- Connect sentences with 「また、」「なお、」「ただ、」.

## Notation

- Lists use `-`. At most one level of sub-items. No bold at the start of an item.
- Headings only in an incident report: 「原因」「対応」「影響範囲」. Bold only as a substitute for a heading.
- Numbers, paths, environment names, times and URLs go inline in the sentence, not in a table.
- A URL is alone on its line. For two or more URLs, add a short label before each (「UI: 」).
- Commands, configuration values and meeting notes go in a code block.
- To answer a statement of the user, quote it with `>` and answer in 1 to 2 lines under it.

## Asking for a decision

- List the options. Write the effect on the user as a sub-item of each option.
- Write the recommendation as 「可能であれば〜でお願いしたいです」.
- End the question as 「〜でよろしいでしょうか」.

## Do not write

Greetings, announcements (「〜について報告します」), summaries, emoji, exclamation marks, apologies, supplements in parentheses.
