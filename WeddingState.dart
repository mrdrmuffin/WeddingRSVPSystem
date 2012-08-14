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
        
        if(fname.value == "")
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