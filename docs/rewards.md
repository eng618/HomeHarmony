# Rewards & Chores Feature

## Overview

Rewards and chores in Home Harmony help motivate positive behavior. Parents can assign chores to children, and upon completion, children can earn rewards such as additional screen time.

## Assignment Logic

- Assign chores to one or more children.
- Set a reward value (e.g., minutes of screen time) for each chore.
- Children can mark chores as complete; parents can approve or reject completions.
- Approved completions automatically add the reward to the child's screen time bucket.

## UI Details

- Chores and rewards are managed in the Rewards screen.
- Quick-add buttons allow parents to easily add screen time rewards.
- The UI shows which children are assigned to each chore and the status of completions.

## Customization

- To customize rewards and chores logic, see `lib/screens/home/rewards_screen.dart` and related models/services.

## Example

- Assign the chore "Clean room" to Alice and Bob, with a reward of 15 minutes of screen time.
- When Alice marks the chore as complete and a parent approves, Alice's screen time bucket is increased by 15 minutes.
