#
# Common view for categories and layers items
#
##############################################

class App.CatalogItemView extends Backbone.View
  className: "media"
  categoryTemplate: _.template("
  <div class='media-wrapper'>
    <div class='media-body'>
      <h4 class='media-heading category'>
        <i class='icon-folder-open'></i>
        &nbsp;
        <%= name %>
      </h4>
    </div>
  </div>")
  layerTemplate: _.template("
  <div class='media-wrapper media-layer <% if(onMap) { %>added<% } %>'>
    <a class='pull-left' href='#'>
      <img class='media-object' src='http://placehold.it/64x64' width='64' height='64'  >
    </a>
    <div class='media-body'>

      <h4 class='media-heading layer-heading'><%= title %></h4>
      <% if(description) { %><div class='description'> <%= description %> </div><% } %>
    </div>
  </div>")

  events: 
    "click .media-layer": "toggleOnMap"
    "click .category" : "displayChildren"
  
  initialize: ->
    @parentView = @options.parentView
    @layers = @parentView.layers
    @hud = @parentView.hud
    @cartCollection = @hud.cartCollection
    @model.on("change:onMap", @render, this)

  toggleOnMap: (e) ->
    if @cartCollection.get(@model)
      @model.removeFromMap()
    else
      @cartCollection.add(@model)

  displayChildren: (e) ->
    if @model.get("children").length == 0
      that = this
      layers = @layers.filter( (layer) ->
        _.contains(layer.get("category_ids"), that.model.get("id"))
      )
      layerCollection = new App.LayerCollection(layers)
      layerCollection.parent = {}
      layerCollection.parent.collection = @model.collection
      @parentView.collection = layerCollection
    else
      @parentView.collection = @model.get("children")
    @parentView.appendCategory(@model)
    @parentView.render()
  render: ->
    attributes = @model.toJSON()
    if @model.get("model") == "category"
      @$el.html(@categoryTemplate(attributes))
    else
      @$el.addClass("layer")
      @$el.html(@layerTemplate(attributes))
    return this
