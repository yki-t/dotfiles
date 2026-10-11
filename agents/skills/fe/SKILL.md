---
name: fe
description: Rules for frontend UI implementation and UI copy. Covers design components, the project glossary, and word choice (style, amount), and strips explanatory copy out of interfaces. Use when you write, edit, or review UI copy such as headings, empty states, button labels, toggle and setting descriptions, helper text, dialogs, banners, permission notices, and onboarding, or when you implement UI.
---

# Frontend implementation rules

UI copy is in Japanese. Apply these rules when you write or edit UI and UI copy.

## Design components

- Use the design components of the project.
- Do not implement an element yourself, even if it appears on one screen only. If the components do not have the element, report to the user before you implement it.

## Glossary

- Find the project glossary before you write copy. Select words from it.
- If there is no glossary, recommend to the user that they make one. When you write without a glossary, use the words of the existing screens and do not make new words.

## Style

- Always use 敬体.

## Stop describing UI

An interface shows what the user can do. It does not explain itself. Every sentence is text the user must read before they act. Keep a sentence only when the user would make a real mistake without it.

When you write UI, apply the rules as you write. When you review UI, check every string against each rule and show the result as before and after.

If the copy becomes long, do not add text. Change the design: group, add headings, or change the order. If an explanation is still necessary, put it in a "?" tip that shows on hover, not in the body.

### 1. Do not describe the feature

Name the action. The heading, the control, and its label already say what the screen is for.

Before: `No projects yet. Choose a GitHub repository and we'll deploy on every push. [+ New]`
After: `[+ Connect repository]`

### 2. Use specific verbs

Use the verb that names what happens, with the object it acts on. Do not use generic verbs such as New, Create, Manage, Set up, Configure, Go, or OK when a more precise verb exists.

### 3. Keep only the most critical consequence

When an action has several effects, state the one that matters most and remove the rest. Effects that follow from it are implied.

Before: `Turning this off stops AI auto-replies and web reservations. Customer messages are saved only to the conversation log. You can turn it back on anytime from "Replies off" in the header.`
After: `Temporarily turns off AI auto-replies.`

Irreversible or destructive effects, such as data deletion, a charge, or a notification to customers, are the critical consequence and always stay.

### 4. Do not describe backend behavior

Where data is stored, what is logged, what syncs, and what runs in the background are not the concern of the user.

### 5. Do not explain undo when the same control undoes it

A toggle that turns something off also turns it on. Explain undo only when it needs a different control or a different place.

### 6. Do not explain what the page already tells

The page title, the navigation, and the section structure carry meaning. On an Options page, the user knows they look at options.

Before: `# Other options` / `Options that become available with a contract. They cannot be toggled on or off.`
After: `# Other`

### 7. Do not state what does not exist

Do not say that there are no items yet, that something cannot be toggled, or that a feature is not available, when the screen already shows it. An empty list with a clear action says "nothing here yet". A row without a toggle says "cannot be toggled".

Exception: a restriction the user would try and fail at, such as an action their role cannot do. Keep it as one short line with an icon (rule 9).

### 8. Show how to enable, do not write it

If something becomes available by subscribing, upgrading, connecting, or turning on a setting, put the button or toggle on the screen. Do not write where to go or what to do.

Before: `Sign up for the Pro plan to use this option.`
After: `[Upgrade to Pro]`

### 9. Do not rely on text alone

Split prose into short lines, each with an icon first. Use spacing and grouping for structure.

Do not use `->`, `>`, `|`, `✔️`, `!`, `→`, or `:` as separators, arrows, bullets, or emphasis. Use an icon or spacing.

### Checklist

For each string, ask in order.

1. Does it explain what the feature is? Delete it, or make it a specific action label.
2. Is the verb generic? Replace it with one that names the real action and its object.
3. Does it list several consequences? Keep the most critical one.
4. Does it mention storage, logging, syncing, or other internals? Delete it.
5. Does it explain undo with the same control? Delete it.
6. Does the page title or navigation already say it? Delete it.
7. Does it say something is missing or unavailable? Delete it, unless the user would try and fail.
8. Does it tell the user how to enable something? Replace it with the button or toggle.
9. Is it a paragraph, or does it use symbols as separators? Split it into icon-led lines and use spacing.

If nothing is left after the checklist, write nothing. An empty helper text slot is better than a filler sentence.
