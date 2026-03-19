---
name: devcontainer
description: "Invoke this skill immediately if the user's request contains any of these trigger phrases: 'devcontainer', 'in the container', 'inside the container', 'docker exec'. Also use when host execution is not viable: (1) node/npm/npx is not found, (2) Node.js version on host is incompatible with the project, or (3) a previous host command failed due to environment/tooling issues. Do not use this skill by default for routine npm/node commands if they can run successfully on the host and the user did not mention the devcontainer."
allowed-tools: Bash(.claude/skills/devcontainer/scripts/exec.sh *)
---

# Run commands in devcontainer

Execute any command inside the project's devcontainer:

```
.claude/skills/devcontainer/scripts/exec.sh <command> [args...]
```

**IMPORTANT**: Always use the relative path shown above — never an absolute path. This ensures the `allowed-tools` rule matches and no permission prompt is shown.

## Notes

- The container workspace is a bind mount of the host project directory — file edits on the host are immediately visible inside the container and vice versa.
- For long-running commands, use `run_in_background: true` on the Bash tool call.
- If no container is running, the script exits with an error suggesting how to start one. Relay this to the user.
