This is a tool I developed for creating and updating .json files to be used with my choice driven dialog system in Godot 4.4.1. 

# Features

A json creation and management page, allowing you to select a source folder.

A page to create, delete, and manange "EntityIDs" which are unique identifiers for every dialog capable entity created.

A page to create, delete, and manange "Topics" which belong to an entity and are a dialog instance, with text and player choices.

The final page is used to create, delete, and manange the text and choices in a topic.
  The text will display in the in-game dialogue box in the order its shown in the tool.
  
  The choices have 4 fields, position (the order they show up), 
    text (the text displayed on the choice), 
    destination topic (the topic that will load up when this choice is clicked), 
    and a modifier (used to emit signals in the conversing entity when those dialog options are chosen).
