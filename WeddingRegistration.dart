// Needed for HTML junk
#import('dart:html');
// Needed for the timer
#import('dart:isolate');
// The state map
//#source('WeddingState.dart');

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
  
  // Start information and flavor text
      state.stateMap[state.stateNum] = new RegState(0, "StartScreen", "Press [ENTER]", "", ""); state.stateNum++;
      state.stateMap[state.stateNum] = new RegState(0, "Intro", "Welcome to the LePosey RSVP system.", "", ""); state.stateNum++;
      state.stateMap[state.stateNum] = new RegState(0, "Flavor01", "Presumably you've been invited to our wedding. Correct?", "", ""); state.stateNum++;
      // Fondest memory of the couple
      state.stateMap[state.stateNum] = new RegState(1, "#memoryInpt", "To prove it, what is your fondest memory of the bride and/or groom?", "#Memory", ""); state.stateNum++;
      // Main guest information
      state.stateMap[state.stateNum] = new RegState(2, "#nameInpt", "OK, before we start, what is your name?", "#FirstName", "#LastName"); state.stateNum++;
      state.stateMap[state.stateNum] = new RegState(3, "#comingInpt", "Are you coming to the wedding?", "#NoComing", ""); state.stateNum++;
      // Plus 1 information
      state.stateMap[state.stateNum] = new RegState(3, "#plus1Inpt", "Are you bringing a plus 1?", "#NoGuest", ""); state.stateNum++;
      state.stateMap[state.stateNum] = new RegState(2, "#plus1nameInpt", "What is the name of your guest?", "#Plus1FirstName", "#Plus1LastName"); state.stateNum++;
      // Food information
      state.dietaryState = state.stateNum;
      state.stateMap[state.stateNum] = new RegState(3, "#mainFoodInpt", "Pick your meal type!", "#NoGuest", ""); state.stateNum++;
      state.stateMap[state.stateNum] = new RegState(3, "#guestFoodInpt", "What's your guest's meal type?", "", ""); state.stateNum++;
      state.restrictionState = state.stateNum;
      state.stateMap[state.stateNum] = new RegState(1, "#restrictionInpt", "Do you have any dietary restrictions?", "", ""); state.stateNum++;
      // End information
      state.completionState = state.stateNum;
      state.stateMap[state.stateNum] = new RegState(4, "#submitInpt", "Thank you for your RSVP. Click 'Submit' to finish.", "", ""); state.stateNum++;

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
  
  if(state.stateMap[counter].name == "#submitInpt")
  {
    if(inpt.elements.length == 0)
    {
    InputElement sub = new InputElement("submit");
    sub.name = "submit";
    sub.value = "Submit";
    
    inpt.elements.add(sub);
    }
  }
}


// WeddingState contains all the state information for our RSVP system.
// I added special states for any time we have to skip ahead based on
// previous input.
class WeddingState{
  // Total number of states
  num stateNum = 0;
  // The final state (submit button)
  num completionState = 0;
  // The state for the main food input. Used to skip +1 info.
  num dietaryState = 0;
  // The state for food restrictions. Skips +1 food info.
  num restrictionState = 0;
  // The map of the states
  var stateMap;
  
  WeddingState()
  {
    // The state map is instantiated in the constructor to add the special
    // state numbers.
    // This could also be loaded through XML by having the set of all states
    // and a set of special states. A hash table could be built using the
    // starting state as the key and the target state as the value. I
    // however am lazy and short on time, so it's done in the lame way.
    stateMap = new Map();
    
    // Start information and flavor text
    stateMap[stateNum] = new RegState(0, "StartScreen", "Press [ENTER]", "", ""); stateNum++;
    stateMap[stateNum] = new RegState(0, "Intro", "Welcome to the LePosey RSVP system.", "", ""); stateNum++;
    stateMap[stateNum] = new RegState(0, "Flavor01", "Presumably you've been invited to our wedding. Correct?", "", ""); stateNum++;
    // Fondest memory of the couple
    stateMap[stateNum] = new RegState(1, "#memoryInpt", "To prove it, what is your fondest memory of the bride and/or groom?", "#Memory", ""); stateNum++;
    // Main guest information
    stateMap[stateNum] = new RegState(2, "#nameInpt", "OK, before we start, what is your name?", "#FirstName", "#LastName"); stateNum++;
    stateMap[stateNum] = new RegState(3, "#comingInpt", "Are you coming to the wedding?", "#NoComing", ""); stateNum++;
    // Plus 1 information
    stateMap[stateNum] = new RegState(3, "#plus1Inpt", "Are you bringing a plus 1?", "#NoGuest", ""); stateNum++;
    stateMap[stateNum] = new RegState(2, "#plus1nameInpt", "What is the name of your guest?", "#Plus1FirstName", "#Plus1LastName"); stateNum++;
    // Food information
    dietaryState = stateNum;
    stateMap[stateNum] = new RegState(3, "#mainFoodInpt", "Pick your meal type!", "#NoGuest", ""); stateNum++;
    stateMap[stateNum] = new RegState(3, "#guestFoodInpt", "What's your guest's meal type?", "", ""); stateNum++;
    restrictionState = stateNum;
    stateMap[stateNum] = new RegState(1, "#restrictionInpt", "Do you have any dietary restrictions?", "", ""); stateNum++;
    // End information
    completionState = stateNum;
    stateMap[stateNum] = new RegState(4, "#submitInpt", "Thank you for your RSVP. Click 'Submit' to finish.", "", ""); stateNum++;
  }
}

class RegState {
  /* Types
   * 0 = flavor
   * 1 = textArea
   * 2 = dual text box
   * 3 = radio
   * 4 = submit
  */
  final num sType;  
  // State name
  final String name;
  // Text for the state (to print on screen)
  final String textValue;
  // Name of the first input element in html (if any)
  String inputName1;
  // Name of the second input element in html (if any)
  String inputName2;
  
  // Constructor
  RegState(this.sType, this.name, this.textValue, this.inputName1, this.inputName2)
  {
  }
  
  // Validate input
  // 0 to stay on this state
  // 1 to advance
  // -1 for a jump
  // Put all special state transitions with -1 and handle in main app
  num ValidateInput()
  {
    if(this.inputName1 == "") { return 1; }
    
    switch(this.sType)
    {
      // TextArea states
      case 1:
        TextAreaElement fname = query(this.inputName1);
        
        if(fname.value.trim() == "")
        {
          return 0;        
        }
        break;
      // Dual text box states
      case 2:
        InputElement fname = query(this.inputName1);
        InputElement lname = query(this.inputName2);
        
        if(fname.value == "" || lname.value == "")
        {
          return 0;         
        }
        
        break;
      // Radio button states (usually jumps)
      case 3:
        InputElement rad = query(this.inputName1);
        
        if(rad.checked == true)
        {
          return -1;
        }
        break;
    }
    
    return 1;
  }
}


