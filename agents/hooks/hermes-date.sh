#!/bin/sh
# Hermes の pre_llm_call shell hook。Claude Code の UserPromptSubmit hook と同じ日時をユーザー発言に付加する。
date '+[%Y-%m-%d (%a) %H:%M:%S %Z]' | jq -Rc '{context: .}'
