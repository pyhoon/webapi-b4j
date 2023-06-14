  $("#btnGetDefaultTopic").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "GET",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnGetTopicFromSlug").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "GET",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnGetCategories").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "GET",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnGetCategory").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "GET",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnPostCategory").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "POST",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnPutCategory").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "PUT",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnDeleteCategory").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "DELETE",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnGetProducts").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "GET",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnGetProduct").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "GET",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnPostProduct").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "POST",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnPutProduct").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "PUT",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnDeleteProduct").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "DELETE",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnGetCategoriesByKeyword").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "GET",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
  $("#btnGetProductsByKeyword").click(function(e) {
    e.preventDefault();
	var id = $(this).attr("id");
	$("#response"+id).val("");
	//console.log('url:'+$('#path'+id).val());
    $.ajax({
      type: "GET",
	  dataType: "json",
      url: $("#path"+id).val(),
      data: $("#body"+id).val(),
      success: function (data) {
        if (data.s == "ok" || data.s == "success") {
          var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.m);
          $("#alert" + id).removeClass("alert-danger");
          $("#alert" + id).addClass("alert-success");
          $("#alert" + id).fadeIn();
        }
        else {
          //console.log(data.e);
		  var content = JSON.stringify(data.r, undefined, 2);
          $("#response" + id).val(content);
          $("#alert" + id).html(data.a + ' ' + data.e);
          $("#alert" + id).removeClass("alert-success");
          $("#alert" + id).addClass("alert-danger");
          $("#alert" + id).fadeIn();
        }
      },
      error: function (xhr, ajaxOptions, thrownError) {
        $("#alert" + id).html('400 ' + thrownError);
        $("#alert" + id).removeClass("alert-success");
        $("#alert" + id).addClass("alert-danger");
        $("#alert" + id).fadeIn();		  
      }
    })
  })
