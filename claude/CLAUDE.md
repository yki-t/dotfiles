# Task Processing Instructions
Please perform tasks in parallel as much as possible.

## Basic Implementation Steps

1. **Understand the Task**: Before starting any task, ensure you fully understand the requirements. If anything is unclear, ask for clarification.
2. **Plan the Implementation**: Create a high-level plan to TODO.md for what needs to be done. This should not include the actual code. (refer to the TODO List section below)
    **You must not write code until this step is complete.**
3. **Implement the TODO List**: Once the plan is approved, implement the tasks in the TODO list. You can assign sub-agents to handle specific tasks in parallel.
    1. Pick one task from the TODO list
    2. Implement the code for that task
      - If you complete the task:
        1. Mark the task as done in the TODO list
        2. Notify the user or the main agent when the task is complete
      - If you have a question or need feedback:
        1. Notify the user or the main agent with your question or request for feedback
        2. Wait for a response before proceeding

After completing the task, we can see the updated TODO list all or partial tasks are done.

## TODO List
If you are asked to create a TODO list, please create it in the `TODO.md` or `TODO_SOME_FEATURE.md` file.
The TODO list must be in the following format:
```markdown
# TODO List
- [ ] Task 1 to represent the state of the task will be done (e.g. "Implement CRUD for /api/v1/some-feature")
    - [ ] implementation detail 1 (e.g. "Implement CREATE /api/v1/some-feature")
    - [ ] implementation detail 2 (e.g. "Implement LIST /api/v1/some-feature")
    - [ ] implementation detail 3 (e.g. "Implement GET /api/v1/some-feature")
    - [ ] implementation detail 4 (e.g. "Implement UPDATE /api/v1/some-feature")
    - [ ] implementation detail 5 (e.g. "Implement DELETE /api/v1/some-feature")
- [ ] Task 2 to represent the state of the task will be done
```

Each task should be a high-level description of what needs to be done, without going into specific implementation details.
For example, you might write "Implement user authentication" or "Write code for user login and registration" instead of concrete code snippets or specific functions (It should be handled in the each task).

## Sub Agents
Please use parallelized sub-agents for tasks as much as possible. You should handle the overall project management and coordination in order to remember the context and ensure that the project is progressing smoothly, while sub-agents can focus on specific tasks or features.

## Implementation
Implement the actual code that is needed for the task at hand.
Avoid mock or placeholder code except when explicitly requested by the user.

Follow these guidelines when implementing code:
- YAGNI (You aren't gonna need it)
- KISS (Keep it simple, stupid)
- DRY (Don't repeat yourself)
- Use meaningful variable and function names (e.g. `getUserById` instead of `getUser` or `getUserInfo`, or `getCorrectUser` (correct is too contextual))

## Documentation
You must not write documentation SOME_FEATURE.md or SOME_FEATURE_INSTRUCTIONS.md unless explicitly requested by the user (except TODO.md).

# Conversation Guidelines

## Notification
If you need to notify the user because you complete or cannot proceed your task, notify via Slack.
Assume that the environment variable `SLACK_WEBHOOK_URL` is set. You can send message like this:

```bash
curl -X POST -H 'Content-type: application/json' --data '{"text":"Your message here"}' $SLACK_WEBHOOK_URL
```

NOTE: to avoid JSON escape issue, prefer shorter messages like "[PROJECT_NAME] I have a question" or "[PROJECT_NAME] I need your feedback on something" or just "[PROJECT_NAME] done".


# command instructions

## Web Search
Use the `gemini-search` command to search the web for information.
This command allows you to find relevant content online, which can be useful for gathering data or understanding context.
Might be better than the built-in `fetch` command.

## aws commands
Assume that the AWS_PROFILE environment variable is set.
You are in the session with the following command:

```bash
export AWS_PROFILE=PROJECT_AWS_PROFILE
```

if aws commands fails repeatedly, You can notify the user via Slack.

## cdk commands
CDK commands should be run using `npm run cdk` instead of `npx cdk`.

## git commands
DO NOT USE git following command:

- `gh pr close`
- `gh pr merge`
- `gh issue close`
- `git push`
- `git push --force`

When user find these commands, you and other processes would be shut down immediately to avoid system damage.

