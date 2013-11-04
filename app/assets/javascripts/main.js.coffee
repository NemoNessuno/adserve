isValid = (n) -> 
  +n is n && !(n % 1) && n < 0x800 && n > 0;

@addZone = ->
  width  = parseInt($("#zone_width").val(),10)
  height = parseInt($("#zone_height").val(),10)
  
  if (isValid(width) && isValid(height))
    @zoneList = [] unless @zoneList?
    @zoneList.push "#{width}; #{height}"
    $('#zone_table > tbody:last').append("
      <tr>
        <td>#{width}</td>
        <td>#{height}</td>
      </tr>
      ");
    $("#website_zone_strings").val(@zoneList)
  return

@toggleCategory = (value, checked) ->
  
  @current = [] if !$.trim($('[id$=_categories]').val())

  if (checked)
    @current.push value
  else
    @current = @current.filter (arrValue) -> arrValue isnt value
  
  $('[id$=_categories]').val(@current)
  return

@selectAllCheckBoxes = (element)->
  cblist = $(element).parents(".scrollable").first().find(":checkbox")
  cblist.prop("checked", !cblist.prop("checked"))
  return

@showAds = (zone_id) ->
  if @current_shown_zone?
   $("#{@current_shown_zone}").slideUp('slow') 

  target = $("#adsforzone_#{zone_id}")
  
  if target.is(":hidden")
    $("#help_text").hide()
    target.slideDown('slow') 
    @current_shown_zone = "#adsforzone_#{zone_id}"
  else
    target.slideUp('slow', () ->
      $("#help_text").show()
    )
    @current_shown_zone = null
  
  return

$ ->
  $('.tree').treegrid
  
  $(".secondary-navigation li").hover(
    () -> 
      $(this).addClass("active")
      return
    ,
    () -> 
      $(this).removeClass("active")
      return
  )
  
  $(".scrollable-controller").click(
    () ->
      controller = $(this)
      target = controller.closest(".scrollable").children(".scrollable-content")
      if target.is(":hidden")
        target.slideDown('slow', () -> 
          controller.addClass("expanded").removeClass("collapsed")
          $('.datepicker', target).Zebra_DatePicker({direction: true})
        )
      else  
        target.slideUp('slow', () ->
          controller.addClass("collapsed").removeClass("expanded")
        )
        
      return
      )
  
  return
