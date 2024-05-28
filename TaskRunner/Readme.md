## Task Runner

### What does it do?
* `TaskRunner.lua` is the script you select to execute from ME
* `TaskRunner.lua` will require a defined list of other scripts to execute (see the TASKS table in TaskRunner.lua)
* Allows you to define max runtime for a task (e.g you want to only carry out your woodcutting task for 1hr)
* Allows you to define dynamic tables of data the script should focus on for that execution (see the BuyItems examples in this folder)
* The listed scripts will need to contain some common function and variable names to align with the Task Runner framework
* Existing scripts can be easily adapted to work with this

### How do I modify and existing script to be compatible?

* Simply change your **While LoopyLoop** to function `TASK.run()`
* Define `TASK = {}` at the top of your script, and add `return TASK` at the bottom of your script
* See the basic examples in this folder

### How does it work?
* It will grab the first task in the list (if any left) and initalise it with `setTask`
* It will check if the task is marked as complete, or if the RUNTIME limt has been reached
    * If yes, it will remove that task from the list with `finishTask`, and move onto the next task (if available)
* the **While LoopyLoop** in `TaskRunner.lua will` be your master loop across all scripts, and it will call the `run()` function of whichever script it's processing - effectively replicating the **While LoopyLoop** for all scripts


### Usage
* I've been using this throughout DXP to change between different skills/scripts easily
* The example in TaskRunner.lua will buy 2 different sets of items from GE
* I've also used this for fresh accounts, where my TASKS list might look someting like:
```
TASKS = {
    {SCRIPT = "~TaskLogin", RUNTIME = 60}, -- this would be a file called "~TaskLogin.lua", which would auto-kill if it takes more than 60 seconds to finish, if in lobby, logs in, exits when in-world
    {SCRIPT = "~Task_Lodestones", RUNTIME = 300}, -- runs a script to unlock lodestones
    {SCRIPT = "~Task_Quest_Restless_Ghost", RUNTIME = 300}, -- restless ghost quest
    {SCRIPT = "~Task_Quest_Necromancy", RUNTIME = 660} -- necromancy quest
```
