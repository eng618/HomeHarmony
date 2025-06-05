# Rules Feature

## Overview

Rules in Home Harmony allow parents to define expectations and guidelines for children. Rules can be assigned to one or more children and can be linked to consequences for flexible behavior management.

## Assignment Logic

- Assign rules to any number of children.
- Rules can be linked to consequences, so that breaking a rule can automatically trigger a consequence for the assigned children.

## UI Details

- Rules are managed in the Rules screen.
- When editing or creating a rule, you can select which children the rule applies to.
- In the consequences form, you can link consequences to rules, and the system will automatically apply the consequence to all children assigned to those rules.

## Customization

- To customize rule assignment logic, see `lib/widgets/rule_dialog.dart` and `lib/screens/home/rules_screen.dart`.

## Example

- Create a rule "No screen time after 8 PM" and assign it to Alice and Bob.
- Link a consequence to this rule; both Alice and Bob will inherit the consequence if the rule is broken.
