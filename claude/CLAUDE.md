# Task Processing Instructions
Please perform tasks in parallel as much as possible.

## TODO List
If you asked to create a TODO list, please create it in the `TODO.md` or `TODO_SOME_FEATURE.md` file.
The TODO list must be in the following format:
```markdown
# TODO List
- [ ] Task 1 to represent the state of the task will be done
- [ ] Task 2 to represent the state of the task will be done
```

Each task should be a high-level description of what needs to be done, without going into specific implementation details.
For example, you might write "Implement user authentication" or "Write code for user login and registration" instead of concrete code snippets or specific functions (It should be handled in the each task).

## Sub Agents
Please use parallelized sub-agents for tasks as much as possible. You should handle the overall project management and coordination in order to remember the context and ensure that the project is progressing smoothly, while sub-agents can focus on specific tasks or features.

# Conversation Guidelines
Please don't jump into the work right away.
First, take the time to make a plan and get feedback from the user, so that the design and overall direction are clearly defined before you start the actual work.

## Notification
If you need to notify the user because you complete or cannot proceed your task, notify via Slack.
Assume that the environment variable `SLACK_WEBHOOK_URL` is set. You can send message like this:

```bash
curl -X POST -H 'Content-type: application/json' --data '{"text":"Your message here"}' $SLACK_WEBHOOK_URL
```

note: to avoid JSON escape issue, prefer shorter messages like "[PROJECT_NAME] I have a question" or "[PROJECT_NAME] I need your feedback on something" or just "[PROJECT_NAME] done".

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

