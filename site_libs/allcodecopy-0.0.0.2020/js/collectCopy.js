
function initButton( ) {
  document.addEventListener("DOMContentLoaded", function() {
    
    var myButton = "<button type='button' data-clipboard-action='copy' data-clipboard-target='.SmdAidAll' class='btn' >複製</button>";

    
    var codeNodeList = document.querySelectorAll(".SmdAidAll");
    for (var i = 0; i < codeNodeList.length; i += 1) {
      codeNodeList.item(i).insertAdjacentHTML('beforebegin', myButton);
    }
	
   });
 
}

function initBoard( ) {
  document.addEventListener("DOMContentLoaded", function() {
	var clipboard = new Clipboard('.btn');
   });
 
}

initButton();
initBoard()