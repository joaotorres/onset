# 61: Back the unique player name rule with a database index

Status: needs-triage
Kind: behavioural
Blocked by:
Priority:
Feature:
Model:
Effort:
Changelog:

## Request

Deferred from 54. Back the rule that no two players in a room share a name (case-insensitive) with a database unique index, so two joins at the same moment with one name cannot both get in; today it is a read-then-write check in `Player`, and a join that loses the race should come back with the name error as a taken name does.

## Comments
