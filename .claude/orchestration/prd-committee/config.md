# PRD Committee Configuration

```yaml
rounds:
  min: 2
  max: 3
  target: 3

convergence:
  consensus_threshold: 7.5
  quality_threshold: 7.0
  early_exit: true

user_checkpoints:
  enabled: true                    # Enable user intervention after each round
  mandatory: true                  # Require user confirmation before continuing
  timeout_seconds: 300             # 5 minutes max wait for user input
  brief_style: concise             # concise|detailed

timeouts:
  draft_minutes: 8
  feedback_minutes: 4
  analysis_minutes: 2
  checkpoint_minutes: 5            # Max time for user checkpoint
```