# Consequences Feature

## Overview

Consequences in Home Harmony can be assigned directly to children, to rules, or both. This flexible system allows parents to manage behavior and accountability in a way that fits their family's needs.

## Assignment Logic

- **Direct Assignment:** Select one or more children to assign a consequence directly.
- **Rule-Linked Assignment:** Link a consequence to one or more rules. All children assigned to those rules will automatically inherit the consequence.
- **Combined:** You can assign a consequence to both children and rules; the final list of affected children is the union of both (no duplicates).

## UI Details

- When rules are selected in the consequence form, a preview shows which children will be affected and from which rule(s) they are inherited.
- In the consequences list, linked rules are displayed by their titles for clarity.

## Customization

- To customize consequence assignment logic, see `lib/widgets/consequence_form.dart` and `lib/views/consequences_view.dart`.
- The UI previews which children are affected by rule-linked consequences, and the list view shows rule titles for clarity.

## Example

- Assign a consequence to the rule "No screen time after 8 PM". All children assigned to that rule will inherit the consequence.
- Assign a consequence directly to "Alice". Only Alice will be affected.
- Assign a consequence to both "Bob" and the rule "Chores not done". All children assigned to that rule, plus Bob, will be affected (no duplicates).
