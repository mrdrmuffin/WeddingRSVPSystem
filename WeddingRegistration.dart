// Needed for HTML junk
#import('dart:html');
// Needed for the timer
#import('dart:isolate');
// The state map
#source('WeddingState.dart');

// The state counter
num counter = 0;
// Counter for the current position in the writing array
num writingCounter = 0;
// Reload counter for the timer
num writingSpeed = 50;
// Are we currently outputting text or not?
bool isWriting = false;
// The state map
var state;

void main() {
  // Reset everything
  isWriting = false;
  writingCounter = 0;
  state = new WeddingState();

  // Add the onKeyDown handler to intercept input
  window.on.keyDown.add(onKeyDown);
}

// Handle key down events
// This function drives the state machine
void onKeyDown(KeyboardEvent event) 
{
  // Get the text box for outputting text
  var textElement = query("#text");
  
  // [Enter] is the magic key to make this run
  if(event.keyCode == 13)
  {
    // If we're currently writing, stop writing and output the text to the
    // window. Show input if there is any
    if(isWriting == true)
    {
      isWriting = false;
      writingCounter = 2000;
      
      // Set the text
      textElement.text = state.stateMap[counter].textValue;
      // Show the input
      showCurrentInput();
      
      // Exit the state machine
      return;
    }
    
    // Validate the input and move accordingly
    num tc = state.stateMap[counter].ValidateInput();
    
    switch(tc)
    {
      // If it's a jump state, handle specially
      case -1:
        if(state.stateMap[counter].name == "#comingInpt")
        {
          counter = state.completionState;
        }
        else if(state.stateMap[counter].name == "#plus1Inpt")
        {
          counter =  state.dietaryState;
        }
        else if(state.stateMap[counter].name == "#mainFoodInpt")
        {
          counter = state.restrictionState;
        }
        break;
      // Stay on this state if the validation failed
      case 0: 
        return;
      // Move on, nothing to see here
      default:
        counter++;
        break;
    }
    
    // If we haven't reached the end of the state machine, continue
    if(counter < state.stateNum)
    {  
      // Hide inputs indiscriminately
      hideAllInput();
      
      // Handle the intro specially because of the different images
      if(state.stateMap[counter].name == "Intro")
      {
        // Switch the background
        DivElement d = query("#container");
        d.style.backgroundImage = "Url('./Images/bg480.png')";
        
        // Make Oak and the speech-bubble appear
        query("#oak").hidden = false;
        query("#speech-bubble").hidden = false;
      }
      
      // Start writing the current text
      isWriting = true;
      writingCounter = 0;
      
      new Timer(writingSpeed, writeChar);
    }
    
  }
    
  
}

// Write char timer event
// Writes text progressively to the screen
void writeChar(Timer t)
{
  // Get the text
  String s = state.stateMap[counter].textValue;
  
  // If we haven't reached the end, continue writing
  if(writingCounter < s.length)
  {
    var textElement = query("#text");

    // Get the current text to output
    textElement.text = s.substring(0, writingCounter + 1);
    writingCounter++;
    
    // Reload the timer for another go
    new Timer(writingSpeed, writeChar);
  }
  // Else, stop writing and show input (if any)
  else
  {
    isWriting = false;
    showCurrentInput();
  }
}

// Hide all inputs
// This should by done by enumerating through all the states so we don't have
// to add code when a new question is added. Once again, lazy.
void hideAllInput()
{
  query("#nameInpt").hidden = true;
  query("#comingInpt").hidden = true;
  query("#plus1Inpt").hidden = true;
  query("#plus1nameInpt").hidden = true;
  query("#mainFoodInpt").hidden = true;
  query("#guestFoodInpt").hidden = true;
  query("#restrictionInpt").hidden = true;
  query("#memoryInpt").hidden = true;
  query("#submitInpt").hidden = true;
}

// See if this state has input, and show if so
void showCurrentInput()
{
  var inpt = query(state.stateMap[counter].name);
  if(inpt != null)
  {
    inpt.hidden = false;
  }
}


