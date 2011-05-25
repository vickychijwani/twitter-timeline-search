$(function() {
   $("form#load-tweets-form").submit(function(e) {
      $("#message-drawer span").html("Loading tweets. Hang on...");
      $("#message-drawer").show();
      $(this).children(".loading").show();
      $(this).children("#load-tweets-button").attr('disabled', 'disabled');
      
      $.ajax({
         url : "loading",
         data : { "user" : $("input#load-tweets-box").val() },
         success : function(success) {
            $(".loading").hide();
            $(this).children("#load-tweets-button").removeAttr('disabled');
            if(success == "true") {
               location.href = "/?status=done";
            }
            else {
               $("#message-drawer .message-inside span").html("No such user.");
            }
         }
      });
      
      return false;
   });
   
   $("form#load-tweets-form input#load-tweets-box").keyup(function() {
      if($(this).val().length == 0) {
         $(this).siblings("input#load-tweets-button").disable();
      }
      else {
         $(this).siblings("input#load-tweets-button").enable();
      }
   });
   
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
});
