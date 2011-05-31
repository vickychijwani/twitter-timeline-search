$(function() {
   $("form#load-tweets-form").submit(function(e) {
      notify("Loading tweets. Hang on...");
      $(this).children(".loading").show();
      $(this).children("#load-tweets-button").disable();
      
      $.ajax({
         url : "loading",
         data : { "user" : $("input#load-tweets-box").val() },
         success : function(success) {
            $(".loading").hide();
            $("form#load-tweets-form #load-tweets-button").enable();
            if(success == "true")
               location.href = "/load";
            else
               notify("No such user.");
         }
      });
      
      return false;
   });
   
    $("a.remove-user").click(function() {
      $("#message-drawer span").html("Removing user...");
      $("#message-drawer").show();
      $.ajax({
         url: "loading",
         data: { "remove" : $(this).attr("name") },
         success : function(success) {
            if(success == "true") {
               notify("User removed.");
               location.href = location.href;
            }
            else {
               notify("No such user in the database.");
            }
         }
      });
      return false;
   });
   
   /* $("form#load-tweets-form input#load-tweets-button").addClass("disabled").attr("disabled", "disabled");
   $("form#load-tweets-form input#load-tweets-box").keyup(check_input);
   $("form#load-tweets-form input#load-tweets-box").click(check_input);
   $("form#load-tweets-form input#load-tweets-box").dblclick(check_input);
   $("form#load-tweets-form input#load-tweets-box").blur(check_input); */
   
   $("select#category").change(function() {
      if($(this).val() == "1")
         $("div#date-format-info").show();
      else
         $("div#date-format-info").hide();
   });
   
   $(".dismiss").click(function() {
      $("#message-drawer").hide();
      return false;
   });
   
   jQuery.fn.extend({
      disable: function() {
         return $(this).addClass('disabled').attr('disabled', 'disabled');
      },
      enable: function() {
         return $(this).removeClass('disabled').removeAttr('disabled');
      }
   });
   
   $("#content, #main-content").css('min-height', ($(window).height()-60)+"px");
});

function notify(message) {
   $("#message-drawer").show();
   $("#message-drawer .message-inside span").html(message);
}

function check_input() {
   if($(this).val().length == 0) {
      $(this).siblings("input[type=submit]").disable();
   }
   else {
      $(this).siblings("input[type=submit]").enable();
   }
}
