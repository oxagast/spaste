/**
 * Defines various functions to give functionality to
 * the terminal website 
 *
 * @summary gives functionality to terminal website 
 * @author Patrick McCarty <patricksantos1234567@gmail.com>
 *
 * Created at     : 2022-11-19 12:21:56 
 * Last modified  : 2022-12-30 12:44:00
 */


/** 
 * sleeps for a given number of ms
 */
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}


/** 
 * decide how the program should resopond to certain key presses
 */
function choosePath(e){

  document.getElementById("myInput").focus();
  if(e.key == 'Enter'){
    printUser();
  } else if(e.keyCode == '38'){ // up arrow
    e.preventDefault();
    if(counter <= 0){
      document.getElementById("myInput").value = hist[0];
    } else{
      counter--;
      document.getElementById("myInput").value = hist[counter];
    } 
  } else if(e.keyCode == '40'){ // down arrow
    e.preventDefault();
    if(document.getElementById("myInput").value == ""){
      //do nothing
    } else if(counter == hist.length - 1){
      document.getElementById("myInput").value = "";
      counter++;
    } else if(counter > hist.length - 1){
      document.getElementById("myInput").value = "";
    } else{
      counter++;
      document.getElementById("myInput").value = hist[counter];
    }
  }
}


/** 
 * called at the start of the program. Creates text box, displays logo and help message
 */
async function start(){
  let newLine = document.createElement("div");
  newLine.className = "spaced";
  newLine.id = "sp";

  let username = document.createElement("span");
  let col = document.createElement("span");
  let til = document.createElement("span");
  let dol = document.createElement("span");

  let tbox = document.createElement("input");
  tbox.className = "inputText";
  tbox.spellcheck = false;
  tbox.id = "myInput";

  username.appendChild(document.createTextNode("nobody@spaste.oxasploits.com"));
  username.className = "blackText";

  col.appendChild(document.createTextNode(":"));
  col.className = "blackText";

  til.appendChild(document.createTextNode("~"));
  til.className = "blackText";

  dol.appendChild(document.createTextNode("$"));
  dol.className = "blackText";

  newLine.appendChild(username);
  newLine.appendChild(col);
  newLine.appendChild(til);
  newLine.appendChild(dol);

  newLine.appendChild(tbox);
  document.body.appendChild(newLine);

  let helpMessage = document.createElement("p");
  helpMessage.className = "hlpMessage";
  helpMessage.id = "hlp";
  helpMessage.textContent = "Type " + "\'help\' for the list of commands!";

  /* logo(true); */

  document.getElementById("invisible_div").appendChild(helpMessage);
  document.getElementById("myInput").focus();
}


/** 
 * copies input box and contents into a new string and appends it to the screen.
 * Then decides what function to call based on the input in the text box
 */
function printUser(){

  x = document.getElementById("myInput").value;

  let newLine = document.createElement("div");
  newLine.className = "spaced";

  let username = document.createElement("span");
  let col = document.createElement("span");
  let til = document.createElement("span");
  let dol = document.createElement("span");

  username.appendChild(document.createTextNode("nobody@spaste.oxasploits.com"));
  username.className = "blackText";

  col.appendChild(document.createTextNode(":"));
  col.className = "blackText";

  til.appendChild(document.createTextNode("~"));
  til.className = "blackText";

  dol.appendChild(document.createTextNode("$"));
  dol.className = "blackText";

  newLine.appendChild(username);
  newLine.appendChild(col);
  newLine.appendChild(til);
  newLine.appendChild(dol);

  let thing = document.createElement("span");
  thing.appendChild(document.createTextNode(" " + x));
  thing.className = "greyText";
  newLine.appendChild(thing);

  document.getElementById("invisible_div").appendChild(newLine);
  let element = document.getElementById("sp");
  element.scrollIntoView();
  if(x.trim() != ""){
    hist.push(document.getElementById("myInput").value);
  }
  document.getElementById("myInput").value = "";
  counter = hist.length;

  if(x == "clear"){
    clear();
  } else if(x.toLowerCase() == "help"){
    help();
  } else if(x.toLowerCase() == ""){
    // do nothing
  } else if(x.toLowerCase() == "author"){
    author();
  } else if(x.toLowerCase() == "email"){
    email();
  } else if(x.toLowerCase() == "usage"){
    usage();i
  } else if(x.toLowerCase() == "install"){
    installing();
  } else if(x.toLowerCase() == "history"){
	history();
  }else{
    invalid();
  }

  element = document.getElementById("sp");
  element.scrollIntoView();

}


/** 
 * clears DOM elements from the 'invisible_div', leaving only the input box
 */
function clear(){
  let element = document.getElementById("invisible_div");
  element.innerHTML = '';
}


/** 
 * displays the various commands of this website
 */
function help(){

  const commands = []
  commands[0] = 'help' + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0' + 'print commands';
  commands[1] = 'clear' + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0' + 'clear terminal';
  commands[2] = 'author' + '\xa0\xa0\xa0\xa0\xa0\xa0' + 'about spaste\'s author';
  commands[3] = 'usage' + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0' + 'display spaste usage help page';
  commands[4] = 'install' + '\xa0\xa0\xa0\xa0\xa0' + 'display spaste install help page';
  commands[5] = 'email' + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0' + 'author email';
  commands[6] = 'history' + '\xa0\xa0\xa0\xa0\xa0' + 'previously used commands';

  for(let i = 0; i < commands.length; i++){
    let buf = document.createElement("p");
    buf.textContent = commands[i];
    buf.className = "blackText";
    document.getElementById("invisible_div").appendChild(buf);
  }
}


/** 
 * displays message for invalid commands
 */
function invalid(){
  const store = document.createElement("div");
  store.className = "blackText";

  const err = document.createElement("div");
  err.appendChild(document.createTextNode("\'" + x + "\'" + " is not a valid command"));

  const hlp = document.createElement("div");
  hlp.appendChild(document.createTextNode("Type " + "\'help\' for the list of commands"));

  store.appendChild(err);
  store.appendChild(hlp);
  document.getElementById("invisible_div").appendChild(store);
}

/** 
 * prints a discription about who I am
 */
function author(){
  const store = document.createElement("div");
  const par = document.createElement("p");
  par.className = "half";

  par.textContent = "Hi! I'm oxagast, author of Spaste.  I enjoy breaking code, writing security focused"
      + " applications, exploits, and gadgets.  I also enjoy gardening, working on trucks and other"
      + " mechanical things, cooking, as well as hanging with my loving girlfriend.  If you would like"
      + " to see more of my projects, visit https://oxasploits.com!";

   par.className = "blackText";
  store.appendChild(par);
  document.getElementById("invisible_div").appendChild(par);
}


/** 
 * gives link to email
 */
function email(){
  const store = document.createElement("p");
  store.textContent = "my email: ";
  const link = document.createElement("a");
  link.textContent = "oxagast@oxasploits.com";

  link.href = "mailto:oxagast@oxasploits.com";
  store.appendChild(link);
  document.getElementById("invisible_div").appendChild(store);
}

function usage(){
  const store = document.createElement("div");
  const par = document.createElement("p");
  par.className = "half";

  par.textContent = "Usage: echo oxagast | sp";

  store.appendChild(par);

    par.className = "blackText";
  document.getElementById("invisible_div").appendChild(par);
}

function installing(){
  const store = document.createElement("div");
  const par = document.createElement("p");
  par.className = "half";

  par.textContent = "Install: ./install.sh";

  store.appendChild(par);
    par.className = "blackText";
  document.getElementById("invisible_div").appendChild(par);
}


/**
 * Display history
 */
function history(){
  for(let i = 0; i < hist.length; i++){
    let buf = document.createElement("p");
    buf.textContent = hist[i];
    buf.className = "blackText";
    document.getElementById("invisible_div").appendChild(buf);
  }
}


window.addEventListener("keydown", choosePath); // listen for key presses

var x = "";			// the input that will be in the input box
var sleepTime = 30; // the time  between each color change for logo
var hist = [];		// an array to store all commands excecuted by the user
var counter = 0;	// used to sift through the previous commands
