class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :get_categories, only: %i[ new create edit update ]

  # GET /posts or /posts.json
  def index
    @posts = []
    @error_message = nil

    if params[:category].present?
      begin
        # O correto seria essa key deveria ficar no .env
        newsapi = News.new("2a06f25fce394327adfd5748a4737996") 
        response = newsapi.get_sources(category: params[:category])

        news_json = JSON.parse(response.to_json)

        news_json.each do |source|
          new_post = Post.new(title: source['name'], author_id: 0, content: source['description'], category: source['category'])
          @posts << new_post
        end

      rescue UnauthorizedException => e
        @error_message = "Acesso não autorizado à API. Verifique suas credenciais."

      rescue BadRequestException => e
        @error_message = "Requisição inválida. Verifique os parâmetros enviados."
      
      rescue TooManyRequestsException  => e
        @error_message = "Muitas requisições à API. Por favor, tente novamente mais tarde."

      rescue ServerException  => e
        @error_message = "Erro interno do servidor. Por favor, tente novamente mais tarde."

      rescue StandardError => e
        @error_message = "Ocorreu um erro inesperado!" #{e.message}"

      end
    else
      @posts = Post.all
    end
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    def get_categories
      @categories = ["business", "entertainment", "general", "health", "sciences", "sports", "technology"]
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :content, :publishid_at, :author_id, :category)
    end
end
