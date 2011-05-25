$(function() {
   $("form#load-tweets-form").submit(function(e) {
      $("body").append("<p style='color:red;'>You will be automatically redirected to the search page after all tweets have been loaded.</p>")
      $.ajax({
         url : "loading",
         data : { "user" : $("#user-box").val() },
         success : function() {
            location.href = "/"
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
