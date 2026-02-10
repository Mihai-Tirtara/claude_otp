#!/bin/bash
#
# Copyright 2011-2026 The OTP authors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# .claude/hooks/skill-router.sh
# Pre-prompt hook: suggests relevant skill resources based on prompt content
#
# Skills structure:
#   .claude/skills/SKILL.md           (main, loaded by progressive disclosure)
#   .claude/skills/coding-guidelines/resources/
#     coding_style_guide.md
#     review_guide.md
#     testing_guide.md
#     UI_development_guide.md

set -e

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)

PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

SKILL_BASE=".claude/skills/SKILL.md"
RES_DIR=".claude/skills/coding-guidelines/resources"
SUGGESTIONS=""

# Always suggest the main SKILL.md for any code-related prompt
if echo "$PROMPT_LOWER" | grep -qE '(implement|fix|add|change|create|modify|refactor|update|write|edit|debug|service|controller|domain|groovy|grails|gsp|test|spec|review|lint)'; then
  SUGGESTIONS="${SUGGESTIONS}Read main skill: $SKILL_BASE\n"
fi

# Testing triggers → also load testing_guide.md
if echo "$PROMPT_LOWER" | grep -qE '(test|spec|spock|assert|mock|stub|verify|coverage|junit|integration test|unit test|spec\.groovy|test\.groovy)'; then
  SUGGESTIONS="${SUGGESTIONS}Also read: $RES_DIR/testing_guide.md\n"
fi

# UI triggers → also load UI_development_guide.md
if echo "$PROMPT_LOWER" | grep -qE '(gsp|view|template|css|javascript|js|frontend|layout|taglib|ui|page|form|button|modal|ajax|asset|\.(gsp|css|js|less|sass|scss))'; then
  SUGGESTIONS="${SUGGESTIONS}Also read: $RES_DIR/UI_development_guide.md\n"
fi

# Review triggers → also load review_guide.md
if echo "$PROMPT_LOWER" | grep -qE '(review|merge request|mr comment|feedback|code review|approve)'; then
  SUGGESTIONS="${SUGGESTIONS}Also read: $RES_DIR/review_guide.md\n"
fi

# Coding style triggers → also load coding_style_guide.md
if echo "$PROMPT_LOWER" | grep -qE '(codenarc|eslint|lint|style|format|convention|indent|import order)'; then
  SUGGESTIONS="${SUGGESTIONS}Also read: $RES_DIR/coding_style_guide.md\n"
fi

# Deduplicate and output
if [[ -n "$SUGGESTIONS" ]]; then
  DEDUPED=$(echo -e "$SUGGESTIONS" | sort -u)
  echo "📚 Suggested skills:"
  echo "$DEDUPED"

  # Log skill usage to the tools log
  DATE=$(date +%Y-%m-%d)
  TIME=$(date +%H:%M:%S)
  LOG_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/logs/tools-$DATE.log"
  echo "$DEDUPED" | while IFS= read -r line; do
    SKILL_FILE=$(echo "$line" | sed 's/^.*: //')
    [[ -n "$SKILL_FILE" ]] && echo "$TIME|SkillRouter|$SKILL_FILE" >> "$LOG_FILE"
  done
fi

exit 0
