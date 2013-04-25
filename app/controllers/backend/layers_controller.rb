class Backend::LayersController < Backend::ApplicationController
  before_filter :require_category, :except => [:create, :getfeatures]

  def index
    redirect_to [:backend, @category]
  end

  def show
    @layer = @category.layers.find(params[:id])

    respond_with([:backend, @category, @layer])
  end

  def getfeatures
    layer = Layer.find(params[:id])
    @features = WMS::Client.new(layer.data_source_wms, {:layer_name => layer.name}).features_list
    respond_to do |format|
      format.json { render json: @features }
    end
  end

  def new
    @layer = @category.layers.new
    respond_with([:backend, @category, @layer])
  end

  def edit
    @layer = @category.layers.find(params[:id])
    @categories = Category.leafs
    respond_with([:backend, @category, @layer])
  end

  def create
    dimension_values = params.delete(:dimension_values)
    bbox = params.delete(:bbox)
    @layer = Layer.new(params[:layer].reject{ |p| p == "category_id" })
    @layer.crs = params.delete(:srs).first.to_s
    if @layer.save
      if dimension_values && dimension_values.any?
        Dimension.create_dimension_values(@layer, dimension_values)
      end
      if bbox && bbox.any?
        BoundingBox.create_bounding_boxes(@layer, bbox)
      end
      @layer.do_thumbnail
    end

    respond_with(@layer) do |format|
      format.json if request.xhr?
      format.html { redirect_to [:backend, @category] }
    end
  end

  def update
    @layer = @category.layers.find(params[:id])
    @layer.update_attributes(params[:layer])
    respond_with [:backend, @category]
  end

  def destroy
    @layer = @category.layers.find(params[:id])
    @layer.categories.delete(@category)
    # Destroy the relationship between category and layer, if layer doesn't have any categories left, destroy the layer
    if @layer.categories.empty?
      @layer.destroy
    else
      @layer.save
    end
    respond_with([:backend, @category])
  end

  private
  def require_category
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
    else
      @category = Category.find(params[:layer][:category_id])
    end
  end
end
