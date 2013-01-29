class App.CartItemView extends Backbone.View
  tagName: "li"
  template: _.template("<div class='grippy'></div>
    <div class='right-infos'>
      <label for='<%= name %>' class='title'>
        <input type='checkbox' class='layer-visibility' <% if(visible) { %> checked <% } %> id='<%=name %>'>
        <a title='<%= title %>' class='unstyled'><%= title %></a>
      </label>
      <% if(dimension) { %>
        <div class='m-btn-group control-buttons'>
          <a class='m-btn first mini backward' ><i class='icon-step-backward'></i></a>
          <a class='m-btn mini play <% if(playing) { %> active <% } %>'><i class=<% if(playing) { %>'icon-pause' <% } else { %> 'icon-play' <% } %>></i></a>
          <a class='m-btn mini forward'><i class=' icon-step-forward'></i></a>
        </div>
      <% } %>
      <div class='m-btn-group control-buttons'>
        <a class='m-btn mini first query' data-toggle='button' rel='tooltip' data-original-title='Informations sur la couche'><i class='icon-info-sign'></i></a>
        <a class='m-btn mini opacity <% if(controllingOpacity) { %> active <% } %>' data-toggle='button' rel='tooltip' data-original-title='Opacité'><i class='icon-adjust'></i></a>
        <a class='m-btn mini center' rel='tooltip' data-original-title='Centrer'><i class='icon-screenshot'></i></a>
        <a class='m-btn mini remove' rel='tooltip' data-original-title='Supprimer'><i class='icon-remove'></i></a>
      </div>
      <% if(dimension) { %>
          <ul class='unstyled dimensions-list'>
            <% _.each(dimensions, function(dim, i) { %>
              <li class='dimension<% if (i == timelineCounter) { %> active <% } %>'><%= moment(dim.dimension.value).calendar() %></li>
            <% }) %>
          </ul>
      <% } %>
      <div class='opacity-controler <% if(!controllingOpacity) { %> hide <% } %>'>
        <div class='opacity-slider'></div>
      </div>
    </div>"
  )

  events: 
    "click  .remove"           : "removeLayer"
    "click  .query"            : "toggleClicListener"
    "click  .backward"         : "backwardTimeline"
    "click  .forward"          : "forwardTimeline"
    "click  .play"             : "toggleTimeline"
    "click  .dimension"        : "gotoTime"
    "change .layer-visibility" : "toggleVisibility"
    "click  .center"           : "panToLayer"
    "click  .opacity"          : "toggleOpacity"

  removeLayer: ->
    @model.removeFromMap()

  toggleClicListener: (e) ->
    $self = $(e.currentTarget)
    $(".query").not($self).removeClass("active")
    @mapProvider.toggleClicListener(!$self.hasClass("active"), @model.attributes)

  toggleVisibility: (e) ->
    if (@$el.find(".layer-visibility").attr("checked") == "checked")
      @model.toggleVisibility(true, 1)
    else
      @model.toggleVisibility(false, 0)

  toggleOpacity: (e) ->
    $e = $(e.currentTarget)
    if $e.hasClass("active")
      @$el.find(".opacity-controler").hide()
      @model.set controllingOpacity: false
    else
      @$el.find(".opacity-controler").show()
      @model.set controllingOpacity: true

  changeOpacity: ->
    @model.get("leaflet").setOpacity(@model.get("opacity")/100)

  toggleTimeline: (e) ->
    $e = $(e.currentTarget)
    if $e.hasClass("active")
      $e.removeClass("active").find("i").removeClass("icon-pause").addClass("icon-play")
      @model.pauseTimeline()
    else
      $e.addClass("active").find("i").removeClass("icon-play").addClass("icon-pause")
      @model.playTimeline()

  backwardTimeline: (e) ->
    @model.showtime(-1)

  forwardTimeline: (e) ->
    @model.showtime(1)

  gotoTime: (e) ->
    $e = $(e.currentTarget)
    @model.showtime(0, $e.index())

  panToLayer: (e) ->
    if @model.get("bbox")["CRS:84"]
      projBox = @mapProvider.arrayToLatLngBounds(@model.get("bbox")["CRS:84"].table.bbox)
    else if @model.get("bbox")["EPSG:4326"]
      projBox = @mapProvider.arrayToLatLngBounds(@model.get("bbox")["EPSG:4326"].table.bbox)
    else
      projBox = @mapProvider.bboxTo4326(@model.get("bbox")["EPSG:2154"].table.bbox)
    console.log projBox
    @mapProvider.fitBounds(projBox)

  initialize: ->
    @changeOpacity()
    @model.on("change:playing", @render, this)
    @model.on("change:timelineCounter", @render, this)
    @model.on("change:opacity", @changeOpacity, this)
    @model.on("removeFromMap", @destroy, this)
    @mapProvider = @options.mapProvider

  destroy: ->
    @$el.remove()

  render: ->
    that = @
    attributes = @model.toJSON()
    # escape quotes
    attributes.title = attributes.title.replace(/'/g, "&#39;")
    console.log attributes
    @$el.html(@template(attributes))
    @$el.find('.opacity-slider').slider 
      value: attributes.opacity
      range: "min"
      change: (e, ui) ->
        that.model.set opacity: ui.value
        true

    return this
