## rules

1. ask before adding code for unlikely edge cases: say what it fixes, how likely it is, and how many lines it costs.
2. validate outside data once at the entry point, then trust the types everywhere else.
3. inline one-time logic and skip try/catch unless the failure is real and you can handle it.
4. keep functions whole unless splitting makes them reused or easier to read.
5. cut any label or explainer text the UI doesn't need, and if it breaks without them, fix the layout.
