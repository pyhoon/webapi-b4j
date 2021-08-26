$( document ).ready(function() {
  $("#btnsearch").click(function(e) {
    e.preventDefault();
    $.ajax({
      type: "POST",
      url: "/",
      data: $("form").serialize(), 
      success: function(response)
      {
       if (response.s == "ok") {
            // console.log(response.r);
            var tbl_head = "";
            var tbl_body = "";
            if (response.r.length) {
              tbl_head = "<thead class=\"bg-light\"><th style=\"text-align: right\">#</th><th>Code</th><th>Category</th><th>Name</th><th style=\"text-align: right\">Price</th></thead>";
              tbl_body += "<tbody>";
              $.each(response.r, function() {
                var tbl_row = "";
                $.each(this, function(key, value) {
                  if (key == "ee" || key == "aa") 
                  {
                    tbl_row += "<td style=\"text-align: right\">"+value+"</td>";
                  }
                  else
                  {
                    tbl_row += "<td>"+value+"</td>";
                  }          
                });
                tbl_body += "<tr>"+tbl_row+"</tr>";
              });
              tbl_body += "</tbody>";
            }
            else
            {
              tbl_body = "<tr><td>No results</td></tr>";
            }
            $("#results table").html(tbl_head+tbl_body);
          }
          else {
            $(".alert").html(response.e);
            $(".alert").fadeIn();
          }
        },
        error: function (xhr, ajaxOptions, thrownError) {
          $(".alert").html(thrownError);
          $(".alert").fadeIn();  
        }
      });
  });
});