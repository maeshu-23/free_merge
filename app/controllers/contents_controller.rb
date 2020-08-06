class ContentsController < ApplicationController
  before_action :set_content, only: [:show, :destroy, :edit, :update]
  before_action :content_category, only: [:edit, :update]
  def index
  end

  def show
  end
  

  def new
    @category_parent_array = Category.where(ancestry: nil)
    if user_signed_in?
      @content = Content.new
      @content.images.build
    else
      redirect_to root_path
    end
  end

  def create
    @content = Content.new(content_params)
    @content.images.present?
    @content.save!
    redirect_to root_path 
  end

  def destroy
    if @content.destroy
      redirect_to root_path, notice: '削除しました'
    else
      render :show
    end
  end

  def edit
   
    # if user_signed_in?
    #   @content.images.build
    # else
    #   redirect_to root_path
    # end
    
  end

  def update
    if params[:content].keys.include?("image") || params[:content].keys.include?("images_attributes") 
      if @content.valid?
        if params[:content].keys.include?("image") 
        # dbにある画像がedit画面で一部削除してるか確認
          update_images_ids = params[:content][:image].values #投稿済み画像 
          before_images_ids = @content.images.ids
          #  商品に紐づく投稿済み画像が、投稿済みにない場合は削除する
          # @product.images.ids.each doで、一つずつimageハッシュにあるか確認。なければdestroy
          before_images_ids.each do |before_img_id|
            Image.find(before_img_id).destroy unless update_images_ids.include?("#{before_img_id}") 

          end
        else
          # imageハッシュがない = 投稿済みの画像をすべてedit画面で消しているので、商品に紐づく投稿済み画像を削除する。
          # @product.images.destroy = nil と削除されないので、each do で一つずつ削除する
          before_images_ids.each do |before_img_id|
            Image.find(before_img_id).destroy 
          end
        end
        @content.update!(content_params)
        # @size = @content.categories[1].sizes[0]
        # @content.update(size: nil) unless @size
        redirect_to :root, notice: "商品を更新しました"
      else
        render 'edit'
      end
    else
      redirect_back(fallback_location: root_path,flash: {success: '画像がありません'})
    end
    # @content.images.present?
    # if @content.update!(content_params)
    #   redirect_to root_path      
    # else
    #   render :edit
    # end
  end

  def get_category_children
    @category_children = Category.find("#{params[:parent_id]}").children
  end

  def get_category_grandchildren
    @category_grandchildren = Category.find("#{params[:child_id]}").children
  end

  private

  def content_params
    params.require(:content).permit(:name, :category_id, :price, :explain, :size, :brand, :status, :postage, :shipment, :prefecture, images_attributes: [:content_image, :id, :_destroy] ).merge(user_id: current_user.id)
  end

  def set_content
    @content = Content.find(params[:id])
  end

  def content_category
    @grandchild = @content.category
    @child = @grandchild.parent
    @category_parent_array = Category.where(ancestry: nil)
    @category_child_array = Category.where(ancestry: @child.ancestry)
    @category_grandchild_array = Category.where(ancestry: @grandchild.ancestry)
  end
end
