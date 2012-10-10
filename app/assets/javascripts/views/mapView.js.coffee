class App.MapView extends Backbone.View
  el: "div#map",
  initialize: ->
    @mapProvider = this.options.mapProvider
    @initialCenter = this.options.initialCenter || { latitude: @$el.data("latitude"), longitude: @$el.data("longitude") }
    @render()
  setInitialView: ->
    @mapProvider.setViewForMap
      latitude: @initialCenter.latitude,
      longitude: @initialCenter.longitude
      zoomLevel: @$el.data("zoom")
  addBaseLayer: ->
    osm = L.tileLayer.wms("http://osm.geobretagne.fr/gwc01/service/wms", {
      layers: "osm:google",
      format: 'image/png',
      transparent: true,
      continuousWorld: true,
      unloadInvisibleTiles: false
    })
    @mapProvider.addLayerToMap(osm)
  addWatermark: ->
    watermark = L.control({position: "bottomright"})
    watermark.onAdd =  (map) ->
      this._div = L.DomUtil.create('div', 'watermark');
      this._div.innerHTML = "<img src='/assets/dotgee.png'/>"
      return this._div;
    watermark.addTo(@mapProvider.map)
  addGetFeatures: ->
    features = L.control({position: "bottomleft"})
    features.onAdd= ->
      @_div = L.DomUtil.create('div', 'features-infos');
      @_div.innerHTML = "<div class='table-results'></div>"
      @_div
    @mapProvider.map.addControl(features)
  render: ->
    @mapProvider.createMap(@el.id)
    @addBaseLayer()
    @addWatermark()
    @addGetFeatures()
    @setInitialView()