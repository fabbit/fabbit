/**
These functions are globally available UI functions, as well functiosn to control behavior of common UI elements like dropdown
@module UI
**/

// **** GLOBALLY AVAILABLE ERROR HANDLING FUNCTIONS ****
//UI to display Errors
function displayError(message){
		$("#errorMessage").html("Oops: " + message);
		$("#errorMessage").fadeIn(300).delay(5000).fadeOut(300);
}

//Error handling AJAX function - to be used as callback for AJAX errors
function AJAXerrorHandler(request, textStatus, errorThrown) {
      console.log(request);
      var message = (request.status == 403) ? request.responseText : "An unknown error has occured";
      displayError(message);
}

//To show status of an AJAX request to the server
$.ajaxSetup({
    beforeSend: function() {
        $("#progressMessage").fadeIn(300);
    },
    complete: function() {
        $("#progressMessage").fadeOut(300);
    }
});

// **** DROPDOWN UI HANDLING FUNCTIONS ****
$(document).ready(function(){

  $(".dropdown li:first-child").toggle(

  	//One expand add class and post. The posting here posts the unread count
    //TOOD: DO WE REALLY NEED THIS BEHAVIOR? WHAT ARE WE GAINING? TALK TO KEIEN
    function(){ 
    	$(this).parent().addClass("expanded");
      $(this).removeClass("red");
     
  	 	//Do a post if the dropdown is the notifications dropdown
      if ($(this).parent().parent().hasClass('notifications')) {
   	    $.ajax({
       		type: "PUT",
       		url: "<%= j notification_url(current_member.notification) %>",
       		data: {"count": $(".notifications .unread").size()},
       		error: AJAXerrorHandler
       	});  
      }
    }, 
    //On collapse collapse, unless its permenant
    function(){ 
    	if (!$(this).parent().hasClass('perm'))
    		$(this).parent().removeClass("expanded");
    }
  );

  //".dropdown" elements should close when you click away from them (unless they are permenant)
  $('body').click(function(event){
    
    $(".dropdown").each(function(i,el){
      if (!$(el).hasClass('perm'))
          $(el).removeClass("expanded");
      });
  });
});
