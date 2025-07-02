# Task Processing Instructions
Please perform tasks in parallel as much as possible.

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

