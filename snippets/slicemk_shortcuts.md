# setting up slice mk use keyboard shortcuts in vscode


## On linux:

1. to goto definition: `ctrl + F12`

2. to go back: `ctrl + alt + -`  

{
  "key": "ctrl+alt+-",
  "command": "workbench.action.navigateBack",
  "when": "canNavigateBack"
}

3. Focus tab to the right: `ctrl + PageDown`

{
  "key": "ctrl+pagedown",
  "command": "workbench.action.debug.nextConsole",
  "when": "inDebugRepl"
}


4. Focus tab to the left: `ctrl + PageUp`

{
  "key": "ctrl+pageup",
  "command": "workbench.action.previousEditor"
}

5. Move tab to the right: `ctrl + alt + LeftArrow`

{
  "key": "ctrl+alt+left",
  "command": "workbench.action.moveEditorToPreviousGroup"
}

6. Move tab to the left: `ctrl + alt + RightArrow`

{
  "key": "ctrl+alt+right",
  "command": "workbench.action.moveEditorToNextGroup"
}


## On Mac: 

1. to goto definition: `ctrl + F12`

2. to go back: `ctrl + alt + -`  

{
  "key": "ctrl+alt+-",
  "command": "workbench.action.navigateBack",
  "when": "canNavigateBack"
}

3. Focus tab to the right: `ctrl + PageDown`

{
  "key": "ctrl+pagedown",
  "command": "workbench.action.debug.nextConsole",
  "when": "inDebugRepl"
}


4. Focus tab to the left: `ctrl + PageUp`

{
  "key": "ctrl+pageup",
  "command": "workbench.action.previousEditor"
}

5. Move tab to the right: `ctrl + alt + LeftArrow`

{
  "key": "ctrl+alt+left",
  "command": "workbench.action.moveEditorToPreviousGroup"
}

6. Move tab to the left: `ctrl + alt + RightArrow`

{
  "key": "ctrl+alt+right",
  "command": "workbench.action.moveEditorToNextGroup"
}