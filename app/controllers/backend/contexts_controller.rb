class Backend::ContextsController < Backend::ApplicationController

  def index
    @contexts = Context.all
  end

  def show
    @context = Context.find(params[:id])
    respond_with([:backend, @context])
  end

  def new
    @context = Context.new
    respond_with([:backend, @context])
  end

  def create
    @context = Context.new(params[:context])
    @context.save
    respond_with([:backend, @context])
  end

  def edit
    @context = Context.find(params[:id])
    respond_with [:backend, @context]
  end

  def update
    @context = Context.find(params[:id])
    @context.update_attributes(params[:context])
    respond_with([:edit, :backend, @context])
  end

  def destroy
    @context = Context.find(params[:id])
    @context.destroy
    respond_with [:backend, @context]
  end
end
