$(function() {
   $("form#load-tweets-form").submit(function(e) {
      $("body").append("<p style='color:red;'>You will be automatically redirected to the search page after all tweets have been loaded.</p>");
      $(this).append("<img src='images/progress-dots.gif' />");
      
      $.ajax({
         url : "loading",
         data : { "user" : $("input#load-tweets-box").val() },
         success : function() {
            //location.href = "/?status=done";
         }
      });
      
      return false;
   });
   
   $("select#category").change(function() {
      if($(this).val() == "1")
         $("div#date-format-info").show();
      else
         $("div#date-format-info").hide();
   });
});
